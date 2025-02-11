@tool
class_name PackedSceneUtilsTests
extends Node

const _EXAMPLE_SCENES_PATH := GDScriptUtilities.PATH_PLUGIN_DIRECTORY + "/examples/scenes"

#Unrelated scene, Uses Control and has no script
const _UI_SCENE := preload(_EXAMPLE_SCENES_PATH + "/ui_npc_name.tscn")

#Basic scene. Uses Node2D and Goblin script.
const _GOBLIN_SCENE := preload(_EXAMPLE_SCENES_PATH + "/goblin.tscn")

#Inherits from Goblin, changes a few values.
const _HOBGOBLIN_SCENE := preload(_EXAMPLE_SCENES_PATH + "/hobgoblin.tscn")

#Inherits from HobGoblin, different script
const _ORC_SCENE := preload(_EXAMPLE_SCENES_PATH + "/orc.tscn")

#Contains Goblin, HobGoblin and Orc as sub-scenes
const _LEVEL_SCENE := preload(_EXAMPLE_SCENES_PATH + "/level_01.tscn")


func _ready():
	run_tests()
	queue_free()


func run_tests():
	assert_get_node_name()
	assert_get_node_type()
	assert_get_node_type_name()
	assert_get_scene_instance()
	assert_get_scene_instances()
	assert_get_script_type()
	assert_get_script_type_name()
	
	#Should also serves as a test for get methods.
	assert_has_groups()
	assert_has_methods()
	assert_has_properties()
	assert_has_properties_with_values()
	assert_has_signals()
	assert_is_class_of()


