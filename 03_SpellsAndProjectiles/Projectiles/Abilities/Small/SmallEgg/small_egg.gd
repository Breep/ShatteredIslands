# SmallEgg — projectile d'abilité à impact unique. À l'impact : dégâts physiques
# (base + nombre d'invocations alliées vivantes × valeur par level) et une chance
# de faire éclore un poussin (Chicken) au point de chute.
class_name SmallEgg
extends Projectile

# === EXPORTS ===
## Chance (%) de faire spawn un chicken à l'impact, par level.
@export var _chicken_chances: Array[float] = []
## Dégâts de base infligés à l'impact (indépendant du level).
@export var _base_damage: float = 1.0
## Dégâts ajoutés par invocation alliée vivante, par level.
@export var _damage_per_summon: Array[float] = []


# === Node base functions ===

func _ready() -> void:
	if _stats != null:
		_stats.on_hit_callbacks.append(_default_hit)
	super._ready()


# === Private functions ===

func _default_hit(cb_vars: Dictionary) -> void:
	AudioManager.play_3d("egg_crack_01", global_position, 0.95)
	var target: Entity = cb_vars.get(ProjectileStats.VarType.TARGET)
	if not is_instance_valid(target): return

	var per_summon: float = value_at_level(_damage_per_summon, level, 0.0)
	var damage: float = _base_damage + _living_allied_summons() * per_summon
	_source.damage.direct(target, damage, Utils.ActionType.DAMAGE_PHYSICAL, &"small_egg")

	var chance: float = value_at_level(_chicken_chances, level, 0.0)
	if Utils.is_randomize_modifier_active(chance, _source.battle_id):
		_spawn_chicken()


# Nombre d'invocations alliées (Category.SUMMON) vivantes sur l'équipe de la source.
func _living_allied_summons() -> int:
	if not is_instance_valid(_source): return 0
	var count: int = 0
	for ally: Entity in _source.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if is_instance_valid(ally) and ally.category == Entity.Category.SUMMON:
			count += 1
	return count


func _spawn_chicken() -> void:
	if not is_instance_valid(_source) or _source.summon == null: return
	_source.summon.summon_entity(Entity.EntityType.CHICKEN, SpawnLocationConfig.create_exact(global_position), {})
