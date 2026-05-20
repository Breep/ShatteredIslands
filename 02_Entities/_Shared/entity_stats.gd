# EntityStats — Stats d'une entité, distinction Mono / Multi.
# Mono = valeur unique exposée joueur. Multi (M_*) = valeur par ActionType, interne dev.
# Lookup composite via get_effective_stat ; cf. doc GD Stats.md.
class_name EntityStats
extends Resource

#region ============================== Enum ==============================
enum StatType {
	# --- Mono pure ---
	HEALTH_MAX,
	HEALTH,
	MANA_MAX,
	MANA,
	MANA_REGEN,
	AD,
	AS,
	AP,
	AR,
	MS,
	SCALE,
	CRIT_RESISTANCE,

	# --- Mono avec Multi sœur (lookup composite) ---
	CRIT_CHANCE,
	CRIT_MULT,
	DODGE,
	LIFESTEAL,

	# --- Mono alias vers M_RESISTANCE[action] ---
	ARMOR,
	MAGIC_RESIST,
	POISON_RESIST,

	# --- Multi only ---
	M_POWER,
	M_FRAGILITY,
	M_RESISTANCE,
	M_EXPOSURE,
	M_CRIT_CHANCE,
	M_CRIT_MULT,
	M_DODGE,
	M_LIFESTEAL,
}

enum AutoAttackType {RANGED, MELEE}
#endregion

#region ============================== Constants ==============================
# ActionType auxquels chaque stat Mono "à Multi sœur" se branche au lookup composite.
# Par défaut : les 3 types de dégâts (PHYSICAL, MAGICAL, POISON). À étendre selon design.
const MONO_LINKED_ACTIONS: Dictionary[StatType, Array] = {
	StatType.CRIT_CHANCE: [Utils.ActionType.DAMAGE_PHYSICAL, Utils.ActionType.DAMAGE_MAGICAL, Utils.ActionType.DAMAGE_POISON],
	StatType.CRIT_MULT:   [Utils.ActionType.DAMAGE_PHYSICAL, Utils.ActionType.DAMAGE_MAGICAL, Utils.ActionType.DAMAGE_POISON],
	StatType.DODGE:       [Utils.ActionType.DAMAGE_PHYSICAL, Utils.ActionType.DAMAGE_MAGICAL, Utils.ActionType.DAMAGE_POISON],
	StatType.LIFESTEAL:   [Utils.ActionType.DAMAGE_PHYSICAL, Utils.ActionType.DAMAGE_MAGICAL, Utils.ActionType.DAMAGE_POISON],
}

# Stats Mono "alias" : pointent vers une entrée M_RESISTANCE[action]. Exposition UI joueur.
const RESISTANCE_ALIASES: Dictionary[StatType, Utils.ActionType] = {
	StatType.ARMOR:         Utils.ActionType.DAMAGE_PHYSICAL,
	StatType.MAGIC_RESIST:  Utils.ActionType.DAMAGE_MAGICAL,
	StatType.POISON_RESIST: Utils.ActionType.DAMAGE_POISON,
}
#endregion

#region ============================== Signals ==============================
signal has_been_reset()
#endregion

#region ============================== Health ==============================
signal health_max_changed(new_health_max: float)
var _health_max: float
## HP max de l'entité. Augmenter HP_MAX augmente aussi les HP courants du même montant.
@export var health_max: float:
	get: return _health_max
	set(value):
		if value == _health_max: return
		var old_health_max: float = _health_max
		_health_max = value
		if _health_max > old_health_max: health += _health_max - old_health_max
		else: health = clampf(health, 0, value)
		health_max_changed.emit(_health_max)

signal health_changed(new_health: float)
var _health: float
## HP courants. À 0, l'entité meurt. Clampé entre 0 et health_max.
var health: float:
	get: return _health
	set(value):
		value = clampf(value, 0, health_max)
		if value == _health: return
		_health = value
		health_changed.emit(_health)
#endregion

#region ============================== Mana ==============================
signal mana_max_changed(new_mana_max: float)
var _mana_max: float
## Seuil de mana qui déclenche l'ultimate.
@export var mana_max: float:
	get: return _mana_max
	set(value):
		if value == _mana_max: return
		_mana_max = value
		mana_max_changed.emit(_mana_max)

signal mana_changed(new_mana: float)
var _mana: float
## Mana courant. Quand mana atteint mana_max, l'ultimate se déclenche et mana revient à 0.
var mana: float:
	get: return _mana
	set(value):
		if value == _mana: return
		_mana = value
		mana_changed.emit(_mana)