func assert_get_node_name():
	const assertion_item := "PackedSceneUtils.get_node_name()"
	
	assert(PackedSceneUtils.get_node_name(_GOBLIN_SCENE) == "Goblin", assertion_item)
	assert(PackedSceneUtils.get_node_name(_HOBGOBLIN_SCENE) == "HobGoblin", assertion_item)
	assert(PackedSceneUtils.get_node_name(_ORC_SCENE) == "Orc", assertion_item)
	assert(PackedSceneUtils.get_node_name(_UI_SCENE) == "NPC Name", assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_get_node_type():
	const assertion_item := "PackedSceneUtils.get_node_type()"
	
	assert(PackedSceneUtils.get_node_type(_GOBLIN_SCENE) == Sprite2D, assertion_item)
	assert(PackedSceneUtils.get_node_type(_HOBGOBLIN_SCENE) == Sprite2D, assertion_item)
	assert(PackedSceneUtils.get_node_type(_ORC_SCENE) == Sprite2D, assertion_item)
	assert(PackedSceneUtils.get_node_type(_UI_SCENE) == Control, assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_get_node_type_name():
	const assertion_item := "PackedSceneUtils.get_node_type_name()"
	
	assert(PackedSceneUtils.get_node_type_name(_GOBLIN_SCENE) == "Sprite2D", assertion_item)
	assert(PackedSceneUtils.get_node_type_name(_HOBGOBLIN_SCENE) == "Sprite2D", assertion_item)
	assert(PackedSceneUtils.get_node_type_name(_ORC_SCENE) == "Sprite2D", assertion_item)
	assert(PackedSceneUtils.get_node_type_name(_UI_SCENE) == "Control", assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_get_scene_instance():
	const assertion_item := "PackedSceneUtils.get_scene_instance()"
	
	assert(PackedSceneUtils.get_scene_instance(_GOBLIN_SCENE) == null, assertion_item)
	assert(PackedSceneUtils.get_scene_instance(_HOBGOBLIN_SCENE) == _GOBLIN_SCENE, assertion_item)
	assert(not PackedSceneUtils.get_scene_instance(_ORC_SCENE) == _GOBLIN_SCENE, assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_get_scene_instances():
	const assertion_item := "PackedSceneUtils.get_scene_instances()"
	
	var expected_scenes := [_GOBLIN_SCENE, _HOBGOBLIN_SCENE, _ORC_SCENE]
	var unexpected_scenes := [_UI_SCENE, _LEVEL_SCENE]
	var scene_instances := PackedSceneUtils.get_scene_instances(_LEVEL_SCENE)
	var has_all := true
	
	for expected_item in expected_scenes:
		if not scene_instances.has(expected_item):
			has_all = false
			break
	
	assert(has_all, assertion_item)
	
	var has_any := false
	for unexpected_item in unexpected_scenes:
		if scene_instances.has(unexpected_item):
			has_all = true
			break
	
	assert(not has_any, assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_get_script_type():
	const assertion_item := "PackedSceneUtils.get_script_type()"
	
	assert(PackedSceneUtils.get_script_type(_GOBLIN_SCENE) == Goblin, assertion_item)
	assert(PackedSceneUtils.get_script_type(_HOBGOBLIN_SCENE) == Goblin, assertion_item)
	assert(PackedSceneUtils.get_script_type(_ORC_SCENE) == Orc, assertion_item)
	assert(PackedSceneUtils.get_script_type(_UI_SCENE) == null, assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_get_script_type_name():
	const assertion_item := "PackedSceneUtils.get_script_type_name()"
	
	assert(PackedSceneUtils.get_script_type_name(_GOBLIN_SCENE) == "Goblin", assertion_item)
	assert(PackedSceneUtils.get_script_type_name(_HOBGOBLIN_SCENE) == "Goblin", assertion_item)
	assert(PackedSceneUtils.get_script_type_name(_ORC_SCENE) == "Orc", assertion_item)
	assert(PackedSceneUtils.get_script_type_name(_UI_SCENE) == "", assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_has_groups():
	const assertion_item := "PackedSceneUtils.has_groups()"
	
	assert(PackedSceneUtils.has_groups(_GOBLIN_SCENE, ["Enemy"]), assertion_item)
	assert(not PackedSceneUtils.has_groups(_GOBLIN_SCENE, ["Evolution"]), assertion_item)
	
	assert(PackedSceneUtils.has_groups(_HOBGOBLIN_SCENE, ["Evolution"]), assertion_item)
	assert(PackedSceneUtils.has_groups(_HOBGOBLIN_SCENE, ["Enemy", "Evolution"]), assertion_item)
	assert(not PackedSceneUtils.has_groups(_HOBGOBLIN_SCENE, ["Highland"]), assertion_item)
	
	assert(PackedSceneUtils.has_groups(_ORC_SCENE, ["Highland"]), assertion_item)
	assert(PackedSceneUtils.has_groups(_ORC_SCENE, ["Enemy", "Evolution", "Highland"]), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_has_methods():
	const assertion_item := "PackedSceneUtils.has_methods()"
	
	# Script, Sprite2D, Node, Object
	var goblin_methods : PackedStringArray = [
		"receive_damage",
		"is_pixel_opaque",
		"get_tree",
		"emit_signal",
	]
	
	var bad_methods : PackedStringArray = [
		"receive_dmg",
		"do_nothing",
		"get_tree",
		"emit_signal",
	]
	
	# Control, Node, Object
	var control_methods : PackedStringArray = [
		"get_anchor",
		"get_tree",
		"emit_signal",
	]
	
	assert(PackedSceneUtils.has_methods(_GOBLIN_SCENE, []), assertion_item)
	assert(not PackedSceneUtils.has_methods(_GOBLIN_SCENE, bad_methods), assertion_item)
	
	assert(PackedSceneUtils.has_methods(_GOBLIN_SCENE, goblin_methods), assertion_item)
	assert(not PackedSceneUtils.has_methods(_GOBLIN_SCENE, control_methods), assertion_item)
	assert(PackedSceneUtils.has_methods(_HOBGOBLIN_SCENE, goblin_methods), assertion_item)
	assert(PackedSceneUtils.has_methods(_ORC_SCENE, goblin_methods), assertion_item)
	
	assert(PackedSceneUtils.has_methods(_UI_SCENE, control_methods))
	assert(not PackedSceneUtils.has_methods(_UI_SCENE, goblin_methods))
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_has_properties():
	const assertion_item := "PackedSceneUtils.has_properties()"
	
	# Script, Sprite2D, Node, Object
	var goblin_properties : PackedStringArray = [
		"implements",
		"health",
		"can_jump",
		"is_magical",
		"frame",
		"frame_coords",
		"owner",
	]
	
	var orc_properties : PackedStringArray = [
		"health",
		"can_jump",
		"is_magical",
		"frame",
		"frame_coords",
		"owner",
	]
	
	var bad_properties : PackedStringArray = [
		"layout_direction",
		"can_jump",
		"owner",
		"z_index",
	]
	
	# Control, Node, Object
	var control_properties : PackedStringArray = [
		"layout_direction",
		"owner",
		"z_index",
	]
	
	assert(PackedSceneUtils.has_properties(_GOBLIN_SCENE, []), assertion_item)
	assert(not PackedSceneUtils.has_properties(_GOBLIN_SCENE, bad_properties), assertion_item)
	
	assert(PackedSceneUtils.has_properties(_GOBLIN_SCENE, goblin_properties), assertion_item)
	assert(not PackedSceneUtils.has_properties(_GOBLIN_SCENE, control_properties), assertion_item)
	assert(PackedSceneUtils.has_properties(_HOBGOBLIN_SCENE, goblin_properties), assertion_item)
	assert(not PackedSceneUtils.has_properties(_ORC_SCENE, goblin_properties), assertion_item)
	assert(PackedSceneUtils.has_properties(_ORC_SCENE, orc_properties), assertion_item)
	
	assert(PackedSceneUtils.has_properties(_UI_SCENE, control_properties), assertion_item)
	assert(not PackedSceneUtils.has_properties(_UI_SCENE, goblin_properties), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_has_properties_with_values():
	const assertion_item := "PackedSceneUtils.has_properties_with_values()"
	
	var goblin_values := {
		"health":5,
		"attack":6,
		"defense":{ "value":DefaultValue.instance, "type":TYPE_INT },
		"position":{ "value":Vector2(100,100), "type":TYPE_VECTOR2 },
	}
		
	var hobgoblin_values := {
		"health":10,
		"attack":5,
		"defense":DefaultValue.instance,
		"position":Vector2(200,100),
		"scale":Vector2(200,200),
		"modulate":Color(0,1,0,1),
		"metadata/Tags":[ "Enemy", "Damageable" ],
	}
	
	var orc_values := {
		"health":10,
		"attack":10,
		"defense":10,
		"script":Orc,
		"metadata/Tags":{ "value":[ "Magician", "Enemy" ], "type":TYPE_PACKED_STRING_ARRAY },
	}
	
	assert(PackedSceneUtils.has_properties_with_values(_GOBLIN_SCENE, { }), assertion_item)
	assert(PackedSceneUtils.has_properties_with_values(_GOBLIN_SCENE, goblin_values), assertion_item)
	assert(not PackedSceneUtils.has_properties_with_values(_GOBLIN_SCENE, hobgoblin_values), assertion_item)
	assert(not PackedSceneUtils.has_properties_with_values(_GOBLIN_SCENE, orc_values), assertion_item)
	
	assert(PackedSceneUtils.has_properties_with_values(_HOBGOBLIN_SCENE, hobgoblin_values), assertion_item)
	assert(not PackedSceneUtils.has_properties_with_values(_HOBGOBLIN_SCENE, goblin_values), assertion_item)
	assert(not PackedSceneUtils.has_properties_with_values(_HOBGOBLIN_SCENE, orc_values), assertion_item)
	
	assert(PackedSceneUtils.has_properties_with_values(_ORC_SCENE, orc_values), assertion_item)
	assert(not PackedSceneUtils.has_properties_with_values(_ORC_SCENE, goblin_values), assertion_item)
	assert(not PackedSceneUtils.has_properties_with_values(_ORC_SCENE, hobgoblin_values), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_has_signals():
	const assertion_item := "PackedSceneUtils.has_signals()"
	
	# Script, Sprite2D, Node, Object
	var goblin_signals : PackedStringArray = [
		"frame_changed",
		"visibility_changed",
		"tree_entered",
		"script_changed"
	]
	
	# Control, Node, Object
	var control_signals : PackedStringArray = [
		"gui_input",
		"visibility_changed",
		"tree_entered",
		"script_changed",
	]
	
	assert(PackedSceneUtils.has_signals(_GOBLIN_SCENE, []), assertion_item)
	
	assert(PackedSceneUtils.has_signals(_GOBLIN_SCENE, goblin_signals), assertion_item)
	assert(not PackedSceneUtils.has_signals(_GOBLIN_SCENE, control_signals), assertion_item)
	assert(PackedSceneUtils.has_signals(_HOBGOBLIN_SCENE, goblin_signals), assertion_item)
	assert(PackedSceneUtils.has_signals(_ORC_SCENE, goblin_signals), assertion_item)
	
	assert(PackedSceneUtils.has_signals(_UI_SCENE, control_signals), assertion_item)
	assert(not PackedSceneUtils.has_signals(_UI_SCENE, goblin_signals), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_is_class_of():
	const assertion_item := "PackedSceneUtils.is_class_of()"
	
	assert(not PackedSceneUtils.is_class_of(null, null), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_GOBLIN_SCENE, null), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_GOBLIN_SCENE, ""), assertion_item)
	
	assert(PackedSceneUtils.is_class_of(_GOBLIN_SCENE, Goblin), assertion_item)
	assert(PackedSceneUtils.is_class_of(_GOBLIN_SCENE, Character), assertion_item)
	assert(PackedSceneUtils.is_class_of(_GOBLIN_SCENE, Sprite2D), assertion_item)
	assert(PackedSceneUtils.is_class_of(_GOBLIN_SCENE, Node), assertion_item)
	assert(PackedSceneUtils.is_class_of(_GOBLIN_SCENE, Object), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_GOBLIN_SCENE, MainScene), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_GOBLIN_SCENE, Node3D), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_GOBLIN_SCENE, Resource), assertion_item)
	
	assert(PackedSceneUtils.is_class_of(_GOBLIN_SCENE, "Goblin"), assertion_item)
	assert(PackedSceneUtils.is_class_of(_GOBLIN_SCENE, "Character"), assertion_item)
	assert(PackedSceneUtils.is_class_of(_GOBLIN_SCENE, "Sprite2D"), assertion_item)
	assert(PackedSceneUtils.is_class_of(_GOBLIN_SCENE, "Node"), assertion_item)
	assert(PackedSceneUtils.is_class_of(_GOBLIN_SCENE, "Object"), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_GOBLIN_SCENE, "SceneCollector"), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_GOBLIN_SCENE, "Node3D"), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_GOBLIN_SCENE, "Resource"), assertion_item)
	
	assert(PackedSceneUtils.is_class_of(_UI_SCENE, Control), assertion_item)
	assert(PackedSceneUtils.is_class_of(_UI_SCENE, Node), assertion_item)
	assert(PackedSceneUtils.is_class_of(_UI_SCENE, Object), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_UI_SCENE, Goblin), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_UI_SCENE, Character), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_UI_SCENE, MainScene), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_UI_SCENE, Sprite2D), assertion_item)
	assert(not PackedSceneUtils.is_class_of(_UI_SCENE, Resource), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)
