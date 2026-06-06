# Pool de cartes — Comment créer une carte

Ce dossier contient **toutes les cartes du jeu**. Ce document explique la
recette complète pour en créer une nouvelle. Le vocabulaire général (Famille,
Alteration, Action…) est défini dans le `CLAUDE.md` racine.

> **Signatures décrites ici = cible de la migration.** Le code vivant
> (`01_Cards/Templates/card_effect.gd`, `card.gd`) utilise encore l'API legacy
> `apply_card(ctx, card_lvl)` / `revert_card(ctx, card_lvl)` avec le nom de carte
> **hardcodé** dans chaque effet. Voir l'encadré [État actuel vs cible](#état-actuel-vs-cible)
> en bas. Écris les nouvelles cartes avec l'API cible.

---

## 1. Ce qu'est une carte

Une carte est une **`Resource` Godot sérialisable** (`.tres`) basée sur
`card.gd`. Elle porte une identité de design (`name`), une rareté, une (des)
famille(s), et un **effet** (`CardEffect`) qui contient le code appliqué au
héros porteur.

## 2. Où enregistrer la carte

```
01_Cards/Pool/Cards/<Famille>/<Rareté>/<NomCarte>/
	<famille>_<nom_carte>.gd      # le CardEffect (le code)
	<famille>_<nom_carte>.tres    # la ressource Card (les données)
	portrait_<nom_carte>.png      # l'illustration
```

Le rangement se fait **par famille puis par rareté**.

- **Dossiers familles** : `ArdentCelestial`, `ChickenLord`, `Colossus`,
  `Engineer`, `Light`, `Necro`, `Poison`, `StormCaller`, `Warrior`
- **Dossiers raretés** : `Common`, `Rare`, `Epic`, `Legendary`

### Famille principale (= où ranger une carte multi-famille)

Une carte peut appartenir à plusieurs familles. Elle est **rangée dans le
dossier de sa famille principale**. La notion de « principale » sert
**uniquement au rangement** — elle n'a pas d'effet gameplay.

**Règle : la famille principale est celle de l'événement _consommé_, pas de
l'événement _émis_.**

| Carte | Consomme | Émet | Principale | Secondaire |
|---|---|---|---|---|
| « 10% d'infliger 5 poison quand on inflige de l'ignite » | ignite (Feu) | poison | **Feu** | Poison |
| « 5% d'infliger X ignite quand on inflige du poison » | poison | ignite (Feu) | **Poison** | Feu |

Dans `Card.families`, l'ordre reflète cette hiérarchie : **principale d'abord,
puis secondaires**.

## 3. Les 4 ingrédients d'une carte

| Champ | Où | Note |
|---|---|---|
| **Nom** | `Card.name` (`StringName`) | Identité de design stable. Sert aussi d'`id` pour register les effets (cf. §5). |
| **Familles** | `Card.families` (`Array[Family.Type]`) | Principale d'abord. **À challenger avec la description** : la famille principale doit correspondre à l'événement consommé. |
| **Rareté** | `Card.rarity` (`Card.Rarity`) | `COMMON` / `RARE` / `EPIC` / `LEGENDARY`. Détermine le nombre de niveaux (`RARITY_MAX_LEVEL`). |
| **Description** | `Card.card_effect` (`CardEffect`) | Le code de la carte. Voir §4. |

Le `.tres` est une ressource `Card` qui embarque le `CardEffect` en
sous-ressource. Les valeurs par niveau (dégâts, stacks, période…) sont des
`@export` du `CardEffect`, typiquement des `Array` indexés par niveau.

## 4. Le CardEffect (le code de la carte)

Un `CardEffect` étend `card_effect.gd` et implémente **3 méthodes** :

```gdscript
class_name FamilleNomCarte
extends CardEffect

# @export des valeurs par niveau (Array indexé par card_lvl - 1)

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	# Pose les modifiers / callbacks sur le héros porteur

func revert(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	# Retire EXACTEMENT ce que apply() a posé (miroir)

func get_description(card_lvl: int) -> String:
	# Texte affiché pour ce niveau
```

### Paramètres

