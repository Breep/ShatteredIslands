class_name GlossaryContent
extends RefCounted

# Construit la liste d'entrées du glossaire joueur. Les mots-clés partagés
# (altérations, stats, types de dégâts...) sont tirés de la base canonique du
# TooltipManager pour rester synchronisés avec les tooltips en jeu ; les
# déclencheurs, mots d'effet et règles de grammaire — qui n'ont pas de tooltip —
# sont rédigés ici à partir du Guide joueur des cartes.

const CAT_TRIGGER := "Déclencheurs"
const CAT_EFFECT := "Mots d'effet"
const CAT_ALTERATION := "Altérations"
const CAT_STAT := "Stats"
const CAT_TAG := "Tags & dégâts"
const CAT_FAMILY := "Familles"
const CAT_GRAMMAR := "Grammaire"

const CATEGORY_ORDER: Array[String] = [
	CAT_TRIGGER, CAT_EFFECT, CAT_ALTERATION, CAT_STAT, CAT_TAG, CAT_FAMILY, CAT_GRAMMAR,
]

# Catégorie de chaque clé surfacée depuis la base de tooltips. Les clés inconnues
# retombent sur CAT_TAG (elles restent affichées avec leur texte canonique).
const CATEGORY_BY_KEY := {
	"SHIELD": CAT_ALTERATION, "REGEN": CAT_ALTERATION, "STRENGTH": CAT_ALTERATION,
	"DEFENCE": CAT_ALTERATION, "BLOCK": CAT_ALTERATION, "THORN": CAT_ALTERATION,
	"TAUNT": CAT_ALTERATION, "IGNITE": CAT_ALTERATION, "NECROSIS": CAT_ALTERATION,
	"WEAKNESS": CAT_ALTERATION, "VULNERABILITY": CAT_ALTERATION, "STUN": CAT_ALTERATION,
	"POISON_STACK": CAT_ALTERATION,

	"AD": CAT_STAT, "AP": CAT_STAT, "ARMOR": CAT_STAT, "MR": CAT_STAT,
	"CRIT_CHANCE": CAT_STAT, "CRIT_MULTIPLIER": CAT_STAT, "DODGE": CAT_STAT,
	"SCALE": CAT_STAT, "COOLDOWN": CAT_STAT, "MANA": CAT_STAT, "RANK": CAT_STAT,
	"POISON_RESISTANCE": CAT_STAT, "POISON_RESIST": CAT_STAT, "ATTACK": CAT_STAT,
	"HP": CAT_STAT,

	"PHYSICAL_DAMAGE": CAT_TAG, "MAGICAL_DAMAGE": CAT_TAG, "POISON_DAMAGE": CAT_TAG,
	"TRUE_DAMAGE": CAT_TAG, "SMALL_PROJECTILE": CAT_TAG, "BIG_PROJECTILE": CAT_TAG,

	"CLEANSE": CAT_EFFECT, "DISPELL": CAT_EFFECT, "EXECUTE": CAT_EFFECT,
	"SUMMON": CAT_EFFECT, "METEOR": CAT_EFFECT, "BUILDING": CAT_EFFECT,
	"ACOLYTE": CAT_EFFECT,

	"CHICKEN_LORD": CAT_FAMILY, "COLOSSUS": CAT_FAMILY, "NECRO": CAT_FAMILY,
	"LIGHT": CAT_FAMILY, "LIGHTNING": CAT_FAMILY, "WARRIOR": CAT_FAMILY,
}


## Liste complète, regroupée par catégorie dans l'ordre de CATEGORY_ORDER.
static func build() -> Array[GlossaryEntry]:
	var all: Array[GlossaryEntry] = []
	all.append_array(_triggers())
	all.append_array(_effect_keywords())
	all.append_array(_from_tooltips())
	all.append_array(_grammar())

	var ordered: Array[GlossaryEntry] = []
	for category in CATEGORY_ORDER:
		for entry in all:
			if entry.category == category:
				ordered.append(entry)
	return ordered


static func _entry(term: String, category: String, description: String, icon_key: String = "") -> GlossaryEntry:
	var entry := GlossaryEntry.new()
	entry.term = term
	entry.category = category
	entry.description = description
	entry.icon_key = icon_key
	return entry


static func _from_tooltips() -> Array[GlossaryEntry]:
	var out: Array[GlossaryEntry] = []
	for desc in TooltipManager.get_descriptions():
		var category: String = CATEGORY_BY_KEY.get(String(desc.key), CAT_TAG)
		out.append(_entry(desc.title, category, desc.description, desc.icon_key))
	return out


