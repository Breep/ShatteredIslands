class_name CardEffect
extends Resource

## Code d'une carte appliqué au héros porteur. Chaque carte concrète implémente
## apply / revert (miroir strict l'un de l'autre) et get_description. apply/revert
## reçoivent le card_name — id stable servant à register/unregister les modifiers
## et callbacks, au lieu d'un nom hardcodé — et le card_lvl pour choisir les valeurs.
##
## Quatre virtuelles distinctes selon la durée de vie de l'effet :
## - apply : rejoué à CHAQUE spawn du héros (modifiers sur l'Entity qui meurent
##   avec elle). Ré-applique le niveau courant.
## - revert : appelé quand la carte quitte la main (vente, mise en coffre…).
##   Doit défaire tout ce qui survit à un despawn d'Entity (acolytes recrutés,
##   buffs persistants…) ET les modifiers en cours.
## - on_hand_enter : one-shot quand la carte entre dans la main (achat, sortie
##   de coffre). Pour les mutations persistantes (ajout d'acolytes au roaster).
##   N'est PAS rejoué au respawn de l'Entity.
## - on_upgrade : appelé au level-up. Défaut = revert(prev) + apply(new), adapté
##   aux modifiers. Override pour appliquer un delta sans toucher au reste.

@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(_ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	push_warning("[CardEffect] call virtual apply()")


# Retire du héros tout ce que apply a posé (modifiers, callbacks de bataille,
# callbacks/champs de famille) ET tout ce que on_hand_enter a posé en
# persistant (acolytes recrutés, etc.). Appelé quand la carte quitte la main
# (vente, mise en coffre, retrait).
func revert(_ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	push_warning("[CardEffect] call virtual revert()")


# One-shot à l'entrée dans la main (achat ou sortie de coffre). Mutations
# persistantes qui ne doivent PAS être rejouées au respawn de l'Entity (ex.
# ajout d'entries au roaster). Défaut no-op : les cartes "modifier" classiques
# n'ont rien à override ici.
func on_hand_enter(_ctx: CardContext, _card_name: StringName, _card_lvl: int) -> void:
	pass


# Réagit à un level up de la carte. Comportement par défaut suffisant pour la
# majorité des cartes "modifier" : retirer l'ancien niveau et reposer le nouveau
# (revert prev + apply new). Les cartes qui mutent un état persistant doivent
# override pour appliquer un delta (ex. recruter (new_lvl - prev_lvl) acolytes)
# au lieu de tout détruire/recréer.
func on_upgrade(ctx: CardContext, card_name: StringName, prev_lvl: int, new_lvl: int) -> void:
	revert(ctx, card_name, prev_lvl)
	apply(ctx, card_name, new_lvl)


func get_description(_card_lvl: int) -> String:
	push_warning("[CardEffect] call virtual get_description()")
	return ""
