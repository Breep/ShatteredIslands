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

enum Type {
	PASSIVE,
	BRONZE,
	SILVER,
	GOLD,
	ULTIMATE
}

const TIER_NAMES: Dictionary [SkillID, String] = {
	SkillID.BRONZE1: "-- Tier 1 --",
	SkillID.BRONZE2: "-- Tier 1 --",
	SkillID.SILVER1: "-- Tier 2 --",
	SkillID.SILVER2: "-- Tier 2 --",
	SkillID.GOLD1: "-- Tier 3 --",
	SkillID.GOLD2: "-- Tier 3 --",
	SkillID.PASSIVE: "-- Passive --",
	SkillID.ULTIMATE: "-- Ultimate --"
}

const COLORS: Dictionary [SkillID, Color] = {
	SkillID.BRONZE1: Color.SADDLE_BROWN,
	SkillID.BRONZE2: Color.SADDLE_BROWN,
	SkillID.SILVER1: Color.SILVER,
	SkillID.SILVER2: Color.SILVER,
	SkillID.GOLD1: Color.GOLDENROD,
	SkillID.GOLD2: Color.GOLDENROD,
	SkillID.PASSIVE: Color.BLACK,
	SkillID.ULTIMATE: Color.BLACK
}

@export var skill_id: SkillID
@export var name: String
@export_multiline var description: String
@export var portrait: CompressedTexture2D
