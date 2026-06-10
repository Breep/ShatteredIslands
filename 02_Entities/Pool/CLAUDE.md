# Pool — Comment créer une entité

## Vue d'ensemble

`Pool/` rassemble toutes les entités jouables ou spawnables, classées
par catégorie haut-niveau :

```
Pool/
├── Heroes/      → héros jouables             (Category.HERO)
├── Mobs/        → mobs de combat & summons   (Category.MOB / SUMMON / ACOLYTE / ANTAGONIST)
├── Buildings/   → tourelles, structures      (Category.BUILDING)
└── NPCs/        → PNJ (taverne et autres lieux), pas d'Entity, juste visuels
```

Une entité = un dossier dédié. Code de base dans
`02_Entities/entity.gd` (`class_name Entity extends CharacterBody3D`).

---

## Structure d'un dossier d'entité

```
Mobs/Forest/ForestDrake/
├── forest_drake.gd                # class_name ForestDrake extends Entity (corps vide)
├── forest_drake.tscn              # scène runtime (visuel + logique)
├── forest_drake_visual.tscn       # visuel pur (mesh + AnimationPlayer)
├── forest_drake_preview.tscn      # héros uniquement (visuel + script présentation)
└── Stats/
	├── entity_desc.tres           # EntityDesc agrégeant les stats
	├── forest_drake_builder.tres  # EntityStatsBuilder (bootstrap)
	└── stats_lvl_01.tres … stats_lvl_20.tres
```

Optionnels :
- `Data/` — textures, portraits, FBX bruts
- `Skills/` — icônes SVG par tier (Bronze/Silver/Gold/Passive/Ultimate),
  pour héros et élites
- `VFX/` — VFX propres à l'entité
- `Skins/` — variantes visuelles (cf. `DarkKnight/Skins/Standard/`)
- `<name>_animation_tree.res` — AnimationTree partagé

---

## Structure d'une scène d'entité (`<name>.tscn`)

```
Root  (CharacterBody3D, script <name>.gd, category posée ici)
├── Visuel              ← instance de <name>_visual.tscn
│   ├── HealthBarMarker      (Marker3D, au-dessus de la tête)
│   └── ProjectileSpawnMarker (Marker3D, point de spawn projectile AA —
│                              peut être attaché à un os du visuel)
├── CollisionShape      (Layer = Entity, Mask = Entity / Wall / Floor)
├── AnimationTree       (par défaut, dupliquer
│                        res://02_Entities/_Shared/Animations/default_animation_tree.res)
├── AnimationComponent  (par défaut, instancier
│                        res://02_Entities/_Shared/Components/Animation/animation_component.tscn)
└── HealthBarComponent
```

Notes :
- Les markers vivent **dans** le Visuel pour suivre les animations / bones.
- Pour des besoins d'animation spécifiques, créer un nouveau
  `animation_component` héritant de `AnimationComponent`.
- Propriétés à renseigner sur Root : `entity_name`, `category`,
  `entity_desc`, `_visual_3d`, `_health_bar_marker`,
  `_attack_spawn_marker`, `_projectile_type`.

---

## Les trois scènes — `.tscn` vs `_visual.tscn` vs `_preview.tscn`

| Scène                 | Contient                                              | Rôle |
|-----------------------|-------------------------------------------------------|------|
| `<name>_visual.tscn`  | mesh + AnimationPlayer uniquement                     | Brique partagée, aucune logique. La "peau" de l'entité. |
| `<name>.tscn`         | `_visual` + script Entity + composants combat         | Scène runtime de combat. |
| `<name>_preview.tscn` | `_visual` + script de présentation (anims, sons)      | Écrans de sélection/présentation. Pas d'Entity, pas de stats. |

Cette séparation rend le visuel réutilisable et garde les écrans de
présentation légers.

---

## Stats — bootstrap via EntityStatsBuilder

⚠️ **`EntityStatsBuilder` n'est qu'un outil de bootstrap.** Il sert à
générer un premier set de stats pour tester rapidement une nouvelle
entité. **Une fois en place, les stats sont gérées en externe**

Workflow bootstrap :
1. Créer `Stats/<name>_stat_builder.tres` (script
   `10_Tool/EntityStatsBuilder/`)
2. Renseigner `output_dir`, `entity_name`, growth rules par stat,
   `desc_type = HERO` si héros
3. Cliquer "Generate" → produit N `stats_lvl_NN.tres` + 1 `*_desc.tres`

Après ce passage, le builder reste dans le dossier mais n'est plus
source de vérité.

---

## Pattern de code — unique

**95% des entités ont leur corps de classe vide.** Tout passe par les
composants (préfabriqués par `Entity`) et les skills (ressources
externes).

