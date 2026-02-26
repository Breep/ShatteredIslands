class_name ProjectileTrajectory
extends Resource

## Abstract base class for projectile movement patterns.
## Each trajectory defines how a projectile moves from source to target.

# === EXPORTS (to configure per trajectory) ===
@export var speed: float = 20.0

# === RUNTIME (set by init) ===
var _projectile: Projectile
var _source: Entity
var _target: Entity

var _start_pos: Vector3
var _t: float = 0.0


## Initialize the trajectory with projectile and entities.
## Called once when the projectile is created.
func init(projectile: Projectile, source: Entity, target: Entity) -> void:
	_projectile = projectile
	_source = source
	_target = target
	_start_pos = projectile.global_position
	_on_init()


## Virtual method called after init() for subclass-specific setup.
## Override this in derived classes.
func _on_init() -> void:
	pass


## Update the projectile position and orientation.
## Called every frame. MUST be overridden by subclasses.
func update(_delta: float) -> void:
	push_error("ProjectileTrajectory.update() not implemented in " + get_script().resource_path)


## Called when the projectile needs to change target (e.g., for bouncing).
## Optional to override - default behavior resets to new target.
func retarget(new_target: Entity) -> void:
	_target = new_target
	_start_pos = _projectile.global_position
	_t = 0.0
	_on_retarget()


## Virtual method called after retarget() for subclass-specific logic.
## Override this in derived classes if needed.
func _on_retarget() -> void:
	pass
