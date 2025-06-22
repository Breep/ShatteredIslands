class_name CharacterUpgrade
extends Resource

# Effets généraux
const VULNERABILITY: String = "[url=vulnerability][color=#00008B][wave freq=2.0 amp=5.0]Vulnerability[/wave][/color][/url]" # Bleu foncé
const ARMOR: String = "[url=armor][color=#8B4513][wave freq=2.0 amp=5.0]Armor[/wave][/color][/url]" # Marron
const POISON: String = "[url=poison][color=#006400][wave freq=2.0 amp=5.0]Poison[/wave][/color][/url]" # Vert foncé
const HEAL: String = "[url=heal][color=#006400][wave freq=2.0 amp=5.0]Heal[/wave][/color][/url]" # Vert foncé (correspond à Poison)
const IGNITE: String = "[url=ignite][color=#FF0000][wave freq=2.0 amp=5.0]Ignite[/wave][/color][/url]" # Vert foncé (correspond à Poison)

# Types de dégâts
const MAGICAL_DAMAGE: String = "[url=magical_damage][color=#1E90FF][wave freq=2.0 amp=5.0]Magical Damage[/wave][/color][/url]" # Bleu clair
const PHYSICAL_DAMAGE: String = "[url=physical_damage][color=#FF0000][wave freq=2.0 amp=5.0]Physical Damage[/wave][/color][/url]" # Rouge
const POISON_DAMAGE: String = "[url=poison_damage][color=#006400][wave freq=2.0 amp=5.0]Poison Damage[/wave][/color][/url]" # Vert foncé

# Statistiques 
const CRITICAL_CHANCE: String = "[url=critical_chance][wave freq=2.0 amp=5.0]Critical Chance[/wave][/url]" # Pas de couleur
const CRITICAL_MULTIPLIER: String = "[url=critical_multiplier][wave freq=2.0 amp=5.0]Critical Multiplier[/wave][/url]" # Pas de couleur
const ATTACK_DAMAGE: String = "[url=attack_damage][wave freq=2.0 amp=5.0]Attack[/wave][/url]" # Pas de couleur
const ATTACK_SPEED: String = "[url=attack_speed][wave freq=2.0 amp=5.0]Attack Speed[/wave][/url]" # Pas de couleur
const MANA: String = "[url=mana][wave freq=2.0 amp=5.0]Mana[/wave][/url]" # Pas de couleur
const MANA_REGEN: String = "[url=mana_regen][wave freq=2.0 amp=5.0]Mana Regen[/wave][/url]" # Pas de couleur
const ENERGY: String = "[url=energy][wave freq=2.0 amp=5.0]Energy[/wave][/url]" # Pas de couleur
const ENERGY_REGEN: String = "[url=energy_regen][wave freq=2.0 amp=5.0]Energy Regen[/wave][/url]" # Pas de couleur
const MOVE_SPEED: String = "[url=move_speed][wave freq=2.0 amp=5.0]Movement Speed[/wave][/url]" # Pas de couleur

# Effets de statut spéciaux
const BOUNCE: String = "[url=bounce][wave freq=2.0 amp=5.0]Bounce[/wave][/url]" # Pas de couleur
const PACIFY: String = "[url=pacify][wave freq=2.0 amp=5.0]Pacify[/wave][/url]" # Pas de couleur
const TELEPORT: String = "[url=teleport][wave freq=2.0 amp=5.0]Teleport[/wave][/url]" # Pas de couleur
const INVINCIBLE: String = "[url=invincible][wave freq=2.0 amp=5.0]Invincibility[/wave][/url]" # Pas de couleur
const FOCUS: String = "[url=focus][wave freq=2.0 amp=5.0]Focus[/wave][/url]" # Pas de couleur

# Familles d'améliorations
const FIRE_FAMILY: String = "[url=fire_family][color=#FF4500][wave freq=2.0 amp=5.0]Fire Family[/wave][/color][/url]" # Rouge feu
const DEFENSE_FAMILY: String = "[url=defense_family][color=#8B4513][wave freq=2.0 amp=5.0]Defense Family[/wave][/color][/url]" # Marron
const STORM_FAMILY: String = "[url=storm_family][color=#00008B][wave freq=2.0 amp=5.0]Storm Family[/wave][/color][/url]" # Bleu foncé
const HEAL_FAMILY: String = "[url=heal_family][color=#FFFFFF][wave freq=2.0 amp=5.0]Heal Family[/wave][/color][/url]" # Blanc
const POISON_FAMILY: String = "[url=poison_family][color=#006400][wave freq=2.0 amp=5.0]Poison Family[/wave][/color][/url]" # Vert foncé
const HP_FAMILY: String = "[url=hp_family][color=#FFA500][wave freq=2.0 amp=5.0]HP Family[/wave][/color][/url]" # Orange
const ATTACK_FAMILY: String = "[url=attack_family][color=#FFD700][wave freq=2.0 amp=5.0]Attack Family[/wave][/color][/url]" # Jaune
const SHADOW_FAMILY: String = "[url=shadow_family][color=#2F4F4F][wave freq=2.0 amp=5.0]Shadow Family[/wave][/color][/url]" # Gris foncé


func apply(_stats: FamiliesStats, _cardLvl: int) -> void:
	pass

func get_description(_cardlvl: int) -> String:
	return ""
