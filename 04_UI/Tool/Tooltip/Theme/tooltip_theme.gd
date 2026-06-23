class_name TooltipTheme
extends Resource

# ============================== ICONS ==============================
@export_group("Icons")

@export_subgroup("General Actions")
@export var ATTACK_ICON: CompressedTexture2D
@export var RANK_ICON: CompressedTexture2D
@export var SUMMON_ICON: CompressedTexture2D

@export_subgroup("Families")
@export var LIGHTNING_FAMILY_ICON: CompressedTexture2D
@export var SERENITY_FAMILY_ICON: CompressedTexture2D
@export var LIFE_FAMILY_ICON: CompressedTexture2D
@export var POISON_FAMILY_ICON: CompressedTexture2D
@export var NECRO_FAMILY_ICON: CompressedTexture2D
@export var CHICKEN_FAMILY_ICON: CompressedTexture2D
@export var FIRE_FAMILY_ICON: CompressedTexture2D
@export var ATTACK_FAMILY_ICON: CompressedTexture2D
@export var CRIT_FAMILY_ICON: CompressedTexture2D

@export_subgroup("Damage Types")
@export var PHYSICAL_DAMAGE_ICON: CompressedTexture2D
@export var MAGICAL_DAMAGE_ICON: CompressedTexture2D
@export var TRUE_DAMAGE_ICON: CompressedTexture2D
@export var POISON_DAMAGE_ICON: CompressedTexture2D

@export_subgroup("Stack Types")
@export var SHIELD_ICON: CompressedTexture2D
@export var POISON_STACK_ICON: CompressedTexture2D
@export var IGNITE_ICON: CompressedTexture2D
@export var THORN_ICON: CompressedTexture2D
@export var TAUNT_ICON: CompressedTexture2D

@export_subgroup("Mechanics & Stats")
@export var DEFENCE_ICON: CompressedTexture2D # Pour Armor, MR, Shield
@export var STAT_ICON: CompressedTexture2D    # Pour Strength, Crit, Dodge
@export var CC_ICON: CompressedTexture2D      # Pour Stun, Root
@export var MAGIC_ICON: CompressedTexture2D   # Pour Meteor, Necrosis
@export var HEAL_ICON: CompressedTexture2D    # Pour Regen, Cleanse
@export var COOLDOWN_ICON: CompressedTexture2D #Pour une horloge/sablier

@export_subgroup("Misc")
@export var DEFAULT_ICON: CompressedTexture2D


# ============================== COLORS ==============================
@export_group("Colors")

# --- COULEURS FAMILLES (Basées sur ton image) ---
@export_subgroup("Family Colors")
@export var ATTACK_COLOR: Color = Color("B0C4DE")    # LightSteelBlue (Gris/Bleu Attaque)
@export var DEFENCE_COLOR: Color = Color("CD853F")   # Peru (Marron Défense)
@export var LIGHTNING_COLOR: Color = Color("005bffff") # DeepSkyBlue (Bleu Foudre)
@export var SERENITY_COLOR: Color = Color("F0F8FF")  # AliceBlue (Blanc/Bleu Serenity)
@export var LIFE_COLOR: Color = Color("FF8C00")      # DarkOrange (Orange Vie)
@export var NECRO_COLOR: Color = Color("9932CC")     # DarkOrchid (Violet Necro)
@export var CHICKEN_COLOR: Color = Color("FFD700")   # Gold (Jaune Chicken-Lord)
@export var POISON_COLOR: Color = Color("346800ff")    # YellowGreen (Vert Poison image)

# --- COULEURS MECANIQUES ---
@export_subgroup("Mechanic Colors")
@export var PHYSICAL_COLOR: Color = Color("DEB887")  # Burlywood (Physique)
@export var MAGICAL_COLOR: Color = Color("6495ED")   # CornflowerBlue (Magique)
@export var TRUE_COLOR: Color = Color("c3af07ff")      # WhiteSmoke (Brut)
@export var FIRE_COLOR: Color = Color("FF4500")      # OrangeRed (Feu/Ignite)
@export var STAT_COLOR: Color = Color("4c8bd8ff")      # Gold (Stats générales)
@export var DEBUFF_COLOR: Color = Color("DA70D6")    # Orchid (Debuffs/Faiblesses)
@export var SHIELD_COLOR: Color = Color("895a24ff")    # LightCyan (Bouclier spécifique)
@export var THORN_COLOR: Color = Color("8B4513")     # SaddleBrown (épines, cf. ThornAlteration)
@export var TAUNT_COLOR: Color = Color("DC143C")     # Crimson (provocation, cf. TauntAlteration)
@export var COOLDOWN_COLOR: Color = Color("87CEEB")  # Skyblue
@export var REGEN_COLOR: Color = Color("7fdf4dff")  # Skyblue
@export var DISPELL_COLOR: Color = Color("af23d4ff")  
@export var METEOR_COLOR: Color = Color("7c2852")  # Skyblue
@export var SMALL_PROJECTILE_COLOR: Color = Color("9bbcd8")  # Light steel blue (petits projectiles)
@export var BIG_PROJECTILE_COLOR: Color = Color("d87c3a")    # Burnt orange (gros projectiles)
@export var ABILITY_PROJECTILE_COLOR: Color = Color("9b6cd8") # Violet (projectiles d'abilité, ombrelle small + big)
@export var MANA_COLOR: Color = Color(0, 0, 255, 1) #Blue
@export var SCALE_COLOR: Color = Color("948e7e")
@export var BLOCK_COLOR: Color = Color("328767")
@export var VALUE_COLOR: Color = Color("87CEFA")     # LightSkyBlue (valeurs numériques)
@export var DEFAULT_COLOR: Color = Color.WHITE

# ============================== FUNCTIONS ==============================

func color_html(color_key: String, include_alpha: bool = true) -> String:
	var color = get(color_key)
	if color != null:
		return color.to_html(include_alpha)
	else:
		# Fallback si la couleur n'est pas trouvée
		return DEFAULT_COLOR.to_html(include_alpha)


func icon(icon_key: String) -> Texture2D:
	var icon_texture = get(icon_key)
	if icon_texture != null:
		return icon_texture
	else:
		return DEFAULT_ICON
