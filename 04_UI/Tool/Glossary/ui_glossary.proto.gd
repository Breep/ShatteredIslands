extends Control

# Scène proto du UIGlossary : exerce son API publique en isolation
# (populate / open / close / filter_category / search) via des boutons,
# avec le contenu réel produit par GlossaryContent.

@onready var _glossary: UIGlossary = %UIGlossary


func _ready() -> void:
	%PopulateButton.pressed.connect(_on_populate)
	%OpenButton.pressed.connect(_glossary.open)
	%CloseButton.pressed.connect(_glossary.close)
	%FilterTriggersButton.pressed.connect(_glossary.filter_category.bind(GlossaryContent.CAT_TRIGGER))
	%SearchPoisonButton.pressed.connect(_glossary.search.bind("poison"))
	%ClearButton.pressed.connect(_on_clear)

	_on_populate()
	_glossary.open()


func _on_populate() -> void:
	_glossary.populate(GlossaryContent.build())


func _on_clear() -> void:
	var empty: Array[GlossaryEntry] = []
	_glossary.populate(empty)
