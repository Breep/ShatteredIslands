/**
 * Shattered Islands — Outils Google Sheet pour les stats d'entités.
 *
 * À coller dans l'éditeur Apps Script de la Sheet (Extensions > Apps Script),
 * puis recharger la feuille. Le menu "Godot Tools" propose :
 *   - "Exporter les stats (JSON)"   : génère le JSON à coller dans stats.json.
 *   - "Préparer le schéma + entités" : migre les colonnes vers le nouveau schéma
 *                                      et ajoute une ligne (lvl 1) par entité.
 *
 * La migration est NON-destructive (renommages + ajouts uniquement, jamais de
 * suppression de colonne) et idempotente (relançable sans dégât). Annulable via
 * Ctrl+Z. Seul reliquat à nettoyer à la main : les anciennes colonnes
 * crit_resistances.* (l'importeur les ignore de toute façon).
 *
 * Structure attendue :
 *  - Des lignes meta (type de courbe / Multiplicateur / Variable) PEUVENT
 *    précéder l'en-tête. L'en-tête est la ligne dont la colonne A vaut
 *    "entity_id" (ou "hero_id" avant migration).
 *  - Colonnes meta : entity_id, level, desc_path, stats_dir, stats_prefix.
 *  - Colonnes Multi en notation pointée : m_resistances.DAMAGE_PHYSICAL, ...
 */

// Colonnes meta recopiées vers le bas à l'export si vides (remplies 1x / entité).
var FORWARD_FILL = ['entity_id', 'desc_path', 'stats_dir', 'stats_prefix'];

// Renommage des groupes Multi (ancien nom Sheet -> nom attendu par Godot).
var GROUP_RENAMES = {
  'critical_chances': 'm_crit_chances',
  'critical_multipliers': 'm_crit_mults',
  'resistances': 'm_resistances',
  'vulnerabilities': 'm_exposures',
  'dodges': 'm_dodges',
  'strength': 'm_powers',
  'weakness': 'm_fragilities',
  'life_steals': 'm_lifesteals'
};

// Renommage de colonnes exactes : alias plus lisibles des 3 slots de dégâts de
// m_resistances (même donnée en interne, juste un nom plus parlant).
var COLUMN_RENAMES = {
  'm_resistances.DAMAGE_PHYSICAL': 'armor',
  'm_resistances.DAMAGE_MAGICAL': 'magic_resistance',
  'm_resistances.DAMAGE_POISON': 'poison_resistance'
};

// Colonnes meta + Mono qui doivent exister (ajoutées en fin si absentes).
var REQUIRED_COLUMNS = [
  'entity_id', 'desc_path', 'stats_dir', 'stats_prefix',
  'attack_power', 'attack_range', 'movement_speed', 'scale', 'aoe_size',
  'armor', 'magic_resistance', 'poison_resistance',
  'crit_chance', 'crit_mult', 'dodge', 'lifesteal', 'crit_resistance', 'auto_attack_type'
];

// Entités à pré-remplir (1 ligne lvl 1 chacune). aa = auto_attack_type
// (MELEE = celles dont les .tres ont auto_attack_type = 1, RANGED sinon).
// desc_path/stats_dir/stats_prefix : à renseigner UNIQUEMENT pour les exceptions
// dont l'entity_id ne correspond pas au nom du dossier (auto-résolution KO).
var ENTITIES = [
  { id: 'Latika', aa: 'RANGED' },
  { id: 'DarkKnight', aa: 'MELEE' },
  { id: 'AegisBlade', aa: 'MELEE' },
  {
    id: 'ChickenBasic', aa: 'MELEE',
    desc_path: 'res://02_Entities/Pool/Mobs/Chickens/Basic/Stats/chicken_entity_desc.tres',
    stats_dir: 'res://02_Entities/Pool/Mobs/Chickens/Basic/Stats/'
  },
  { id: 'ChickenArdentCelestial', aa: 'RANGED' },
  { id: 'ChickenAttack', aa: 'RANGED' },
  { id: 'ChickenColossus', aa: 'MELEE' },
  { id: 'ChickenEngineer', aa: 'MELEE' },
  { id: 'ForestDrake', aa: 'RANGED' },
  { id: 'SmallTreant', aa: 'MELEE' },
  { id: 'IceGolem', aa: 'MELEE' },
  { id: 'MoltenGolem', aa: 'MELEE' },
  { id: 'PoisonGolem', aa: 'MELEE' },
  { id: 'KoboldKnight', aa: 'MELEE' },
  { id: 'KoboldThief', aa: 'MELEE' },
  { id: 'KoboldWarrior', aa: 'MELEE' },
  { id: 'Phoenix', aa: 'MELEE' },
  { id: 'PhoenixEgg', aa: 'MELEE' },
  { id: 'SatyrBerserker', aa: 'MELEE' },
  { id: 'Vrock', aa: 'MELEE' },
  { id: 'SkeletonDragon', aa: 'RANGED' },
  { id: 'AegisTower', aa: 'MELEE' },
  { id: 'ChickenCoop', aa: 'MELEE' },
  { id: 'Sentinelle', aa: 'MELEE' },
  { id: 'FireThrower', aa: 'MELEE' },
  { id: 'GammaTurret', aa: 'RANGED' }
];


