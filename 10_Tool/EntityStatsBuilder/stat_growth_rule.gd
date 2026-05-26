# Règle de croissance d'une stat selon le niveau. Toutes les formules
# retournent `base` au niveau 1, puis évoluent selon le type choisi.
@tool
class_name StatGrowthRule
extends Resource

#region ============================== Enum ==============================
enum Type {
	CONSTANT,    # base
	LINEAR,      # base + slope * (lvl - 1)
	POWER,       # base + slope * (lvl - 1) ^ exponent
	LOGARITHMIC, # base + log_scale * log(lvl)
	EXP_DECAY,   # base + (asymptote - base) * (1 - exp(-(lvl - 1) / decay_constant))
}
#endregion


#region ============================== Export ==============================
## Type de courbe. Détermine quels paramètres ci-dessous sont utilisés.
@export var type: Type = Type.CONSTANT

## Valeur de la stat au niveau 1 (toutes les formules ramènent ce résultat).
@export var base: float = 0.0

@export_group("SLOPE")
## Pente. Pour POWER, multiplie le terme (lvl - 1) ^ exponent.
@export var slope: float = 0.0

@export_group("SLOPE/POWER")
## Exposant. < 1 = croissance racine (e.g. 0.5 = sqrt), > 1 = croissance polynomiale.
@export var exponent: float = 1.0

@export_group("LOGARITHMIC")
## Multiplicateur du log(lvl). log(1) = 0 donc la stat vaut bien `base` au lvl 1.
@export var log_scale: float = 1.0

@export_group("EXP_DECAY")
## Valeur asymptotique quand lvl → ∞.
@export var asymptote: float = 100.0
## Constante de décroissance. Plus haute = approche plus lente de l'asymptote.
@export var decay_constant: float = 10.0
#endregion


#region ============================== Public API ==============================
func compute(lvl: int) -> float:
	var l: float = float(lvl)
	match type:
		Type.CONSTANT:
			return base
		Type.LINEAR:
			return base + slope * (l - 1.0)
		Type.POWER:
			return base + slope * pow(l - 1.0, exponent)
		Type.LOGARITHMIC:
			return base + log_scale * log(l)
		Type.EXP_DECAY:
			if decay_constant == 0.0:
				return asymptote
			return base + (asymptote - base) * (1.0 - exp(-(l - 1.0) / decay_constant))
	return 0.0
#endregion
