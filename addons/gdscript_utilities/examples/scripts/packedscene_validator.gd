@tool
class_name PackedSceneValidator
## This class provides example functions to easily validate [PackedScene] files when they are assigned to an exported script property in the Inspector.
##
## [br]All methods will return [code]false[/code] during runtime, blocking changes.
## [br]All methods will return [code]true[/code] for [code]null[/code] scenes, allowing the property to be removed.
## [br][br]A debug message will be printed whenever an invalid scene is assigned.
## [br]The message will contain the property name, the tested scene file and a description of what the property is expecting.

const msg_invalid_scene_header := "[b][color=yellow][!][/color] Invalid Scene File: [/b]"
const msg_invalid_scene_body   := "\r\n     [b]-Property:[/b] %s\r\n     [b]-Scene:[/b]    '%s'"
const msg_invalid_scene_type   := "Root node or script must be of type [color=green]%s[/color] or inherit from it."
const msg_invalid_scene_meta   := "Root node properties must contain [color=green]%s[/color]."
const msg_invalid_scene_inter  := "Root node script must implement [color=green]%s[/color] as interfaces."


## Validates the type of the root node or script.
static func is_class_of(obj_owner: Object, obj_property_name: String, scene: PackedScene, class_type) -> bool:
	if not Engine.is_editor_hint():
		return false
	elif not scene:
		return true
	
	var is_valid = PackedSceneUtils.is_class_of(scene, class_type)
	
	if not is_valid:
		var class_type_name :String
		if class_type is String:
			class_type_name = class_type
		else:
			class_type_name = ClassUtils.get_type_name(class_type)
			
		var message = msg_invalid_scene_header + msg_invalid_scene_type + msg_invalid_scene_body
		message = message % [class_type_name, _get_object_path(obj_owner, obj_property_name), scene.resource_path]
		print_rich(message)
	
	return is_valid


## Validates the implementation of interfaces (GDScript Interfaces Plugin is recommended)
## [br][param required_interfaces] must be an array containing direct references to script types.
static func has_interfaces(obj_owner: Object, obj_property_name: String, scene: PackedScene, required_interfaces: Array) -> bool:
	if not Engine.is_editor_hint():
		return false
	elif not scene:
		return true
	
	var is_valid = PackedSceneUtils.has_properties_with_values(scene, {"implements":required_interfaces})
	
	if not is_valid:
		var string_interfaces : Array[String]
		for item in required_interfaces:
			string_interfaces.append(ClassUtils.get_type_name(item))
		
		var message = msg_invalid_scene_header + msg_invalid_scene_inter + msg_invalid_scene_body
		message = message %  [string_interfaces, _get_object_path(obj_owner, obj_property_name), scene.resource_path]
		print_rich(message)
	
	return is_valid


## Validates the PackedScene's property names and values (when available)(nulls are skipped).
static func has_properties_with_values(obj_owner: Object, obj_property_name: String, scene: PackedScene, properties: Dictionary) -> bool:
	if not Engine.is_editor_hint():
		return false
	elif not scene:
		return true
	
	var is_valid = PackedSceneUtils.has_properties_with_values(scene, properties)
	
	if not is_valid:
		var message = msg_invalid_scene_header + msg_invalid_scene_meta + msg_invalid_scene_body
		message = message % [properties, _get_object_path(obj_owner, obj_property_name), scene.resource_path]
		print_rich(message)
	
	return is_valid


static func _get_object_path(obj: Object, property: String) -> String:
	var obj_path : String
	
	if obj is Node:
		if obj.owner:
			obj_path = _get_name_in_path(obj.owner.scene_file_path) + obj.owner.name +  "/" + str(obj.owner.get_path_to(obj, false))
		else:
			obj_path = _get_name_in_path(obj.scene_file_path) + obj.name
	
	elif obj is Resource:
		obj_path = "'%s'" % obj.resource_path
		
	return obj_path + " : " + property


static func _get_name_in_path(path: String) -> String:
	var file_name : String
	
	if path.is_empty():
		file_name = "unsaved"
	else:
		file_name = path.split("/")[-1]
	
	return "[%s] " % file_name
