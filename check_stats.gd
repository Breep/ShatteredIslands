@tool
extends SceneTree

# Mock classes to simulate environment
class MockEntityBaseStats:
	func get_stat(stat_type, action_type = null):
		return 10.0 # Base value

class MockEntityStats:
	var update_count: int = 0
	var last_updated_action_type = -1
	
	func update_stat(stat_type, value, action_type = null):
		update_count += 1
		last_updated_action_type = action_type
		print("DEBUG: update_stat called for action_type: ", action_type)

func _init():
	print("Starting Verification...")
	
	# Setup
	var smd = load("res://Entities/Stats/stat_modifier_dictionary.gd").new()
	var base_stats = MockEntityBaseStats.new()
	var stats = MockEntityStats.new()
	
	# StatType.CRIT_CHANCE is a multi-stat (ActionType dependent)
	var crit_stat_type = 7 # EntityStats.StatType.CRIT_CHANCE
	
	smd.setup(crit_stat_type, stats, base_stats)
	
	# Test 1: Register Single Action Modifier
	print("\nTest 1: Register Modifier for DAMAGE_PHYSICAL (0)")
	var mod1 = load("res://Entities/Stats/stat_modifier.gd").new()
	mod1.stat_type = crit_stat_type
	mod1.action_type = 0 # DAMAGE_PHYSICAL
	mod1.id = "test_mod_1"
	mod1.calc_type = 0 # ADD
	mod1.value = 5.0
	
	stats.update_count = 0
	smd.register_modifier(mod1)
	
	if stats.update_count == 1 and stats.last_updated_action_type == 0:
		print("PASS: Only updated DAMAGE_PHYSICAL")
	else:
		print("FAIL: update_count=", stats.update_count, " last_action=", stats.last_updated_action_type)

	# Test 2: Update Modifier
	print("\nTest 2: Update Modifier for DAMAGE_PHYSICAL")
	mod1.value = 10.0
	stats.update_count = 0
	smd.update_modifier(mod1)
	
	if stats.update_count == 1 and stats.last_updated_action_type == 0:
		print("PASS: Only updated DAMAGE_PHYSICAL")
	else:
		print("FAIL: update_count=", stats.update_count)

	# Test 3: Unregister Modifier
	print("\nTest 3: Unregister Modifier")
	stats.update_count = 0
	smd.unregister_modifier(mod1)
	
	if stats.update_count == 1 and stats.last_updated_action_type == 0:
		print("PASS: Only updated DAMAGE_PHYSICAL")
	else:
		print("FAIL: update_count=", stats.update_count)

	quit()