signal mana_regen_changed(new_mana_regen: float)
var _mana_regen: float
## Régénération de mana par seconde.
@export var mana_regen: float:
	get: return _mana_regen
	set(value):
		if value == _mana_regen: return
		_mana_regen = value
		mana_regen_changed.emit(_mana_regen)
#endregion

#region ============================== Auto-Attack ==============================
## Type d'auto-attaque : RANGED (projectile) ou MELEE (corps-à-corps).
@export var auto_attack_type: AutoAttackType = AutoAttackType.RANGED

signal attack_range_changed(new_attack_range: float)
var _attack_range: float = -1.0 # -1 = unlimited range (default)
## Portée des auto-attaques en mètres. -1 = portée illimitée.
@export var attack_range: float:
	get: return _attack_range
	set(value):
		if value == _attack_range: return
		_attack_range = value
		attack_range_changed.emit(_attack_range)

signal attack_damage_changed(new_attack_damage: float)
var _attack_damage: float
## Attack Damage (AD) : dégâts infligés par auto-attaque. 1 AD = 1 dégât par AA.
@export var attack_damage: float:
	get: return _attack_damage
	set(value):
		if value == _attack_damage: return
		_attack_damage = value
		attack_damage_changed.emit(_attack_damage)

signal attack_speed_changed(new_attack_speed: float)
var _attack_speed: float
## Attack Speed (AS) : nombre d'auto-attaques par seconde. 1 AS = 1 AA/s.
@export var attack_speed: float:
	get: return _attack_speed
	set(value):
		if value == _attack_speed: return
		_attack_speed = value
		attack_speed_changed.emit(_attack_speed)
#endregion

#region ============================== Movement ==============================
signal movement_speed_changed(new_movement_speed: float)
var _movement_speed: float
## Vitesse de déplacement en mètres par seconde.
@export var movement_speed: float:
	get: return _movement_speed
	set(value):
		if value == _movement_speed: return
		_movement_speed = value
		movement_speed_changed.emit(_movement_speed)
#endregion

#region ============================== AP ==============================
signal attack_power_changed(new_attack_power: float)
var _attack_power: float
## Ability Power (AP) : puissance magique scalant les compétences.
@export var attack_power: float:
	get: return _attack_power
	set(value):
		if value == _attack_power: return
		_attack_power = value
		attack_power_changed.emit(_attack_power)
#endregion

#region ============================== Scale ==============================
signal scale_changed(new_scale: float)
var _scale: float = 1.0
## Échelle visuelle de l'entité (1.0 = taille normale).
@export var scale: float:
	get: return _scale
	set(value):
		if value == _scale: return
		_scale = value
		scale_changed.emit(_scale)
#endregion

#region ============================== Protection ==============================
signal crit_resistance_changed(new_crit_resistance: float)
## Réduction de la chance de se faire crit (%). S'applique à toutes les actions.
@export var _crit_resistance: float = 0.0

signal armor_changed(new_armor: float)
## Armure : réduit les dégâts physiques reçus (%). Alias éditeur de m_resistances[DAMAGE_PHYSICAL].
@export var armor: float:
	get: return _m_resistances.get(Utils.ActionType.DAMAGE_PHYSICAL, 0.0)
	set(value):
		_set_m_resistance(Utils.ActionType.DAMAGE_PHYSICAL, value)

signal magic_resistance_changed(new_magic_resistance: float)
## Résistance magique : réduit les dégâts magiques reçus (%). Alias éditeur de m_resistances[DAMAGE_MAGICAL].
@export var magic_resistance: float:
	get: return _m_resistances.get(Utils.ActionType.DAMAGE_MAGICAL, 0.0)
	set(value):
		_set_m_resistance(Utils.ActionType.DAMAGE_MAGICAL, value)

signal poison_resistance_changed(new_poison_resistance: float)
## Résistance au poison : réduit les dégâts de poison reçus (%). Alias éditeur de m_resistances[DAMAGE_POISON].
@export var poison_resistance: float:
	get: return _m_resistances.get(Utils.ActionType.DAMAGE_POISON, 0.0)
	set(value):
		_set_m_resistance(Utils.ActionType.DAMAGE_POISON, value)
#endregion

#region ============================== Mono Crit Chance / Crit Mult / Dodge / Lifesteal ==============================
@export_group("Critic / Dodge / Lifesteal (Mono)")
signal crit_chance_changed(new_crit_chance: float)
## Chance de crit globale (%). S'ajoute à m_crit_chances[action] pour les actions linked (PHYS/MAG/POISON).
@export var _crit_chance: float = 0.0

