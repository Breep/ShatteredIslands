class_name Skill
extends Resource

enum SkillID {
	BRONZE1,
	BRONZE2,
	SILVER1,
	SILVER2,
	GOLD1,
	GOLD2,
	PASSIVE,
	ULTIMATE,
}

enum SkillType {
	BRONZE,
	SILVER,
	GOLD
}

const COLORS: Dictionary [SkillID, Color] = {
	SkillID.BRONZE1: Color.SADDLE_BROWN,
	SkillID.BRONZE2: Color.SADDLE_BROWN,
	SkillID.SILVER1: Color.SILVER,
	SkillID.SILVER2: Color.SILVER,
	SkillID.GOLD1: Color.GOLD,
	SkillID.GOLD2: Color.GOLD,
	SkillID.PASSIVE: Color.BLACK,
	SkillID.ULTIMATE: Color.BLACK
}

@export var name: String
@export_multiline var description: String
@export var portrait: CompressedTexture2D
