@tool
class_name PackedSceneUtils
## This class provides utility functions to simplify the process of reading information from the
## nodes inside a [PackedScene] file without the need to instantiate it.
##  
## These functions look into the scene's root node to:
## [br] - Get: Node Type, Script Type, Groups, Signals, Methods, Properties, Values and inner Scenes.
## [br] - Check for valid data on most information above.

const KEY_METADATA := "metadata"
const KEY_NAME := "name"
const KEY_SCRIPT := "script"
const KEY_TYPE := "type"
const KEY_USAGE := "usage"
const KEY_VALUE := "value"


## Returns the node's groups.
## [br][br][param node_idx]: uses the root node by default.
static func get_groups(scene: PackedScene, node_idx: int = 0) -> PackedStringArray:
	var scene_state := scene.get_state()
	var node_groups := scene.get_state().get_node_groups(node_idx)
	
	var base_scene : PackedScene = scene_state.get_node_instance(node_idx)
	if base_scene:
		node_groups.append_array(get_groups(base_scene))
	
	return node_groups


## Returns all methods from the Node and Script types.
## [br][br][param node_idx]: uses the root node by default.
static func get_methods(scene: PackedScene, node_idx: int = 0) -> Dictionary:
	var scene_methods_raw := ClassDB.class_get_method_list(get_node_type_name(scene, node_idx))
	
	var script_type := get_script_type(scene, node_idx)
	if script_type:
		scene_methods_raw.append_array(script_type.get_script_method_list())
	
	var scene_methods : Dictionary
	for item in scene_methods_raw:
		var method_name = item[KEY_NAME]
		scene_methods[method_name] = item
	
	return scene_methods


## Returns the node name, as shown in the scene hierarchy.
## [br][br][param node_idx]: uses the root node by default.
static func get_node_name(scene: PackedScene, node_idx: int = 0) -> String:
	return scene.get_state().get_node_name(node_idx)


## Returns the Node type.
## [br][br][param node_idx]: uses the root node by default.
static func get_node_type(scene: PackedScene, node_idx: int = 0) -> Object:
	return ClassUtils.get_type(get_node_type_name(scene, node_idx))


## Returns a string with the Node type name.
## [br][br][param node_idx]: uses the root node by default.
static func get_node_type_name(scene: PackedScene, node_idx: int = 0) -> String:
	var scene_state := scene.get_state()
	var node_type := scene.get_state().get_node_type(node_idx)
	
	var base_scene : PackedScene = scene_state.get_node_instance(node_idx)
	if node_type.is_empty() and base_scene:
		node_type = get_node_type_name(base_scene)
	
	return node_type


