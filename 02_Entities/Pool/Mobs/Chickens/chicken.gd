class_name Chicken
extends Entity


func _init() -> void:
	super._init()
	category = Category.SUMMON

enum Type {
	BASIC,
	GIFTED_ATTACK,
	GIFTED_STORM_CALLER,
	GIFTED_POISON,
	GIFTED_ARDENT_CELESTIAL,
	GIFTED_COLOSSUS,
	GIFTED_LIGHT,
	GIFTED_ENGINEER,
	GIFTED_NECROSIS
}

# Clés de modifier de stats de base. Plus consommées par le poulet (ses stats viennent
# uniquement de la table par niveau de l'EntityDesc), mais encore écrites par ChickenLord
# (chicken_lord_manager) — conservé pour ne pas casser sa compilation.
enum BaseStatsModifier {
	HP,
	AD,
	ARMOR,
	CRIT_CHANCE,
	CRIT_MULTI
}