function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Godot Tools')
    .addItem('Exporter les stats (JSON)', 'showStatsJson')
    .addItem('Préparer le schéma + entités', 'setupGodotSchema')
    .addToUi();
}


// ============================== Export JSON ==============================

function showStatsJson() {
  var json = buildStatsJson();
  var html = HtmlService
    .createHtmlOutput("<textarea style='width:100%; height:420px;'>" + escapeHtml_(json) + "</textarea>")
    .setWidth(640)
    .setHeight(520);
  SpreadsheetApp.getUi().showModalDialog(html, 'Export JSON — coller dans stats.json');
}

function buildStatsJson() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var rows = sheet.getDataRange().getValues();

  var headerIndex = findHeaderRow_(rows);
  if (headerIndex < 0) {
    throw new Error("En-tête introuvable : aucune ligne ne commence par 'entity_id'.");
  }

  var headers = rows[headerIndex];
  var lastSeen = {};
  var data = [];

  for (var i = headerIndex + 1; i < rows.length; i++) {
    var row = rows[i];
    var record = {};
    var hasStat = false;

    for (var j = 0; j < headers.length; j++) {
      var header = String(headers[j]).trim();
      if (!header) continue;
      var value = row[j];

      if (FORWARD_FILL.indexOf(header) !== -1) {
        if (value === '' || value === null) {
          value = (header in lastSeen) ? lastSeen[header] : '';
        } else {
          lastSeen[header] = value;
        }
      }

      if (value === '' || value === null) continue;

      if (header.indexOf('.') > -1) {
        var parts = header.split('.');
        if (!record[parts[0]]) record[parts[0]] = {};
        record[parts[0]][parts[1]] = value;
      } else {
        record[header] = value;
      }

      if (header !== 'entity_id' && FORWARD_FILL.indexOf(header) === -1) hasStat = true;
    }

    if (record['entity_id'] && hasStat) data.push(record);
  }

  return JSON.stringify(data, null, 2);
}


// ============================== Migration du schéma ==============================

function setupGodotSchema() {
  var ui = SpreadsheetApp.getUi();
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var headerRow = findHeaderRow_(sheet.getDataRange().getValues());
  if (headerRow < 0) {
    ui.alert("En-tête introuvable : la colonne A doit contenir 'entity_id' ou 'hero_id'.");
    return;
  }

  var report = [];
  renameInHeader_(sheet, headerRow, 'hero_id', 'entity_id', report);
  renameGroups_(sheet, headerRow, report);
  renameColumns_(sheet, headerRow, report);
  collapseCritResistances_(sheet, headerRow, report);
  addMissingColumns_(sheet, headerRow, report);
  ensureEntityRows_(sheet, headerRow, report);

  ui.alert(
    'Schéma préparé :\n\n' + (report.length ? report.join('\n') : 'Rien à changer.') +
    "\n\nÀ faire à la main : régler les lignes de formule des nouvelles colonnes, " +
    "remplir les stats des entités ajoutées (lignes lvl 1), et supprimer les " +
    "anciennes colonnes crit_resistances.* (l'importeur les ignore)."
  );
}

function renameInHeader_(sheet, headerRow, oldName, newName, report) {
  var headers = sheet.getDataRange().getValues()[headerRow];
  if (headers.indexOf(newName) !== -1) return;
  var col = headers.indexOf(oldName);
  if (col === -1) return;
  sheet.getRange(headerRow + 1, col + 1).setValue(newName);
  report.push(oldName + ' -> ' + newName);
}

