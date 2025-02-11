@tool
class_name ClassUtils
## Provides utility functions to handle types directly, instead of instances or variables.
##
## This class supports user-created [Script]s and Native Classes like [Object], [Resource] and [Node].
## [br]Scripts without class_name, as inner classes or generated in runtime are [b]NOT[/b] supported,
## they will probably show as a basic type, like [RefCounted] or [GDScript].
## [br]Only Native Classes exposed to GDScript are supported.

const _SCRIPT_BODY := "static func eval(): return %s"

static var _script : GDScript = GDScript.new()


## Returns the inheritance tree of a class type reference or name.
static func get_inheritance_list(class_type, include_self: bool = false) -> Array[String]:
	var final_class_name : String
	
	if class_type is String:
		final_class_name = class_type
	
	elif class_type is Script or class_type is Object:
		final_class_name = get_type_name(class_type)
	
	# Script name > Base Script name > Base Native Class name
	if final_class_name == "" and class_type is Script:
		include_self = true
		var base_script = class_type.get_base_script()
		
		if base_script:
			final_class_name = get_type_name(base_script)
		else:
			final_class_name = class_type.get_instance_base_type()
	
	var inheritance_list : Array[String]
	if include_self:
		inheritance_list.append(final_class_name)
	
	# Search custom script
	var keep_searching := true
	var parent_script := final_class_name
	
	while keep_searching:
		keep_searching = false
		
		for inner_script in ProjectSettings.get_global_class_list():
			if inner_script["class"] == parent_script:
				parent_script = inner_script["base"]
				inheritance_list.append(parent_script)
				keep_searching = true
				break
	
	# Search native node classes
	keep_searching = true
	
	while keep_searching:
		keep_searching = false
		parent_script = ClassDB.get_parent_class(parent_script)
		
		if not parent_script == "":
			inheritance_list.append(parent_script)
			keep_searching = true
	
	return inheritance_list


## Returns the type name of any given type or it's instance.
## [br][br][param obj]: Accepts anything other than built-in Variant types directly.
## [br] This includes Native Classes, user-defined Scripts,
## instances of Node/Resource or any Variant value, including [code]null[/code].
static func get_type_name(obj) -> String:
	var class_type_name : String
	
	if (obj is Node or obj is Resource) and obj.get_script():
		obj = obj.get_script()
	
	if obj is GDScript:
		if obj.has_method("get_global_name"): # Godot v4.3+
			class_type_name = obj.get_global_name()
		else:
			for inner_script in ProjectSettings.get_global_class_list():
				if inner_script["path"] == obj.resource_path:
					class_type_name = inner_script["class"]
					break
		
		if class_type_name.is_empty():
			class_type_name = obj.get_class()
		
	elif obj is Object and is_native(obj):
		class_type_name = GDScriptUtilities.native_classes.get((obj as Object).get_instance_id(), "")
		
	elif obj is Object:
		class_type_name = obj.get_class()
		
	else:
		class_type_name = type_string(typeof(obj))
	
	return class_type_name


## Returns an [Object] that represents the type of a Native Class or user-defined Script.
## [br]It produces a result similar to [code]var class_type = Node as Object[/code].
static func get_type(classname: String) -> Object:
	var result : Object
	
	if is_script(classname):
		for inner_script in ProjectSettings.get_global_class_list():
			if inner_script["class"] == classname:
				result = load(inner_script["path"])
				break
		
	elif ClassDB.class_exists(classname) and ClassDB.is_class_enabled(classname):
		result = get_type_unsafe(classname)
	
	return result


## Used by [method get_type] and core plugin features. Executes with minimal validation.
static func get_type_unsafe(classname: String) -> Object:
	_script.set_source_code(_SCRIPT_BODY % classname)
	var error := _script.reload()
	var result : Object
	
	if error == OK:
		result = _script.eval()
	
	return result


## Checks if [param class_type] is the same or inherits from [param base_class_type].
## [br]Similar to [method Object.is_class], but searches the entire inheritance,
## including Native Classes and user-created Scripts.
## [br][br]Both parameters accept String names, instances and types of Scripts or Native Classes.
static func is_class_of(class_type, base_class_type) -> bool:
	var class_type_name : String
	if class_type is String:
		class_type_name = class_type
	elif class_type is Object:
		class_type_name = get_type_name(class_type)
	else:
		return false
	
	var base_class_type_name := ""
	if base_class_type is String:
		base_class_type_name = base_class_type
	elif base_class_type is Object:
		base_class_type_name = get_type_name(base_class_type)
	else:
		return false
	
	if not is_valid(class_type_name) or not is_valid(base_class_type_name):
		return false
	
	var inheritance_list := get_inheritance_list(class_type_name, true)
	return inheritance_list.has(base_class_type_name)


## Checks if [param class_type] is a reference or name that represents a valid Native Class.
static func is_native(class_type) -> bool:
	if not class_type: return false
	
	if class_type is String:
		return ClassDB.class_exists(class_type) and ClassDB.is_class_enabled(class_type)
	elif class_type is Object and (class_type as Object).get_class() == "GDScriptNativeClass":
		return true
	else:
		return false


## Checks if a [param class_type] is a reference or name that matches an existing user-defined Script.
## Similar to [code]is GDScript[/code], but also accepts string names.
static func is_script(script) -> bool:
	var script_name : String
	
	if script is GDScript:
		return true
	elif script is String:
		script_name = script

	if not script or script_name.is_empty():
		return false
	
	var result := false
	for inner_script in ProjectSettings.get_global_class_list():
		if inner_script["class"] == script_name:
			result = true
			break
	
	return result


## Checks if a string represents an existing Native Class or user-defined Script
static func is_valid(classname: String) -> bool:
	return is_script(classname) or is_native(classname)
