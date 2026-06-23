# Components de combat — la norme `direct` / `take` / `apply`

Ce dossier rassemble les components d'`Entity`. Les **components d'action de
combat** — `DamageComponent`, `HealComponent`, `AlterationsComponent` — suivent
tous la même norme à trois couches. Ce document la fige. (Les autres components,
purement présentation/locaux : animation, health_bar, movement, etc., n'y sont
pas soumis.)

## Pourquoi trois couches

Le combat est **host-authoritative + log/replay** : le serveur simule et
**résout** toutes les actions, écrit un `BattleLog` ; le client **ne simule
pas**, il **rejoue** le log. Une action traverse donc trois couches nettes, et
**chaque couche n'a qu'un seul type d'appelant légitime**.

| Couche | Sens | Tourne où | Qui l'appelle |
|---|---|---|---|
| **`direct(target, …)`** | « j'agis sur un **AUTRE** » : pipeline émetteur (power/fragility, crit, action modifiers) → `target.take(…)` | **serveur** | le **gameplay** (skills, cartes, IA, family managers, registries) |
| **`take(value, source, …)`** | « je **REÇOIS** » : résolution défensive (dodge, résistance, invuln, shield/block) → `apply(valeur résolue)` ; **émet l'event loggé** | **serveur** | **uniquement `direct`** (de l'émetteur) |
| **`apply(value, …)`** | « je mute **MON** état », valeur **déjà résolue**, **zéro** check / **zéro** RNG | **partagé** serveur **+** client | **uniquement** : la queue de `take` (serveur) **et** le `BattleReader` (client) |

Mnémo : **direct = sur autrui · take = de quelqu'un · apply = sur soi, sans condition.**

## La règle d'or

> **Le gameplay n'appelle QUE `direct_*`.** Jamais `take_*`, jamais `apply_*`.

- `apply_*` est la **couture interne** serveur↔client. L'appeler depuis un skill
  ou une carte = l'action **n'est pas loguée** → le client ne la rejoue jamais →
  **desync** (l'effet n'existe que chez l'hôte).
- `take_*` est **déclenché par `direct_*`**, jamais à la main.

## Un buff / auto-buff EST une action

« Je gagne 10 Block », « l'allié gagne 10 Thorn », « je deviens intouchable » :
ce sont des **actions sortantes**. On les émet par `direct`, **sur la source**,
avec la cible en argument — pas par une mutation brute sur la cible :

```gdscript
# ❌ AVANT — mutation brute sur la cible, non loguée → desync
ally.alterations.apply_stack(Alteration.Type.BLOCK, block, chicken, &"Petite horde")

# ✅ APRÈS — action émise par la source, loguée + rejouée
chicken.alterations.direct_stack(ally, block, Alteration.Type.BLOCK, &"Petite horde")
```

Le **receiver devient la SOURCE** ; la cible passe en **1ᵉʳ argument**. Un
auto-buff = source et cible identiques : `self.alterations.direct_stack(self, …)`.

### Conséquence assumée (et son corollaire)

Passer un buff par `direct_*` le fait traverser **tout** le pipeline
(power/fragility, crit, action modifiers, puis résistance/dodge/invuln). C'est
voulu : c'est ce qui le fait **loguer et rejouer**. En contrepartie, les
*action types* de buff (`BLOCK`, `DEFENSE`, `SHIELD`, `THORN`, `STRENGTH`,
`REGEN`, `VULNERABILITY`…) doivent être **neutres** dans le pipeline : pas de
crit, pas de dodge, power = 1 — sinon un buff pourrait crit ou être esquivé.
**La neutralité se règle dans la config d'action type, jamais via un bypass.**

## Déclinaison par component

- **`DamageComponent`** : `direct` / `direct_percent` → `take` / `take_percent` → `apply`.
- **`HealComponent`** : `direct` / `direct_percent` → `take` → `apply`.
- **`AlterationsComponent`** : **un triplet par famille d'effet** :

| Famille | `direct_*` (gameplay) | `take_*` (résolution serveur) | `apply_*` (mutation partagée) |
|---|---|---|---|
| Stack | `direct_stack` | `take_stack` | `apply_stack` (delta signé : `> 0` ajoute, `< 0` retire) |
| Status | `direct_status` | `take_status` | `apply_status` (dispatcher timed/state) |
| Cleanse | `direct_cleanse` | `take_cleanse` | *(à extraire)* |
| Dispell | `direct_dispell` | `take_dispell` | *(à extraire)* |

`apply_timed` / `apply_state` sont **privés** (`_apply_timed` / `_apply_state`) :
la seule couche apply publique des statuts est `apply_status`.

## Gaps connus (à traiter dans la passe résoudre/appliquer)

Quelques sites appellent encore `apply_*` depuis le gameplay parce que le modèle
à 3 fonctions ne les couvre pas encore. Ils sont **identifiés et tolérés**, pas
un feu vert pour en créer d'autres :

1. **Retrait de SES PROPRES stacks** (shed / consume) — ex.
   `SkeletonDragon/Skills/Bronze/shockwave.gd` (`_shed_debuffs`). Il n'existe pas
   de primitive « direct-removal de soi » : reste en `apply_stack(delta < 0)`.
2. **Buff d'équipement persistant modélisé en stacks de combat** — ex.
   `Cards/Colossus/Rare/Provocation` (DEFENSE accordée/retirée en `apply`/`revert`).
   Ça devrait être un `StatModifier` (id-keyé, idempotent, revert propre), pas un
   stack de combat. Laissé tel quel en attendant la migration.
3. **`apply_cleanse` / `apply_dispell` pas encore extraits** : `take_cleanse` /
   `take_dispell` font encore résolution **et** application, et tirent au
   `randi()` non seedé hors garde serveur → desync à corriger.
4. **Côté client**, le `BattleReader` appelle encore `take_*` (devrait être
   `apply_*`). À basculer quand le reader sera l'unique source d'application
   client.