- **`ctx: CardContext`** — contexte extérieur à la carte. Voir §5.
- **`card_name: StringName`** — le nom de la carte. Sert d'`id` pour register
  / unregister les effets, **au lieu de hardcoder** des `&"Poison Flask"` un peu
  partout. `apply` et `revert` doivent utiliser **le même** `card_name`.
- **`card_lvl: int`** — niveau de la carte (1..max selon la rareté). Sert à
  **choisir les valeurs** : `_poison_stacks[card_lvl - 1]`, etc.

### Règles

- **Ne pas checker `card_lvl`** dans `apply` / `revert` / `get_description`.
  Le clamp est fait en amont par `Card` (`Card.lvl` est borné à
  `[1, RARITY_MAX_LEVEL[rarity]]`).
- **`revert` est le miroir strict de `apply`** : tout ce que `apply` register,
  `revert` doit l'unregister (même `card_name` comme `id`). Appelé quand la
  carte quitte la main (vente, retrait).
- **Pas de nom hardcodé** : utilise `card_name` comme `id` des modifiers /
  callbacks.

### `Card` appelle l'effet via

```gdscript
Card.apply_effect(ctx: CardContext) -> void     # → card_effect.apply(ctx, name, lvl)
Card.revert_effect(ctx: CardContext) -> void    # → card_effect.revert(ctx, name, lvl)
Card.get_description() -> String                # → card_effect.get_description(lvl)
```

`Card` injecte `name` et `lvl` ; le `CardEffect` n'a jamais à les deviner.

## 5. CardContext

Contexte extérieur à la carte, passé à chaque méthode. Aujourd'hui il expose le
**propriétaire** de la carte et des raccourcis vers ses registres :

```gdscript
ctx.hero: Entity      # le porteur de la carte
ctx.card: Card        # la carte elle-même

# Raccourcis registres (du héros) :
ctx.stat_modifiers        : EntityStatModifiersRegistry
ctx.action_modifiers      : ActionModifiersRegistry
ctx.auto_attack_modifiers : AutoAttackModifierRegistry
ctx.battle_callbacks      : BattleCallbackRegistry
```

Tout le reste de l'entité est accessible via **`ctx.hero`**.

## 6. Comment implémenter — registres puis composants

La **majorité** des cartes s'implémentent avec les **registres** de `Entity` :

| Registre | Accès | Pour |
|---|---|---|
| `AutoAttackModifierRegistry` | `ctx.auto_attack_modifiers` | modifier les auto-attaques |
| `ActionModifiersRegistry` | `ctx.action_modifiers` | réagir aux actions émises/reçues |
| `EntityStatModifiersRegistry` | `ctx.stat_modifiers` | modifier des stats |
| `BattleCallbackRegistry` | `ctx.battle_callbacks` | start/end of fight, timers périodiques, oneshots |
| `DeathModifiersRegistry` | `ctx.hero.death_modifiers_registry` | réagir à la mort (pas de raccourci sur `ctx`) |

Une autre grande partie s'implémente via les **composants** de l'entité
(`ctx.hero.<composant>`) :

```
damage  heal  projectile  spell  summon  auto_attack
alterations  target  movement
```

> **Si une carte ne peut s'implémenter ni par les registres ni par les
> composants ci-dessus → arbitrage du lead dev requis** avant d'inventer une
> nouvelle mécanique.

## 7. Cartes qui améliorent les Summon / Acolytes / Buildings

Pour buffer non pas le porteur mais **ses minions**, on n'écrit pas dans les
registres directs de l'entité (§6) mais dans des **registres dédiés du
porteur**, qui sont **propagés au minion à son spawn** (clone dans les
registres actifs du minion, en remontant la chaîne `summoner`) :

| Cible | Registre sur le porteur (`owner`) |
|---|---|
| Summons | `owner.summon_modifiers_registry` |
| Acolytes | `owner.acolyte_modifiers_registry` |
| Buildings | `owner.building_modifiers_registry` |

Chacun **encapsule les mêmes sous-registres** qu'une `Entity`. On écrit dans le
bon sous-registre selon le type de buff :

| Type de buff | Sous-registre |
|---|---|
| Stat (HP, AD…) | `.stat_modifiers_registry` |
| Effet additionnel d'auto-attaque | `.auto_attack_modifier_registry` |
| Réaction aux actions | `.action_modifiers_registry` |
| Mort | `.death_modifiers_registry` |