signal crit_mult_changed(new_crit_mult: float)
## Multiplicateur de crit global (%). S'ajoute à m_crit_mults[action] pour les actions linked.
@export var _crit_mult: float = 100.0

signal dodge_changed(new_dodge: float)
## Chance d'esquiver (%). S'ajoute à m_dodges[action] pour les actions linked.
@export var _dodge: float = 0.0

signal lifesteal_changed(new_lifesteal: float)
## % des dégâts infligés restauré en HP. S'ajoute à m_lifesteals[action] pour les actions linked.
@export var _lifesteal: float = 0.0
#endregion

#region ============================== Multi (m_*) ==============================
@export_group("Multi (per ActionType)")
signal m_crit_chance_changed(new_value: float, action_type: Utils.ActionType)
## Crit chance par ActionType. Pour PHYS/MAG/POISON, s'ajoute à la Mono crit_chance.
@export var _m_crit_chances: Dictionary[Utils.ActionType, float]

signal m_crit_mult_changed(new_value: float, action_type: Utils.ActionType)
## Crit multiplier par ActionType. Pour PHYS/MAG/POISON, s'ajoute à la Mono crit_mult.
@export var _m_crit_mults: Dictionary[Utils.ActionType, float]

signal m_dodge_changed(new_value: float, action_type: Utils.ActionType)
## Dodge par ActionType. Pour PHYS/MAG/POISON, s'ajoute à la Mono dodge.
@export var _m_dodges: Dictionary[Utils.ActionType, float]

signal m_lifesteal_changed(new_value: float, action_type: Utils.ActionType)
## Lifesteal par ActionType. Pour PHYS/MAG/POISON, s'ajoute à la Mono lifesteal.
@export var _m_lifesteals: Dictionary[Utils.ActionType, float]

signal m_power_changed(new_value: float, action_type: Utils.ActionType)
## Multiplicateur d'efficacité émise (Strength). Formule Attaque : v × (100+m_power) / (100+m_fragility).
@export var _m_powers: Dictionary[Utils.ActionType, float]

signal m_fragility_changed(new_value: float, action_type: Utils.ActionType)
## Réducteur d'efficacité émise (Weakness). Formule Attaque : v × (100+m_power) / (100+m_fragility).
@export var _m_fragilities: Dictionary[Utils.ActionType, float]

signal m_resistance_changed(new_value: float, action_type: Utils.ActionType)
## Réduction de valeur reçue par ActionType. Slots DAMAGE_PHYS/MAG/POISON exposés via armor/magic_resistance/poison_resistance.
@export var _m_resistances: Dictionary[Utils.ActionType, float]

signal m_exposure_changed(new_value: float, action_type: Utils.ActionType)
## Augmente la valeur reçue (Vulnerability). Formule Défense : v × (100+m_exposure) / (100+m_resistance).
@export var _m_exposures: Dictionary[Utils.ActionType, float]
#endregion

#region ============================== Public functions ==============================
func reset_from_hero_desc(hero: HeroDesc, lvl: int) -> EntityStats:
	if lvl < 1 or lvl > 10:
		Verbose.error("reset_from_hero_desc() - Invalid hero level [" + str(lvl) + "]", Verbose.Category.ENTITY)
		return self

	var hs: HeroStats = hero.stats[lvl]
	health_max = hs.health_max
	health = health_max
	mana_max = hs.mana_max
	mana = 0
	mana_regen = hs.mana_regen
	attack_damage = hs.attack_damage
	attack_power = hs.attack_power
	attack_speed = hs.attack_speed
	attack_range = hs.attack_range
	movement_speed = hs.movement_speed
	auto_attack_type = hs.auto_attack_type

	_set_crit_chance(hs.crit_chance)
	_set_crit_mult(hs.crit_mult)
	_set_dodge(hs.dodge)
	_set_lifesteal(hs.lifesteal)
	_set_crit_resistance(hs.crit_resistance)

	for action_type: Utils.ActionType in Utils.get_all_actions():
		_set_multi(_m_crit_chances, m_crit_chance_changed, action_type, hs.m_crit_chances.get(action_type, 0.0))
		_set_multi(_m_crit_mults,   m_crit_mult_changed,   action_type, hs.m_crit_mults.get(action_type, 0.0))
		_set_multi(_m_dodges,       m_dodge_changed,       action_type, hs.m_dodges.get(action_type, 0.0))
		_set_multi(_m_lifesteals,   m_lifesteal_changed,   action_type, hs.m_lifesteals.get(action_type, 0.0))
		_set_multi(_m_powers,       m_power_changed,       action_type, hs.m_powers.get(action_type, 0.0))
		_set_multi(_m_fragilities,  m_fragility_changed,   action_type, hs.m_fragilities.get(action_type, 0.0))
		_set_m_resistance(action_type, hs.m_resistances.get(action_type, 0.0))
		_set_multi(_m_exposures,    m_exposure_changed,    action_type, hs.m_exposures.get(action_type, 0.0))

	has_been_reset.emit()
	return self


