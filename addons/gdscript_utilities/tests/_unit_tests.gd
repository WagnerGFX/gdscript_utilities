@tool
class_name UnitTests
extends Node

const ASSERTION_PASSED_MSG : String = "✔ Assertion passed: "

static var passed_assertions_count : int = 0


func _ready():
	add_sibling(ClassUtilsTests.new())
	add_sibling(VariantUtilsTests.new())
	add_sibling(PackedSceneUtilsTests.new())
	queue_free()


func _exit_tree() -> void:
	print("✔ Total assertions passed: ", passed_assertions_count)
	passed_assertions_count = 0


static func print_assertion_passed(assertion_item):
	print(ASSERTION_PASSED_MSG, assertion_item)
	passed_assertions_count += 1

# Not for actual use, just some examples for the asset library
func screenshot_samples():
	var GOBLIN_SCENE : Resource
	var HOBGOBLIN_SCENE : Resource
	var required_items
	var my_packed_array
	var maybe_a_dictionary
	
	# Custom Scripts, Native Classes, Inheritance
	ClassUtils.is_class_of(Goblin, Character) == true
	ClassUtils.is_class_of(Goblin, Node) == true
	ClassUtils.is_class_of(Node2D, Node) == true
	ClassUtils.is_class_of("Goblin","Node") == true
	
	# No errors for invalid types
	ClassUtils.is_class_of("","") == false
	ClassUtils.is_class_of("64rand name","64rand name") == false
	ClassUtils.is_class_of(null,null) == false
	
	# Check for valid classes and scripts
	ClassUtils.is_valid("Goblin") == true
	ClassUtils.is_valid("Node") == true
	
	# Know the difference between a Script and a Native Class
	ClassUtils.is_script(Goblin) == true
	ClassUtils.is_native(Node) == true
	
	# Unified function to get a type name.
	# Easily get types from string names and vice-versa.
	ClassUtils.get_type_name(null) == type_string(TYPE_NIL)
	ClassUtils.get_type_name(34) == type_string(TYPE_INT)
	ClassUtils.get_type_name("Object") == type_string(TYPE_STRING)
	ClassUtils.get_type_name([]) == type_string(TYPE_ARRAY)
	ClassUtils.get_type_name(Object) == "Object"
	ClassUtils.get_type_name(Goblin) == "Goblin"
	ClassUtils.get_type_name(get_tree()) == "SceneTree"
	ClassUtils.get_type("Node") == Node
	ClassUtils.get_type("Goblin") == Goblin
	
	# Get the entire inheritance list of a class.
	ClassUtils.get_inheritance_list(Goblin).has("Character") == true
	ClassUtils.get_inheritance_list(Goblin).has("Node") == true
	
	# Easily check for an array, regardless of type
	VariantUtils.is_any_array(my_packed_array) == true
	
	# Check for a collection, be it and array or dictionary
	VariantUtils.is_collection(maybe_a_dictionary) == true
	
	# Easly find information from nodes inside a scene file
	PackedSceneUtils.get_node_name(GOBLIN_SCENE) == "Goblin"
	PackedSceneUtils.get_node_type(GOBLIN_SCENE) == Sprite2D
	PackedSceneUtils.get_script_type(GOBLIN_SCENE) == Goblin
	PackedSceneUtils.get_scene_instance(HOBGOBLIN_SCENE) == GOBLIN_SCENE
	PackedSceneUtils.is_class_of(GOBLIN_SCENE, Character)
	PackedSceneUtils.is_class_of(GOBLIN_SCENE, Node2D)
	
	# Deep dive into available groups, signals, methods, properties and values.
	PackedSceneUtils.has_groups(GOBLIN_SCENE, required_items)
	PackedSceneUtils.has_signals(GOBLIN_SCENE, required_items)
	PackedSceneUtils.has_methods(GOBLIN_SCENE, required_items)
	PackedSceneUtils.has_properties(GOBLIN_SCENE, required_items)
	PackedSceneUtils.has_properties_with_values(GOBLIN_SCENE, required_items)