function renameGroups_(sheet, headerRow, report) {
  var headers = sheet.getDataRange().getValues()[headerRow];
  for (var i = 0; i < headers.length; i++) {
    var h = String(headers[i]).trim();
    var dot = h.indexOf('.');
    if (dot <= 0) continue;
    var grp = h.substring(0, dot);
    if (GROUP_RENAMES[grp]) {
      var nh = GROUP_RENAMES[grp] + h.substring(dot);
      sheet.getRange(headerRow + 1, i + 1).setValue(nh);
      report.push(h + ' -> ' + nh);
    }
  }
}

// Renomme les colonnes exactes définies dans COLUMN_RENAMES (alias lisibles).
function renameColumns_(sheet, headerRow, report) {
  var headers = sheet.getDataRange().getValues()[headerRow];
  for (var i = 0; i < headers.length; i++) {
    var h = String(headers[i]).trim();
    if (COLUMN_RENAMES[h] && headers.indexOf(COLUMN_RENAMES[h]) === -1) {
      sheet.getRange(headerRow + 1, i + 1).setValue(COLUMN_RENAMES[h]);
      report.push(h + ' -> ' + COLUMN_RENAMES[h]);
    }
  }
}

// Collapse non-destructif : la 1re colonne crit_resistances.* devient
// crit_resistance ; les autres sont laissées (à supprimer à la main).
function collapseCritResistances_(sheet, headerRow, report) {
  var headers = sheet.getDataRange().getValues()[headerRow];
  if (headers.indexOf('crit_resistance') !== -1) return;
  for (var i = 0; i < headers.length; i++) {
    if (String(headers[i]).trim().indexOf('crit_resistances.') === 0) {
      sheet.getRange(headerRow + 1, i + 1).setValue('crit_resistance');
      report.push(headers[i] + ' -> crit_resistance (collapse)');
      return;
    }
  }
}

function addMissingColumns_(sheet, headerRow, report) {
  var headers = sheet.getDataRange().getValues()[headerRow];
  var existing = {};
  for (var i = 0; i < headers.length; i++) existing[String(headers[i]).trim()] = true;
  for (var n = 0; n < REQUIRED_COLUMNS.length; n++) {
    var name = REQUIRED_COLUMNS[n];
    if (existing[name]) continue;
    var col = sheet.getLastColumn() + 1;
    sheet.getRange(headerRow + 1, col).setValue(name);
    existing[name] = true;
    report.push('+ colonne ' + name);
  }
}

// Ajoute une ligne (lvl 1) par entité absente : entity_id + auto_attack_type
// (+ desc_path/stats_dir/stats_prefix pour les exceptions). Les stats restent
// vides, à remplir avant import.
function ensureEntityRows_(sheet, headerRow, report) {
  var values = sheet.getDataRange().getValues();
  var headers = values[headerRow];
  var idCol = headers.indexOf('entity_id');
  if (idCol === -1) return;

  var present = {};
  for (var i = headerRow + 1; i < values.length; i++) {
    var id = String(values[i][idCol]).trim();
    if (id) present[id] = true;
  }

  var colOf = {};
  for (var c = 0; c < headers.length; c++) colOf[String(headers[c]).trim()] = c;

  var rowIndex = sheet.getLastRow() + 1;
  var added = 0;
  for (var e = 0; e < ENTITIES.length; e++) {
    var ent = ENTITIES[e];
    if (present[ent.id]) continue;

    var rowData = { 'entity_id': ent.id, 'level': 1, 'auto_attack_type': ent.aa };
    if (ent.desc_path) rowData['desc_path'] = ent.desc_path;
    if (ent.stats_dir) rowData['stats_dir'] = ent.stats_dir;
    if (ent.stats_prefix) rowData['stats_prefix'] = ent.stats_prefix;

    for (var key in rowData) {
      if (key in colOf) sheet.getRange(rowIndex, colOf[key] + 1).setValue(rowData[key]);
    }
    rowIndex++;
    added++;
  }
  if (added > 0) report.push('+ ' + added + ' lignes entités (lvl 1)');
}


// ============================== Helpers ==============================

function findHeaderRow_(rows) {
  for (var i = 0; i < rows.length; i++) {
    var a = String(rows[i][0]).trim();
    if (a === 'entity_id' || a === 'hero_id') return i;
  }
  return -1;
}

function escapeHtml_(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

// Réservé à un usage futur en Web App (transport one-click) : déployer puis GET.
function doGet() {
  return ContentService
    .createTextOutput(buildStatsJson())
    .setMimeType(ContentService.MimeType.JSON);
}