func reset_from_self() -> EntityStats:
	if health == 0 and health_max > 0:
		health = health_max
	if mana == 0 and mana_max > 0:
		mana = 0
	return self


# Lookup brut : valeur Mono OU valeur Multi[action]. Pour aliases (ARMOR/MR/PR),
# retourne la valeur M_RESISTANCE correspondante.
func get_stat(stat_type: StatType, action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL) -> float:
	# Aliases : redirection vers M_RESISTANCE[action_alias]
	if RESISTANCE_ALIASES.has(stat_type):
		return _m_resistances.get(RESISTANCE_ALIASES[stat_type], 0.0)

	match stat_type:
		StatType.HEALTH_MAX:      return _health_max
		StatType.HEALTH:          return _health
		StatType.MANA_MAX:        return _mana_max
		StatType.MANA:            return _mana
		StatType.MANA_REGEN:      return _mana_regen
		StatType.AD:              return _attack_damage
		StatType.AP:              return _attack_power
		StatType.AS:              return _attack_speed
		StatType.AR:              return _attack_range
		StatType.MS:              return _movement_speed
		StatType.SCALE:           return _scale
		StatType.CRIT_RESISTANCE: return _crit_resistance
		StatType.CRIT_CHANCE:     return _crit_chance
		StatType.CRIT_MULT:       return _crit_mult
		StatType.DODGE:           return _dodge
		StatType.LIFESTEAL:       return _lifesteal
		StatType.M_CRIT_CHANCE:   return _m_crit_chances.get(action_type, 0.0)
		StatType.M_CRIT_MULT:     return _m_crit_mults.get(action_type, 0.0)
		StatType.M_DODGE:         return _m_dodges.get(action_type, 0.0)
		StatType.M_LIFESTEAL:     return _m_lifesteals.get(action_type, 0.0)
		StatType.M_POWER:         return _m_powers.get(action_type, 0.0)
		StatType.M_FRAGILITY:     return _m_fragilities.get(action_type, 0.0)
		StatType.M_RESISTANCE:    return _m_resistances.get(action_type, 0.0)
		StatType.M_EXPOSURE:      return _m_exposures.get(action_type, 0.0)
		_:
			printerr("EntityStats: get_stat() - Unknown stat type [", stat_type, "]")
			return 0.0


# Lookup composite : pour Mono-with-Multi (CRIT_CHANCE/CRIT_MULT/DODGE/LIFESTEAL),
# retourne Mono + Multi[action] si l'action est dans MONO_LINKED_ACTIONS de la stat.
# Pour le reste, identique à get_stat.
func get_effective_stat(stat_type: StatType, action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL) -> float:
	match stat_type:
		StatType.CRIT_CHANCE:
			var multi: float = _m_crit_chances.get(action_type, 0.0)
			return _crit_chance + multi if _is_linked(stat_type, action_type) else multi
		StatType.CRIT_MULT:
			var multi: float = _m_crit_mults.get(action_type, 0.0)
			return _crit_mult + multi if _is_linked(stat_type, action_type) else multi
		StatType.DODGE:
			var multi: float = _m_dodges.get(action_type, 0.0)
			return _dodge + multi if _is_linked(stat_type, action_type) else multi
		StatType.LIFESTEAL:
			var multi: float = _m_lifesteals.get(action_type, 0.0)
			return _lifesteal + multi if _is_linked(stat_type, action_type) else multi
		_:
			return get_stat(stat_type, action_type)


