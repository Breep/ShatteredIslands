class_name ProjectileConf
extends Resource

@export var projectile_type: Projectile.ProjectileType
@export var visual_scene: PackedScene

# Movement & path tuning
@export var trajectory_type: Projectile.TrajectoryType = Projectile.TrajectoryType.STRAIGHT
@export var speed: float = 20.0                         # Base forward speed (units/s)
@export var lifetime_max: float = 6.0                   # Safety fuse

# ARC / BEZIER vertical shaping
@export var arc_height: float = 2.0                     # Peak height (world units)
@export var bezier_control_height: float = 5.0          # Control point height for BEZIER
@export var randomize_arc_by: float = 0.5               # ± randomness on height

# ZIGZAG shaping
@export var zigzag_amplitude: float = 0.5              # Lateral offset amplitude
@export var zigzag_frequency: float = 5.0               # Cycles per second along the path

# HOMING smoothing
@export var turn_rate_deg_per_s: float = 360.0          # Max turn speed
@export var homing_retarget_each_frame: bool = true     # If false, homes to snapshot