static func _triggers() -> Array[GlossaryEntry]:
	return [
		_entry("Rush", CAT_TRIGGER,
			"Se déclenche [b]au début du combat[/b].\nEx : [i]Rush : Gagne 50 [[SHIELD]].[/i]"),
		_entry("Rush(X)", CAT_TRIGGER,
			"Au début du combat, puis l'effet [b]dure X secondes[/b].\nEx : [i]Rush(10) : Gagne 20 [[STRENGTH]].[/i]"),
		_entry("⏳ X s", CAT_TRIGGER,
			"Se déclenche [b]toutes les X secondes[/b] (effet périodique).\nEx : [i]⏳ 8 s : Inflige 8 [[IGNITE]].[/i]",
			"COOLDOWN_ICON"),
		_entry("Attaque", CAT_TRIGGER,
			"Se déclenche à [b]chaque auto-attaque[/b].\nEx : [i]Attaque : Applique 1 [[POISON_STACK]].[/i]",
			"ATTACK_ICON"),
		_entry("Combo X", CAT_TRIGGER,
			"Se déclenche [b]après X auto-attaques[/b].\nEx : [i]Combo 8 : Lance 1 [[SMALL_PROJECTILE]].[/i]",
			"ATTACK_ICON"),
		_entry("Ultime", CAT_TRIGGER,
			"Se déclenche quand l'[b]ultime est lancé[/b].\nEx : [i]Ultime : Applique [[STUN]] pendant 2 s.[/i]"),
		_entry("Touché", CAT_TRIGGER,
			"Se déclenche quand l'unité [b]reçoit un impact valide[/b].\nEx : [i]Touché : Gagne 3 [[THORN]].[/i]"),
		_entry("Crit", CAT_TRIGGER,
			"Se déclenche sur [b]coup critique[/b].\nEx : [i]Crit : Applique 3 [[WEAKNESS]].[/i]"),
		_entry("Kill", CAT_TRIGGER,
			"Se déclenche quand la source [b]tue une unité[/b].\nEx : [i]Kill : Gagne 1 [[STRENGTH]].[/i]"),
		_entry("Dodge", CAT_TRIGGER,
			"Se déclenche quand l'unité [b]esquive[/b].\nEx : [i]Dodge : Gagne 20 [[SHIELD]].[/i]"),
		_entry("Spawn", CAT_TRIGGER,
			"Se déclenche quand un [b]summon apparaît[/b].\nEx : [i]Spawn : Le [[SUMMON]] gagne 3 [[BLOCK]].[/i]"),
		_entry("Mort de X", CAT_TRIGGER,
			"Se déclenche quand [b]X meurt[/b].\nEx : [i]Mort de Poulet : Invoque 1 Poulet.[/i]"),
		_entry("Application de X", CAT_TRIGGER,
			"Se déclenche quand [b]X est appliqué[/b].\nEx : [i]Application d'[[IGNITE]] : Lance 1 projectile.[/i]"),
		_entry("Tick de X", CAT_TRIGGER,
			"Se déclenche quand [b]X produit son effet périodique[/b].\nEx : [i]Tick d'[[IGNITE]] : Gagne 5 [[SHIELD]].[/i]"),
	]


static func _effect_keywords() -> Array[GlossaryEntry]:
	return [
		_entry("Inflige", CAT_EFFECT,
			"Fait des dégâts ou applique directement une valeur offensive."),
		_entry("Applique", CAT_EFFECT,
			"Pose une [b]altération[/b] sur une cible."),
		_entry("Gagne", CAT_EFFECT,
			"Donne un effet à [b]la source[/b] de la carte."),
		_entry("Donne", CAT_EFFECT,
			"Donne un effet à [b]une autre cible[/b]."),
		_entry("Pose", CAT_EFFECT,
			"Ajoute un bâtiment, piège, objet ou élément de terrain."),
		_entry("Invoque", CAT_EFFECT,
			"Fait apparaître un [b]summon[/b] pendant le combat.", "SUMMON_ICON"),
		_entry("Crée", CAT_EFFECT,
			"Produit une ressource, une carte, un choix ou un objet abstrait."),
		_entry("Random", CAT_EFFECT,
			"Choisit un résultat [b]aléatoire[/b] parmi plusieurs options."),
		_entry("Area(X)", CAT_EFFECT,
			"Effet appliqué dans une [b]zone de X mètres[/b]."),
	]


static func _grammar() -> Array[GlossaryEntry]:
	return [
		_entry("Structure", CAT_GRAMMAR,
			"Une carte se lit [b]Déclencheur : Effet[/b].\nLe déclencheur dit [i]quand[/i], l'effet dit [i]ce qui se passe[/i]."),
		_entry("Combinaison", CAT_GRAMMAR,
			"Plusieurs déclencheurs pour un même effet se combinent avec [b]+[/b].\nEx : [i]Rush + ⏳ 8 s : Inflige 8 [[IGNITE]].[/i] — une fois au début, puis toutes les 8 s."),
		_entry("Durée vs répétition", CAT_GRAMMAR,
			"[b]Rush(10)[/b] = une durée de 10 s.\n[b]⏳ 10 s[/b] = une répétition toutes les 10 s. À ne pas confondre."),
		_entry("Stacks", CAT_GRAMMAR,
			"Les altérations à nombre utilisent généralement ce nombre comme des [b]stacks[/b]."),
		_entry("Carte vs tooltip", CAT_GRAMMAR,
			"Le front de carte reste court. Les [b]détails longs[/b] (valeurs exactes, ticks, decay) vont dans le tooltip."),
	]
