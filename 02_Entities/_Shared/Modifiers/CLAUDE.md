# Modifiers — Mémoire du dossier

## Rôle dans le jeu

Les **modifiers** sont le moyen générique de modifier le comportement
d'une entité, d'un projectile ou d'un spell. Toute carte, skill, quête,
event ou family qui altère le comportement de jeu passe par un modifier
(cf. `Modifier.TagType` : CARD, SKILL, QUEST, EVENT, FAMILY).

La classe de base est `modifier.gd` (`class_name Modifier extends Resource`).
Elle porte uniquement l'identité commune (`id`, `tags`) et oblige les
sous-classes à override `clone()`.

## Principe : identification par `id`

Chaque modifier est enregistré dans un registry avec un `id` (StringName).
Cet `id` est la clé d'unicité : si on enregistre un modifier avec un `id`
déjà présent, **le modifier existant est remplacé** (pas cumulé).

Exemple :
- on enregistre un `StatModifier` `id = "truc"` avec `+100 HP`
- on enregistre un autre `StatModifier` `id = "truc"` avec `+150 HP`
- l'entité aura `+150 HP` (le `+100 HP` est écrasé, pas additionné)

Ce pattern permet de re-pousser le même modifier sans risque de
double-application (idempotence), et permet aux upgrades de carte
de remplacer proprement la version précédente.

## Les différents types de modifiers

### StatModifier
Modifie la `EntityStats` d'une entité (vie, mana, ad, crit chance, etc.).

Les stats finales sont calculées à partir d'une stat de base (lue dans
l'`EntityDesc` en fonction du niveau, bypassable en prototyping via
`stats_override`), à laquelle les `StatModifier` du registry sont
appliqués.

### ActionModifier
Ajoute des comportements à certaines actions atomiques d'une entité
(cf. `Utils.ActionType`).

Exemples :
- 20% de chance d'infliger +5 poison quand on inflige un dégât magique
- 10% de chance de spawn un poulet quand on applique du poison

### AutoAttackModifier
Modifie le comportement d'une auto-attaque.

**Rappel d'architecture importante** : dans ce projet, les projectiles
ne sont que des vecteurs de callback. Ils ne portent **aucune
information de dégât en eux-mêmes**. Tout est résolu dans les callbacks
préparées côté émetteur.

Le flux de l'auto-attaque (cf. `AutoAttackComponent._prepare_projectile_stats()`) :
1. Construction de la callback principale, qui sera appelée en premier
   quand le projectile touche sa cible (ou immédiatement pour le melee).
2. Dans cette callback :
   - parcours de TOUS les `damage_modifiers_callback`
	 (calcul classique : bonus flat puis multiplicatifs)
   - application des dégâts à la cible
   - récupération des dégâts **réellement infligés**
   - parcours de tous les `additional_effect_callbacks`
	 (qui exploitent les dégâts réellement infligés)

C'est ce pattern qui permet par exemple :
- `+50% dégâts auto-attaque` (damage_modifier_callback multiplicatif)
- `20% des dégâts de l'auto-attaque convertis en stacks de poison`
  (additional_effect_callback basé sur les dégâts réels)

### BattleCallback
Comportements ajoutés à l'entité à des moments précis du combat :
début de combat, fin de combat, pendant le combat (ticks/timers).

Exemples :
- toutes les 5 sec, lance une boule de feu
- en début de combat, distribue 500 shield à toute son équipe

### ProjectileModifier
Modifie le comportement par défaut des projectiles.

Exemples :
- `+5 stacks de poison` sur tous les petits projectiles
- les projectiles d'abilité exécutent les cibles sous 5% HP max
- 25% de chance de doubler le nombre de projectiles au lancer

### DeathModifier
Modifie le comportement d'une entité à sa mort.

Exemples :
- résurrection
- `+10 HP max` à tous les alliés
- explosion

### SummonModifier (méta-modifier)
Un `SummonModifier` porte en lui **quasiment tous les autres modifiers**
(stats, projectile, action, etc.). C'est un conteneur.

**Mécanisme de propagation** : lorsqu'une entité spawn, elle remonte
la chaîne de summoners. Pour chaque summoner trouvé, elle agrège dans
ses propres modifiers ceux trouvés dans le `summon_modifiers_registry`
du summoner. La remontée continue jusqu'à la racine de la chaîne
(le héros).

Exemple :

```
HéroA (registry: +100 HP summons)
 ├─ Invocateur (registry: +50 HP summons, débloqué au niveau 7)
 │    └─ Squelette  ← collecte [+100, +50] = +150 ✓
 └─ Écureuil       ← collecte [+100] = +100 ✓

HéroB (registry vide)
 └─ Poulailler (registry vide)
	  └─ Poulet    ← collecte [] = 0 ✓
```

Traduit en cartes :
- HéroA : carte1 = `+100 HP aux summons`, carte2 = recrute un Invocateur
  (qui invoque des Squelettes), carte3 = invoque un Écureuil toutes les 10 s
- HéroB : carte4 = recrute un Poulailler (qui invoque des Poulets)

C'est ce mécanisme de remontée qui permet à un buff global (`+100 HP summons`
sur HéroA) de s'appliquer à toute la descendance, y compris les summons
de summons.

## Autres modifiers présents dans le dossier

`AcolyteModifier`, `BuildingModifier`, `HatchModifier` suivent les mêmes
principes (id + clone, registry par owner) appliqués à leurs cibles
spécifiques (acolytes, bâtiments, œufs/hatch).

## Conventions

- Toute sous-classe de `Modifier` **doit override `clone()`**.
  `Resource.duplicate()` ne copie pas les `var` non-`@export`, donc la
  copie profonde est explicite. C'est notamment utilisé par
  `SummonModifiersRegistry.apply_to` pour propager les modifiers sans
  partager d'instance entre le registry source et la cible.
- Les registries vivent à côté des modifiers (`*_modifiers_registry.gd`)
  et portent la logique d'ajout/remplacement par `id`, d'agrégation
  et d'application sur la cible.
