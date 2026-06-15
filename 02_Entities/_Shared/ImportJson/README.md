# Import des stats d'entités (Sheet → Godot)

Pipeline pour piloter les stats de **toute entité** (héros, mob, bâtiment...) depuis
une Google Sheet. La Sheet est la **source de vérité** ; Godot ne fait que consommer
l'export.

## Fichiers

| Fichier | Rôle |
|---|---|
| `sheet_export.gs` | Apps Script à coller dans la Sheet (Extensions > Apps Script). Génère le JSON. |
| `stats.json` | Export collé depuis la Sheet. **Commité** → historique git lisible des changements de stats. |
| `import_entity_stats.gd` | `EditorScript` qui lit `stats.json` et régénère les `.tres`. |

## Workflow (transport manuel, "option 3")

1. Éditer les valeurs dans la Sheet.
2. Menu **Godot Tools > Exporter les stats (JSON)** → copier le contenu de la boîte.
3. Coller dans `stats.json` (remplace tout le fichier).
4. Dans Godot : ouvrir `import_entity_stats.gd`, **File > Run** (Maj+Ctrl+X).
5. Vérifier la console : `[ImportStats] <entity> : N niveaux -> <desc>`.

> ⚠️ L'import **remplace intégralement** le dictionnaire `stats` de l'`EntityDesc`.
> Le JSON doit contenir **tous les niveaux** voulus pour chaque entité, sinon les
> niveaux absents sont perdus dans le desc.

## Schéma des colonnes de la Sheet

L'en-tête réel est la ligne dont la 1re cellule vaut `entity_id` (les lignes
meta — type de courbe / Multiplicateur / Variable — au-dessus sont ignorées).

### Colonnes meta (ciblage)
| Colonne | Remplie | Description |
|---|---|---|
| `entity_id` | chaque ligne | Clé de regroupement **et** clé d'auto-résolution (ex: `Latika`, `KoboldKnight`). |
| `level` | chaque ligne | Niveau (entier ≥ 1). |
| `desc_path` | optionnel | `res://...` vers l'`EntityDesc.tres` à mettre à jour. Auto si vide. |
| `stats_dir` | optionnel | `res://...` du dossier où écrire les `.tres`. Auto si vide. |
| `stats_prefix` | optionnel | Préfixe des fichiers. Auto si vide = `<entity_snake>_stats` → `<prefix>_lvl_01.tres`. |

**Auto-résolution** : si `desc_path` / `stats_dir` / `stats_prefix` sont vides,
l'importeur les déduit de `entity_id` :
- `desc_path` : cherche le dossier nommé comme `entity_id` sous `02_Entities/Pool/`,
  puis l'unique resource dont le `script_class` finit par `Desc`
  (dans le dossier ou son sous-dossier `Stats/`).
- `stats_dir` : le dossier du desc s'il s'appelle `Stats`, sinon `<dossier>/Stats/`.
- `stats_prefix` : toujours `<entity_id en snake_case>_stats` (convention unique,
  ex. `kobold_knight_stats`). À l'import, les fichiers de niveau aux anciens noms
  (`stats_lvl_NN.tres`, `latika_lvl_NN.tres`...) sont **supprimés** pour ne garder
  que ce motif.

Repli sur les colonnes explicites quand : le dossier ne porte pas le nom de
l'entité, plusieurs `*Desc` cohabitent, ou l'entité n'existe pas encore sur disque.
Les valeurs explicites sont recopiées vers le bas (forward-fill) : à ne remplir
que sur la 1re ligne de chaque entité.

### Colonnes Mono (une valeur par niveau)
`health_max`, `mana_max`, `mana_regen`, `attack_damage`, `attack_speed`,
`attack_power`, `attack_range`, `movement_speed`, `scale`, `aoe_size`,
`armor`, `magic_resistance`, `poison_resistance`, `crit_chance`,
`crit_mult`, `dodge`, `lifesteal`, `crit_resistance`, `auto_attack_type` (`RANGED` ou `MELEE`).

> `armor` / `magic_resistance` / `poison_resistance` sont des **alias** des 3 slots
> de dégâts de `m_resistances` (PHYSICAL / MAGICAL / POISON) — même donnée en interne.
> N'utilise QUE ces colonnes pour ces 3 slots (pas aussi `m_resistances.DAMAGE_*`,
> ce serait un doublon). Le groupe `m_resistances.*` ne sert plus que pour les
> autres ActionTypes (heal, stacks, status...).

> `crit_resistance` est **une seule colonne** (valeur globale). L'ancien
> `crit_resistances.<ActionType>` par type n'existe plus.

### Colonnes Multi (notation pointée `groupe.ActionType`)
| Groupe (nouveau nom) | Ancien nom Sheet |
|---|---|
| `m_crit_chances` | `critical_chances` |
| `m_crit_mults` | `critical_multipliers` |
| `m_resistances` | `resistances` |
| `m_exposures` | `vulnerabilities` |
| `m_dodges` | `dodges` |
| `m_lifesteals` | `life_steals` |
| `m_powers` | `strength` |
| `m_fragilities` | `weakness` |

`ActionType` valides : `DAMAGE_PHYSICAL`, `DAMAGE_MAGICAL`, `DAMAGE_POISON`,
`DAMAGE_PURE`, `UTILITY_HEAL`, `UTILITY_CLEANSE`, `UTILITY_DISPELL`,
`STACK_SHIELD`, `STACK_IGNITE`, `STACK_POISON`, `STACK_REGEN`, `STACK_NECROSIS`,
`STATUS_STUN`, `STATUS_TAUNT`, `STATUS_SILENCE`, `STATUS_INVULNERABLE`, `STATUS_UNTARGETABLE`.

## Migration des colonnes (automatique)

Le menu **Godot Tools > Préparer le schéma + entités** applique automatiquement,
dans la feuille active (non-destructif, annulable par Ctrl+Z, relançable) :

- `hero_id` → `entity_id` ; ajout de `desc_path`, `stats_dir`, `stats_prefix`.
- Ajout des Mono manquantes : `attack_power`, `attack_range`, `movement_speed`,
  `scale`, `aoe_size`, `crit_chance`, `crit_mult`, `dodge`, `lifesteal`,
  `crit_resistance`, `auto_attack_type` (colonnes ajoutées **en fin de feuille**).
- Renommage des groupes Multi (table ci-dessus).
- Renommage des 3 slots de résistance dégâts : `m_resistances.DAMAGE_PHYSICAL` →
  `armor`, `.DAMAGE_MAGICAL` → `magic_resistance`, `.DAMAGE_POISON` → `poison_resistance`.
- Ajout d'une ligne (lvl 1) par entité absente, avec son `entity_id` et son
  `auto_attack_type` (`ChickenBasic` reçoit en plus son `desc_path` explicite).

Reste à faire à la main :
- Régler les lignes de formule (Multiplicateur / Variable / courbe) des nouvelles
  colonnes ajoutées en fin.
- Supprimer les anciennes colonnes `crit_resistances.*` (collapsées en
  `crit_resistance` ; l'importeur les ignore en attendant).
- Ajouter les `ActionType` manquants si pertinents (`DAMAGE_PURE`, `STATUS_*`...).

## Note

`EntityStatsBuilder` (`10_Tool/EntityStatsBuilder/`) génère des stats par formules
directement dans l'éditeur. Les deux outils coexistent tant que ce pipeline n'est
pas validé.