## Returns a dictionary with property names from Node and Script types.
## [br]Keys will contain the names of:
## [br]  - Node properties with usage: [constant PROPERTY_USAGE_NONE], [constant PROPERTY_USAGE_STORAGE], [constant PROPERTY_USAGE_EDITOR]
## [br]  - Script constants.
## [br]  - Script variables with usage: [constant PROPERTY_USAGE_SCRIPT_VARIABLE]
## [br]  - Scene Metadata.
## [br]Values will contain:
## [br]  - Node and Script variables: A [Dictionary] with property definitions.
## [br]  - Constants, Metadata, etc: The type name when [Object], or a [enum Variant.Type] for anything else.
## [br][br][param node_idx]: uses the root node by default.
static func get_properties(scene: PackedScene, node_idx: int = 0) -> Dictionary:
	var scene_properties : Dictionary
	
	# Inner function: identify 
	var get_property_type = func get_property_type(value):
		if typeof(value) == TYPE_OBJECT:
			return ClassUtils.get_type_name(value)
		else:
			return typeof(value)
	

	# Node Type properties
	var scene_properties_node := ClassDB.class_get_property_list(get_node_type_name(scene, node_idx))
	
	for item in scene_properties_node:
		var prop_name : String = item[KEY_NAME]
		var prop_usage : int = item[KEY_USAGE]
		var is_none := prop_usage == PROPERTY_USAGE_NONE
		var is_storage := prop_usage & PROPERTY_USAGE_STORAGE == PROPERTY_USAGE_STORAGE
		var is_editor := prop_usage & PROPERTY_USAGE_EDITOR == PROPERTY_USAGE_EDITOR
		
		if is_none or is_storage or is_editor:
			scene_properties[prop_name] = item
	
	# Script properties
	var script_type := get_script_type(scene, node_idx)
	
	if script_type:
		var script_name = ClassUtils.get_type_name(script_type)
		
		if script_name.is_empty():
			scene_properties[KEY_SCRIPT] = ClassUtils.get_type_name(Script)
		else:
			scene_properties[KEY_SCRIPT] = script_name
		
		var script_constants : Dictionary = script_type.get_script_constant_map()
		
		for key in script_constants:
			scene_properties[key] = get_property_type.call(script_constants[key])
		
		var script_properties_raw : Array[Dictionary]
		script_properties_raw.append_array(script_type.get_property_list())
		script_properties_raw.append_array(script_type.get_script_property_list())
		
		for item in script_properties_raw:
			var prop_name : String = item[KEY_NAME]
			var prop_usage : int = item[KEY_USAGE]
			var is_var := prop_usage & PROPERTY_USAGE_SCRIPT_VARIABLE == PROPERTY_USAGE_SCRIPT_VARIABLE
			if is_var:
				scene_properties[prop_name] = item
	
	# Scene Metadata properties
	var get_metadata_properties = func get_metadata_properties(metadata_scene, recursive_function, metadata_node_idx : int = 0) -> Dictionary:
		var metadata_properties : Dictionary = { }
		var scene_state = metadata_scene.get_state()
		var base_scene : PackedScene = scene_state.get_node_instance(metadata_node_idx)
		
		if base_scene:
			var base_properties : Dictionary = recursive_function.call(base_scene, recursive_function)
			
			for base_key:String in base_properties:
				if base_key.begins_with(KEY_METADATA):
					metadata_properties[base_key] = get_property_type.call(base_properties[base_key])
		
		for i in range(scene_state.get_node_property_count(metadata_node_idx)):
			var property_name = scene_state.get_node_property_name(metadata_node_idx, i)
			var property_value = scene_state.get_node_property_value(metadata_node_idx, i)
			
			if property_name.begins_with(KEY_METADATA):
				scene_properties[property_name] = get_property_type.call(property_value)
			
		return metadata_properties
		
	var metadata_properties : Dictionary = get_metadata_properties.call(scene, get_metadata_properties, node_idx)
	scene_properties.merge(metadata_properties, true)
	
	return scene_properties


