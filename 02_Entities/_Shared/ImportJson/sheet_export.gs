/**
 * Shattered Islands — Outils Google Sheet pour les stats d'entités.
 *
 * À coller dans l'éditeur Apps Script de la Sheet (Extensions > Apps Script),
 * puis recharger la feuille. Le menu "Godot Tools" propose :
 *   - "Exporter les stats (JSON)"  : génère le JSON à coller dans stats.json.
 *   - "Préparer le schéma + Latika" : migre les colonnes vers le nouveau schéma
 *                                     et ajoute une ligne exemple Latika.
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

// Colonnes meta + Mono qui doivent exister (ajoutées en fin si absentes).
var REQUIRED_COLUMNS = [
  'entity_id', 'desc_path', 'stats_dir', 'stats_prefix',
  'attack_power', 'attack_range', 'movement_speed', 'scale',
  'crit_chance', 'crit_mult', 'dodge', 'lifesteal', 'crit_resistance', 'auto_attack_type'
];

// Valeurs de la ligne exemple Latika (clés = en-têtes). Chiffres réels du lvl 1.
var LATIKA_ROW = {
  'entity_id': 'Latika',
  'level': 1,
  'desc_path': 'res://02_Entities/Pool/Heroes/Latika/latika_desc.tres',
  'stats_dir': 'res://02_Entities/Pool/Heroes/Latika/Stats/',
  'stats_prefix': 'latika',
  'health_max': 1000,
  'mana_max': 100,
  'mana_regen': 2,
  'attack_damage': 25,
  'attack_speed': 0.5,
  'attack_power': 10,
  'attack_range': 5,
  'movement_speed': 5,
  'scale': 1,
  'crit_chance': 5,
  'crit_mult': 100,
  'dodge': 5,
  'lifesteal': 0,
  'crit_resistance': 0,
  'auto_attack_type': 'RANGED'
};


function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Godot Tools')
    .addItem('Exporter les stats (JSON)', 'showStatsJson')
    .addItem('Préparer le schéma + Latika', 'setupGodotSchema')
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
  collapseCritResistances_(sheet, headerRow, report);
  addMissingColumns_(sheet, headerRow, report);
  ensureLatikaRow_(sheet, headerRow, report);

  ui.alert(
    'Schéma préparé :\n\n' + (report.length ? report.join('\n') : 'Rien à changer.') +
    "\n\nÀ faire à la main : régler les lignes de formule des nouvelles colonnes, " +
    "et supprimer les anciennes colonnes crit_resistances.* (l'importeur les ignore)."
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

function ensureLatikaRow_(sheet, headerRow, report) {
  var values = sheet.getDataRange().getValues();
  var headers = values[headerRow];
  var idCol = headers.indexOf('entity_id');
  if (idCol === -1) return;

  for (var i = headerRow + 1; i < values.length; i++) {
    if (String(values[i][idCol]).trim() === 'Latika') return; // déjà présente
  }

  var rowIndex = sheet.getLastRow() + 1;
  for (var c = 0; c < headers.length; c++) {
    var key = String(headers[c]).trim();
    if (key in LATIKA_ROW) {
      sheet.getRange(rowIndex, c + 1).setValue(LATIKA_ROW[key]);
    }
  }
  report.push('+ ligne exemple Latika (lvl 1)');
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
