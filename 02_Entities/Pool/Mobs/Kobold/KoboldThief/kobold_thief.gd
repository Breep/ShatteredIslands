class_name KoboldThief
extends Entity

# Assassin furtif. La furtivité (état UNTARGETABLE) est gérée ici de façon centralisée :
# on entre en furtivité via enter_stealth(), et toute auto-attaque la rompt (reveal()).
# Les skills (Skills/) déclenchent l'entrée en furtivité (passif / Disparition) et lisent
# les metas DISPARITION_META / DOS_EXPOSE_META.

const DISPARITION_META := &"kobold_thief_disparition"   # bool : T3 actif
const DOS_EXPOSE_META := &"kobold_thief_dos_expose"     # float : bonus dégâts ult vs cible basse vie

var _is_stealthed: bool = false


func _ready() -> void:
	# Toute auto-attaque rompt la furtivité (l'ultimate la rompt via son propre skill).
	auto_attack_completed.connect(func(_attacker: Entity) -> void: reveal())
	super._ready()


## Devient invisible (UNTARGETABLE) : non ciblable par les attaques directes, mais touchable
## par les dégâts de zone déjà lancés (get_targets ne filtre pas l'UNTARGETABLE).
func enter_stealth() -> void:
	if alterations == null:
		return
	if not alterations.has_state(Alteration.Type.UNTARGETABLE):
		alterations.inflict_status(self, Alteration.Type.UNTARGETABLE, 0.0, &"Pas de l'ombre")
	_is_stealthed = true


func reveal() -> void:
	if not _is_stealthed:
		return
	_is_stealthed = false
	if alterations != null:
		alterations.cancel_state(Alteration.Type.UNTARGETABLE)


## À appeler après une attaque/ultimate ayant potentiellement tué : si "Disparition" (T3)
## est actif, redevient invisible et regagne tout son mana.
func notify_kill() -> void:
	if not get_meta(DISPARITION_META, false):
		return
	enter_stealth()
	if stats != null:
		stats.mana = stats.mana_max


func _on_died() -> void:
	super._on_died()
	AudioManager.play_3d("kobold_die_02", global_position)