```gdscript
class_name ForestDrake
extends Entity
```

Signaux d'alarme legacy à virer si rencontrés :
- `func init(...)` paramétré pour passer des stats au spawn
- `category = Category.XXX` posé dans `_init()` / `_ready()`
- `@export` de constantes de skill sur le script (ancien `dark_knight.gd`)
- `_register_<skill>()` privé dans le script entité

→ Tout ça migre vers `EntityDesc` / scène / skills.

### Les 5% restants

Acceptables quand ni un composant ni un skill ne couvre le besoin :
- classe de base "marker" partagée par plusieurs variantes
  (`Chicken` → `ChickenBasic`, `ChickenGifted`, …) factorisant un helper
- signal métier propre à l'entité qu'on veut exposer

---

## Skills — création

Un skill se construit **comme une carte** : mêmes briques (modifiers,
callbacks, effets), même unicité par `id`
(cf. `_Shared/Modifiers/CLAUDE.md`).

**Différence avec une carte** : un skill est lié à une entité connue, il
peut donc se permettre de taper dans une variable spécifique du monstre
si nécessaire. **Préférer quand même le générique** — un skill écrit en
briques génériques est réutilisable, testable en isolation, et robuste
au refacto.

→ *Commence générique. Ne descends dans le spécifique que si le gameplay
l'exige.*

### Héros vs autres mobs

Gestion **identique** pour tous (héros, mobs, summons, buildings) :
skills = ressources externes attachées à l'`EntityDesc`. Pas d'`@export`
de constantes ni de `_register_<skill>()` dans le script entité.

Seule différence, purement quantitative :
- héros : **2 skills par tier** (Bronze1+Bronze2, Silver1+Silver2,
  Gold1+Gold2) + Passive + Ultimate
- autres : **1 skill par tier**

---

## Categories

`category` (enum `Entity.Category`) est toujours **posée via `@export`
sur la scène**, jamais dans le code. C'est ce que consomme
`Entity._ready()` pour brancher les chaînes d'héritage de modifiers
(SUMMON / ACOLYTE / BUILDING).

---

## Composants & registries fournis par Entity

`Entity` instancie déjà tout dans `_init()` / `_enter_tree()`. Dans le
pattern cible (corps vide), on ne les touche pas depuis le script entité :
ce sont les **skills** et la **scène** qui les peuplent.

Composants : `damage`, `heal`, `projectile`, `spell`, `summon`,
`auto_attack`, `alterations`, `target`, `movement`, `label_popup`,
`animation`, `spawn`, `despawn`, `clickable`, `draggable`, `controller`,
`deck_holder`, `family`, `mana`, `health_bar`, `progression`, `skill`.

Registries : `auto_attack_modifier_registry`, `action_modifiers_registry`,
`stat_modifiers_registry`, `death_modifiers_registry`,
`battle_callback_registry`, `summon_modifiers_registry`,
`acolyte_modifiers_registry`, `building_modifiers_registry`,
`projectile_modifiers_registry`.

---

## Conventions de nommage

- Dossier entité : **PascalCase** (`DarkKnight`, `ChickenAttack`)
- Fichier `.gd` / `.tscn` : **snake_case** (`dark_knight.tscn`)
- `class_name` : **PascalCase**
- Membres privés : préfixe `_`
- Signaux : verbe au passé (`spawn_completed`, `fight_is_won`)

---

## Checklist : ajouter une nouvelle entité

1. Créer `Pool/<Category>/<EntityName>/`
2. `<entity_name>.gd` : `class_name X extends Entity` (corps vide)
3. `<entity_name>_visual.tscn` : mesh + AnimationPlayer, rien d'autre
4. `<entity_name>.tscn` selon la structure de la section "Structure d'une
   scène d'entité" — renseigner `entity_name`, `category`, `entity_desc`,
   markers et `_projectile_type` dans l'inspecteur
5. **Résolution de spawn** (lue par `EntityDesc.resolve_scene`) :
   - non-héros : poser `scene_path` sur le `*_desc.tres` → chemin du
     `<entity_name>.tscn`. Source de vérité unique, rien à enregistrer
     ailleurs.
   - **héros** : `<entity_name>_preview.tscn`, entrée dans
     `HeroDesc.HeroId` + `Shared.HERO_SCENES`
6. Bootstrap stats : `Stats/<entity_name>_stat_builder.tres` → Generate
7. Tester en isolation (proto scene si comportement visible, cf. règle
   `*.proto.tscn` du CLAUDE.md racine)
8. Skills éventuels : écrits comme des cartes, briques génériques
   (cf. section "Skills — création")
