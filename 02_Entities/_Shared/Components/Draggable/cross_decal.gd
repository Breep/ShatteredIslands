class_name CrossDecal
extends Decal

# Decal projeté sous l'entité pendant un drag : feedback visuel de validité du
# drop. Pulse en continu sur le plan XZ et bascule entre vert (OK) et rouge (NOK).

#region ============================== Constants ==============================
const COLOR_OK: Color = Color(0.25, 1.0, 0.35)
const COLOR_NOK: Color = Color(1.0, 0.25, 0.25)
const COLOR_NEUTRAL: Color = Color.WHITE

const PULSE_MIN: float = 0.85
const PULSE_MAX: float = 1.15
const PULSE_HALF_DURATION: float = 0.5

const GLOW_BASE: float = 1.0
const GLOW_AMPLITUDE: float = 0.8
const GLOW_FREQUENCY: float = 1.2     # Hz
#endregion

#region ============================== Private variables ==============================
var _pulse_tween: Tween
var _glow_enabled: bool = false
var _time: float = 0.0
#endregion

#region ============================== Node base functions ==============================
func _ready() -> void:
	set_ok()
	_start_pulse()
	set_process(false)


func _process(delta: float) -> void:
	_time += delta
	emission_energy = maxf(0.0, GLOW_BASE + GLOW_AMPLITUDE * sin(_time * TAU * GLOW_FREQUENCY))
#endregion

#region ============================== Public functions ==============================
func set_ok() -> void:
	modulate = COLOR_OK


func set_nok() -> void:
	modulate = COLOR_NOK


func set_neutral() -> void:
	modulate = COLOR_NEUTRAL


# Active un glow pulsé (emission sinusoïdale) — utilisé quand le decal sert de
# marqueur de sélection. La texture d'émission reprend la croix de l'albedo.
func enable_glow() -> void:
	if _glow_enabled:
		return
	_glow_enabled = true
	if texture_emission == null:
		texture_emission = texture_albedo
	set_process(true)


# Fige le decal (marqueur statique, ex. position d'origine) : stoppe le pulse et
# remet l'échelle de base.
func stop_pulse() -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	scale = Vector3.ONE
#endregion

#region ============================== Private functions ==============================
func _start_pulse() -> void:
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(self, "scale", Vector3(PULSE_MAX, 1.0, PULSE_MAX), PULSE_HALF_DURATION)
	_pulse_tween.tween_property(self, "scale", Vector3(PULSE_MIN, 1.0, PULSE_MIN), PULSE_HALF_DURATION)
#endregion
