class_name Skill
extends Resource

enum SkillID {
	BRONZE1,
	BRONZE2,
	SILVER1,
	SILVER2,
	GOLD1,
	GOLD2
}

@export var name: String
@export var description: String
@export var portrait: CompressedTexture2D
