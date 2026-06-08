# Projectiles — Mémoire du dossier

## Qu'est-ce qu'un projectile

Un projectile est une `Area3D` qui se déplace, en général, d'un point A à
un point B selon une trajectoire. Il est **uniquement porteur de
callbacks** — toute la logique de jeu (dégâts, statuts, effets) vit dans
les callbacks préparées par l'émetteur, pas dans le projectile lui-même.

Cf. `projectile.gd` (`class_name Projectile extends Area3D`).

## Ce que porte un projectile

Un projectile transporte uniquement :

- ses **callbacks** `on_spawn` et `on_hit` (via `ProjectileStats`, bakées
  par le composant émetteur — cf.
  `ProjectileComponent.projectile_attack`)
- sa **speed**
- son **bounce** (nombre de rebonds restants)
- son **level** (cf. section [Level](#level))
- son **source_id** (`StringName`, attribution des actions
  damage/alterations émises par le projectile — typiquement `card_name`)

Pas de damage, pas de type d'effet en propre — tout passe par les
callbacks.

### Bounce flottant

`bounces_remaining` est un **flottant**, pas un entier. La partie entière
définit le nombre de rebonds garantis, la partie décimale est la
probabilité d'un rebond supplémentaire.

Exemple : `3.7` bounces →
- 3 rebonds garantis
- puis 70 % de chance d'un 4ᵉ rebond

## Classification (3 axes)

Chaque projectile est classé selon trois axes indépendants, exposés en
`@export` sur sa scène :

| Axe | Valeurs | Exemples |
|---|---|---|
| **Type** | `Projectile.Type` | `POISON_FLASK`, `FIRE_BALL`, `SHADOW_BOLT`, … |
| **Category** | `Projectile.Category` | `ABILITY_PROJECTILE`, `AUTO_ATTACK_PROJECTILE` |
| **Size** | `Projectile.Size` | `SMALL`, `BIG` |

Ces axes sont utilisés par les `ProjectileModifier` pour cibler le bon
sous-ensemble de projectiles (cf. `ProjectileModifier.filter_meta`).

## Level

Chaque projectile a un **level entier**, borné à
`[1, Projectile.MAX_LEVEL]` (= **1..10**). Le level détermine quelle valeur
est lue dans les `Array @export` par-level déclarés par la sous-classe
(damage, hit_radius, vulnerability_stacks, …).

### Déclaration côté projectile

La sous-classe expose ses variables par-level comme des `Array @export`,
puis lit la valeur du level courant via `Projectile.value_at_level()` :

```gdscript
class_name Grenade
extends Projectile

@export var _damage: Array[float] = []
@export var _hit_radius: Array[float] = []

func _aoe_explosion(cb_vars: Dictionary) -> void:
    var damage: float = value_at_level(_damage, level, 0.0)
    var hit_radius: float = value_at_level(_hit_radius, level, 0.0)
    # ...
```

`value_at_level(arr, lvl, default)` clampe l'index dans les bornes de
l'array : un projectile peut déclarer moins de 10 entrées sans crasher,
le dernier index est simplement répété au-delà.

Les valeurs par-level sont **renseignées dans le `.tscn` du projectile**
(éditeur Godot ou directement dans le fichier `.tscn`).

### Résolution au spawn

Le level est calculé par `ProjectileComponent` au moment du
`projectile_attack()`, à partir des `ProjectileModifier` qui matchent le
type/category du projectile :

1. Base : `level = 1`
2. Chaque modifier matché peut muter le level via son
   `level_modifier_callback` (`cb_vars[LevelResolver.LEVEL] += N`)
3. Résultat clampé dans `[1, MAX_LEVEL]`
4. Stocké dans `ProjectileStats.level`, lu par `Projectile.init()`

### Comment une carte boost un level

Une carte ou skill qui lance un projectile **n'embarque plus** ses propres
variables damage/radius/etc. — elle se contente de :

1. **Registrer un `ProjectileModifier`** filtré sur le type cible, avec
   un `level_modifier_callback` qui ajoute son bonus
2. **Tirer le projectile** normalement via
   `owner.projectile.projectile_attack(...)`

Exemple (cf. `engineer_electric_grenade.gd`) :

```gdscript
var mod := ProjectileModifier.new()
mod.id = card_name
mod.types = [Projectile.Type.GRENADE]
var level_bonus := card_lvl - 1
mod.level_modifier_callback = func(cb_vars: Dictionary) -> void:
    cb_vars[LevelResolver.LEVEL] += level_bonus
owner.projectile_modifiers_registry.register_modifier(mod)
```

Les bonus de plusieurs cartes **se cumulent** : une carte "+2 grenade lvl"
combinée à une grenade lvl 3 tire au lvl 5 (toujours clampé à 10).

## Comportement par défaut

Chaque projectile a son **comportement par défaut hardcodé dans le corps
de sa propre classe**, qui consomme les valeurs `@export` par-level
(section [Level](#level)).

**Règle** : ce comportement par défaut doit, autant que possible,
utiliser la mécanique de `ProjectileStats` (callbacks `on_spawn` /
`on_hit`), au lieu de fonctions ad-hoc dans la classe. Cela garde
l'invariant "un projectile = un vecteur de callbacks", peu importe d'où
il vient.

Exemple de référence : `grenade.gd` — auto-register son `_aoe_explosion`
comme `on_hit_callback` dans `_ready()`, et lit `_damage`,
`_vulnerability_stacks`, `_hit_radius` via `value_at_level()`.

## Organisation des dossiers

Chaque projectile a **son propre dossier**, rangé par category :

```
03_SpellsAndProjectiles/Projectiles/
├── Abilities/
│   └── <NomProjectile>/
│       ├── <projectile>.tscn
│       ├── <projectile>_visual.tscn
│       ├── VFX/    (au besoin)
│       └── SFX/    (au besoin)
├── AutoAttacks/
│   └── (même structure)
└── _Shared/
	├── projectile_stats.gd
	└── Trajectories/
```

## Structure de la scène

```
<projectile>.tscn  (Root, extends Projectile)
├── CollisionShape3D
└── Visual  (instance de <projectile>_visual.tscn)
```

## Setup dans l'éditeur

En plus du code, il faut régler **dans l'éditeur** sur le nœud racine
du `.tscn` :

| Paramètre | Note |
|---|---|
| `trajectory` | Resource à choisir dans `res://03_SpellsAndProjectiles/Projectiles/_Shared/Trajectories/` (Straight, Arc, Bezier, Boomerang, Homing, Zigzag) |
| `lifetime_max` | Temps (secondes) après lequel le projectile s'autodétruit s'il n'a rien touché |
| `type` | Cf. axe Type ci-dessus |
| `size` | Cf. axe Size ci-dessus |
| `category` | Cf. axe Category ci-dessus |
| `Array @export par-level` | Variables propres à la sous-classe (damage, hit_radius, …), une entrée par level. Idéalement 10 entrées pour couvrir tout le range `[1, MAX_LEVEL]` — moins est toléré (le dernier index est répété). |