## Returns all properties of the Node, Script and scene metadata with their corresponding value and data type.
## [br]  - Keys: property names following the description of [method get_properties]
## [br]  - Values: A dictionary containing:
## [br]    - "value": A reference to [DefaultValue] when not set or the actual value otherwise.
## [br]    - "type":  The class name when the value is an [Object], or a [enum Variant.Type] for anything else.
## [br][br][b]Limitations:[/b]
## [br]  - Default values for nodes and script variables are not available without instancing the
##         scene, they are replaced with a [DefaultValue] reference to differentiate from [code]null[/code] values.
## [br]  - As an alternative, use [Script] constants, [Resource] references or [Node] metadata
##         for guaranteed values.
## [br]  - Inheriting a scene while using a different script with the same property name,
##         but of a different type, may not return correct values.
## [br][br][param node_idx]: uses the root node by default.
## @experimental: Some values are not garanteed. Read the [b]Limitations[/b].
static func get_properties_and_values(scene: PackedScene, node_idx: int = 0) -> Dictionary:
	var scene_state := scene.get_state()
	var scene_script = get_script_type(scene, node_idx)
	var result_properties : Dictionary
	
	# (1) Get Node, Script and Metadata property names
	var scene_properties := get_properties(scene, node_idx)
	
	for property_key in scene_properties:
		var item_type
		if VariantUtils.is_dictionary(scene_properties[property_key]):
			item_type = scene_properties[property_key][KEY_TYPE]
		else:
			item_type = scene_properties[property_key]
		
		result_properties[property_key] = {KEY_VALUE:DefaultValue.instance, KEY_TYPE:item_type}
	
	# (2) Merge with base scene values
	var base_scene : PackedScene = scene_state.get_node_instance(node_idx)
	
	if base_scene:
		var base_values := get_properties_and_values(base_scene)
		
		for base_key in base_values:
			# Copy values even if the scripts are different.
			# But only if the values are of the same type.
			if result_properties.has(base_key) and not base_key == KEY_SCRIPT:
				var is_same_type = result_properties[base_key][KEY_TYPE] == base_values[base_key][KEY_TYPE]
				
				if is_same_type:
					result_properties[base_key][KEY_VALUE] = base_values[base_key][KEY_VALUE]
	
	# (3) Merge with current scene values
	for i in range(scene_state.get_node_property_count(node_idx)):
		var property_name = scene_state.get_node_property_name(node_idx, i)
		var property_value = scene_state.get_node_property_value(node_idx, i)
		
		if not property_name == KEY_SCRIPT:
			result_properties[property_name][KEY_VALUE] = property_value
	
	# (4) Apply script reference and constant values
	if scene_script:
		result_properties[KEY_SCRIPT][KEY_VALUE] = scene_script
		var const_values = scene_script.get_script_constant_map()
		
		for const_key in const_values:
			result_properties[const_key][KEY_VALUE] = const_values[const_key]
	
	return result_properties


## Return the scene instance (sub-scene, or inherited scene for the root node).
## [br][br][param node_idx]: uses the root node by default.
static func get_scene_instance(scene: PackedScene, node_idx: int = 0) -> PackedScene:
	var scene_state := scene.get_state()
	var base_scene : PackedScene = scene_state.get_node_instance(node_idx)
	return base_scene


## Return all scene instances (sub-scenes).
## [br][br][param include_root]: By default, will not include the inherited scene.
static func get_scene_instances(scene: PackedScene, include_root: bool = false) -> Array[PackedScene]:
	var scene_state := scene.get_state()
	var scene_instances : Array[PackedScene]
	
	var range_start = 0 if include_root else 1
	for i in range(range_start, scene_state.get_node_count()):
		var instance = scene_state.get_node_instance(i)
		if instance:
			scene_instances.append(instance)
	
	# If instances are empty, search in the base scene
	var base_scene : PackedScene = scene_state.get_node_instance(0)
	if base_scene and scene_instances.is_empty():
		scene_instances = get_scene_instances(base_scene)
	
	return scene_instances


## Returns the node's Script type.
## [br][br][param node_idx]: uses the root node by default.
static func get_script_type(scene : PackedScene, node_idx: int = 0) -> Script:
	var scene_state := scene.get_state()
	var property_exists := false
	var node_script : Script
	
	for i in range(scene.get_state().get_node_property_count(node_idx)):
		if scene.get_state().get_node_property_name(node_idx, i) == KEY_SCRIPT:
			property_exists = true #if node_script is null, then the script was removed
			node_script = scene.get_state().get_node_property_value(node_idx, i)
			break
	
	# script might be in the base scene
	var base_scene : PackedScene = scene_state.get_node_instance(node_idx)
	if not property_exists and base_scene:
		node_script = get_script_type(base_scene)
	
	return node_script


## Returns the node's Script name.
## [br][br][param node_idx]: uses the root node by default.
static func get_script_type_name(scene : PackedScene, node_idx: int = 0) -> String:
	var script_type = get_script_type(scene, node_idx)
	
	if script_type:
		return ClassUtils.get_type_name(script_type)
	else:
		return ""