> Le pattern est **identique** à un buff sur soi-même (§6) : même `StatModifier`,
> même `AutoAttackModifier`, même `card_name` comme `id`. La seule différence est
> le **registre de destination**. `revert` reste le miroir strict (mêmes
> sous-registres, même `card_name`).

### Exemples

a. **« Tous les summons gagnent +100 HP »** → un `StatModifier` dans
   `owner.summon_modifiers_registry.stat_modifiers_registry`.

b. **« Les acolytes ajoutent +5 poison à leur auto-attaque »** → un
   `AutoAttackModifier` (avec `additional_effect_callback`) dans
   `owner.acolyte_modifiers_registry.auto_attack_modifier_registry`.

c. **« Les buildings et le héros gagnent +5 Thorn »** → Thorn est une
   **alteration : non fonctionnel pour le moment** (voir limites). Les buffs
   **stat** et **effet additionnel** marchent en revanche aussi pour les
   buildings via `owner.building_modifiers_registry.*`.

Exemple de référence complet (acolytes, +40 AD + poison à l'attaque) :
`01_Cards/Pool/Cards/Prototyping/StatAcolyte/card_acolyte_modifier.proto.gd`.

### Limites actuelles
- **Alterations non propagées** : poser une alteration (Thorn…) via ces
  registres ne fonctionne pas encore.
- **BattleCallback non propagé** : `apply_to` clone Stat / Action / AutoAttack /
  Death, mais **pas** `battle_callback_registry` (TODO). Pas de timer périodique
  hérité par les minions pour l'instant.
- **Propagation au spawn** : le clone se fait à l'apparition du minion. Un
  minion déjà vivant ne reçoit pas rétroactivement un modifier ajouté après son
  spawn.

## 8. Exemple complet — « Poison Flask » (cible)

Inflige des stacks de poison à un ennemi aléatoire, périodiquement.
Famille : **Poison** (consomme un timer, émet du poison → mono-famille).

```gdscript
class_name PoisonPoisonFlask
extends CardEffect

@export var _poison_stacks: Array[int]
@export var _period: Array[float]


func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var stacks := _poison_stacks[card_lvl - 1]
	var period := _period[card_lvl - 1]
	owner.battle_callbacks.register_periodic(card_name, period, func() -> void:
		var enemy := owner.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if enemy == null: return
		owner.alterations.inflict_condition_stacks(enemy, stacks, Alteration.Type.POISON, card_name)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	owner.battle_callbacks.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Inflict %d [[POISON_STACK]], every %ss" % [
		_poison_stacks[card_lvl - 1], _period[card_lvl - 1]
	]
```

Points à noter :
- `card_name` sert d'`id` au `register_periodic` **et** au `unregister_all` du
  `revert` — aucun `&"Poison Flask"` hardcodé.
- Aucun check de `card_lvl`.
- Les valeurs par niveau viennent des `@export` (renseignés dans le `.tres`).
- La closure capture `ctx` / `card_name` / `stacks` par référence.

---

## État actuel vs cible

Tant que la migration n'est pas terminée, **le code qui tourne** diffère de la
cible documentée ci-dessus :

| | Cible (ce doc) | Code vivant actuel |
|---|---|---|
| Méthode d'application | `apply(ctx, card_name, card_lvl)` | `apply_card(ctx, card_lvl)` |
| Méthode de retrait | `revert(ctx, card_name, card_lvl)` | `revert_card(ctx, card_lvl)` |
| Nom de carte | passé en paramètre | **hardcodé** (`&"Poison Flask"`) |
| Check `card_lvl` | supprimé | encore présent dans plusieurs cartes |

Migration à faire pour atteindre la cible :
1. `card_effect.gd` : renommer les virtuelles en `apply` / `revert` et ajouter
   le paramètre `card_name: StringName`.
2. `card.gd` : `apply_effect` / `revert_effect` passent `name` à l'effet ; et
   corriger `revert_effect()` qui appelle aujourd'hui `apply_card` au lieu de
   `revert_card` (`card.gd:68`).
3. Réécrire chaque `CardEffect` avec `card_name` au lieu du nom hardcodé, et
   retirer les checks `card_lvl`.