# Setter générique. Pour les aliases, redirige vers M_RESISTANCE[action_alias].
func update_stat(stat_type: StatType, value: float, action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL) -> void:
	# Aliases : redirection vers M_RESISTANCE[action_alias]
	if RESISTANCE_ALIASES.has(stat_type):
		_set_m_resistance(RESISTANCE_ALIASES[stat_type], value)
		return

	match stat_type:
		StatType.HEALTH_MAX:      health_max = value
		StatType.HEALTH:          health = value
		StatType.MANA_MAX:        mana_max = value
		StatType.MANA:            mana = value
		StatType.MANA_REGEN:      mana_regen = value
		StatType.AD:              attack_damage = value
		StatType.AP:              attack_power = value
		StatType.AS:              attack_speed = value
		StatType.AR:              attack_range = value
		StatType.MS:              movement_speed = value
		StatType.SCALE:           scale = value
		StatType.CRIT_RESISTANCE: _set_crit_resistance(value)
		StatType.CRIT_CHANCE:     _set_crit_chance(value)
		StatType.CRIT_MULT:       _set_crit_mult(value)
		StatType.DODGE:           _set_dodge(value)
		StatType.LIFESTEAL:       _set_lifesteal(value)
		StatType.M_CRIT_CHANCE:   _set_multi(_m_crit_chances, m_crit_chance_changed, action_type, value)
		StatType.M_CRIT_MULT:     _set_multi(_m_crit_mults,   m_crit_mult_changed,   action_type, value)
		StatType.M_DODGE:         _set_multi(_m_dodges,       m_dodge_changed,       action_type, value)
		StatType.M_LIFESTEAL:     _set_multi(_m_lifesteals,   m_lifesteal_changed,   action_type, value)
		StatType.M_POWER:         _set_multi(_m_powers,       m_power_changed,       action_type, value)
		StatType.M_FRAGILITY:     _set_multi(_m_fragilities,  m_fragility_changed,   action_type, value)
		StatType.M_RESISTANCE:    _set_m_resistance(action_type, value)
		StatType.M_EXPOSURE:      _set_multi(_m_exposures,    m_exposure_changed,    action_type, value)
		_: printerr("EntityStats: update_stat() - Unknown stat type [", stat_type, "]")


# True si stat_type est stockée par-action (registry l'utilise pour dispatch single/multi).
static func is_multi_stat(stat_type: StatType) -> bool:
	match stat_type:
		StatType.M_CRIT_CHANCE, StatType.M_CRIT_MULT, StatType.M_DODGE, StatType.M_LIFESTEAL, \
		StatType.M_POWER, StatType.M_FRAGILITY, StatType.M_RESISTANCE, StatType.M_EXPOSURE:
			return true
		_:
			return false


# Résout un alias vers (target_stat, action_type). Retourne null si pas un alias.
static func resolve_alias(stat_type: StatType) -> Dictionary:
	if RESISTANCE_ALIASES.has(stat_type):
		return {"stat_type": StatType.M_RESISTANCE, "action_type": RESISTANCE_ALIASES[stat_type]}
	return {}
#endregion

#region ============================== Private functions ==============================
func _is_linked(stat_type: StatType, action_type: Utils.ActionType) -> bool:
	var linked: Array = MONO_LINKED_ACTIONS.get(stat_type, [])
	return action_type in linked


func _set_multi(dict: Dictionary, signal_ref: Signal, action_type: Utils.ActionType, value: float) -> void:
	if dict.get(action_type, null) == value: return
	dict[action_type] = value
	signal_ref.emit(value, action_type)


# Wrapper sur _m_resistances qui émet aussi le signal alias (armor/MR/PR) quand le slot
# correspondant change. Toutes les écritures sur _m_resistances doivent passer par ici.
func _set_m_resistance(action_type: Utils.ActionType, value: float) -> void:
	if _m_resistances.get(action_type, null) == value: return
	_m_resistances[action_type] = value
	m_resistance_changed.emit(value, action_type)
	match action_type:
		Utils.ActionType.DAMAGE_PHYSICAL: armor_changed.emit(value)
		Utils.ActionType.DAMAGE_MAGICAL: magic_resistance_changed.emit(value)
		Utils.ActionType.DAMAGE_POISON: poison_resistance_changed.emit(value)


func _set_crit_chance(value: float) -> void:
	if value == _crit_chance: return
	_crit_chance = value
	crit_chance_changed.emit(value)


func _set_crit_mult(value: float) -> void:
	if value == _crit_mult: return
	_crit_mult = value
	crit_mult_changed.emit(value)


func _set_dodge(value: float) -> void:
	if value == _dodge: return
	_dodge = value
	dodge_changed.emit(value)


func _set_lifesteal(value: float) -> void:
	if value == _lifesteal: return
	_lifesteal = value
	lifesteal_changed.emit(value)


func _set_crit_resistance(value: float) -> void:
	if value == _crit_resistance: return
	_crit_resistance = value
	crit_resistance_changed.emit(value)
#endregion
