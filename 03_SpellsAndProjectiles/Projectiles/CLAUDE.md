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

## Comportement par défaut

Chaque projectile a son **comportement par défaut hardcodé dans le corps
de sa propre classe**. Pour le moment il n'y a rien — une refacto est
prévue.

**Règle cible** : ce comportement par défaut doit, autant que possible,
utiliser la mécanique de `ProjectileStats` (callbacks `on_spawn` /
`on_hit`), au lieu de fonctions ad-hoc dans la classe. Cela garde
l'invariant "un projectile = un vecteur de callbacks", peu importe d'où
il vient.

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