## Returns all signals from the Node and Script types.
## [br][br][param node_idx]: uses the root node by default.
static func get_signals(scene: PackedScene, node_idx: int = 0) -> Dictionary:
	var scene_signals_raw := ClassDB.class_get_signal_list(get_node_type_name(scene, node_idx))
	
	var script_type := get_script_type(scene, node_idx)
	if script_type:
		scene_signals_raw.append_array(script_type.get_script_signal_list())
	
	var scene_signals : Dictionary
	for item in scene_signals_raw:
		var signal_name = item[KEY_NAME]
		scene_signals[signal_name] = item
	
	return scene_signals


## Checks a node for all groups supplied.
## [br][br][param node_idx]: uses the root node by default.
static func has_groups(scene: PackedScene, groups : Array[String], node_idx: int = 0) -> bool:
	if not scene:
		return false
		
	var scene_groups := get_groups(scene, node_idx)
	var is_valid := true
	
	for item in groups:
		if not scene_groups.has(item):
			is_valid = false
			break
	
	return is_valid


## Checks a node for all method names supplied.
## [br][br][param node_idx]: uses the root node by default.
static func has_methods(scene: PackedScene, methods : Array[String], node_idx: int = 0) -> bool:
	if not scene :
		return false
	
	var scene_methods := get_methods(scene, node_idx)
	var is_valid := true
	
	for item in methods:
		if not scene_methods.has(item):
			is_valid = false
			break
	
	return is_valid


## Checks a node for all property names supplied.
## [br][br][param node_idx]: uses the root node by default.
static func has_properties(scene: PackedScene, properties : Array[String], node_idx: int = 0) -> bool:
	if not scene:
		return false
	
	var scene_properties := get_properties(scene, node_idx)
	var is_valid := true
	
	for property_key in properties:
		if not scene_properties.has(property_key):
			is_valid = false
			break
	
	return is_valid


## Checks a node for all property names and values supplied.
## [br][br][b]Limitation:[/b]
## [br]    Default values for nodes and script variables are not available without instancing the
##         scene, they are replaced with a [DefaultValue] reference to differentiate from [code]null[/code] values.
## [br]    As an alternative, use [Script] constants, [Resource] references or [Node] metadata
##         for guaranteed values.
## [br][br][param node_idx]: uses the root node by default.
static func has_properties_with_values(scene: PackedScene, properties: Dictionary, node_idx: int = 0) -> bool:
	if not scene:
		return false
	
	if properties.is_empty():
		return true
	
	var scene_properties := get_properties_and_values(scene, node_idx)
	
	return VariantUtils._collection_contains(scene_properties, properties)


## Checks a node for all signal names supplied.
## [br][br][param node_idx]: uses the root node by default.
static func has_signals(scene: PackedScene, signals: Array[String], node_idx: int = 0) -> bool:
	if not scene :
		return false
	
	var scene_signals := get_signals(scene, node_idx)
	var is_valid := true
	
	for item in signals:
		if not scene_signals.has(item):
			is_valid = false
			break
	
	return is_valid


## Checks if the node Script is of a given Class or inherits from it.
## [br][br][param base_class]: accepts the class name or it's type reference.
## [br][param node_idx]: uses the root node by default.
static func is_class_of(scene: PackedScene, base_class, node_idx: int = 0) -> bool:
	if not scene or not base_class:
		return false
	
	var base_class_name : String
	
	if base_class is String:
		base_class_name = base_class
	elif base_class is Object:
		base_class_name = ClassUtils.get_type_name(base_class)
	
	var root_script = get_script_type(scene, node_idx)
	
	# Root Node has no script
	if not root_script:
		root_script = get_node_type_name(scene, node_idx)
	
	var script_inheritance := ClassUtils.get_inheritance_list(root_script, true)
	var result = script_inheritance.has(base_class_name)
	
	return result
