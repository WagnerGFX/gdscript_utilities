@tool
extends Node
## [GDScriptUtilities]
## The Plugin's core. Accessible as an autoloaded node.
##
## - Holds data related to the Native Classes available in GDScript.
## [br]- Caches class names, but loads instance IDs on every startup to avoid invalid values.

const NAME_AUTOLOAD := "GDScriptUtilities"
const NAME_MENU_RELOADCACHE := "Reload GDScript Utilities Cache"

const PATH_PLUGIN_DIRECTORY := "res://addons/gdscript_utilities"
const PATH_PLUGIN_SETTINGS := "plugins/gdscript_utilities"
const PATH_PLUGIN_AUTOLOAD := PATH_PLUGIN_DIRECTORY +"/scripts/gdscript_utilities.gd"
const PATH_PLUGIN_EDITOR := PATH_PLUGIN_DIRECTORY +"/gdscript_utilities_plugin.gd"
const PATH_SETTINGS_PRINT_INTERNAL_MSG := PATH_PLUGIN_SETTINGS + "/print_internal_messages"


## Check if log messages are allowed inside this plugin.
## [br]Change in the Project Settings > Plugins > [Plugin Name]
var can_print_internal_messages: bool:
	get:
		return ProjectSettings.get_setting(PATH_SETTINGS_PRINT_INTERNAL_MSG, true)


var _default_value : DefaultValue
## Direct access to the cache. Use [member DefaultValue.instance] instead.
var default_value : DefaultValue:
	get:
		return _default_value


var _native_classes : Dictionary
## A dictionary containing a cache of the engine's valid native classes.
## [br]Key = instance_id  | Value = class name
var native_classes : Dictionary:
	get:
		return _native_classes


func _ready() -> void:
	_load_default_value_cache()
	_load_native_class_cache()


func _load_default_value_cache():
	_default_value = DefaultValue.new()


# Load a dictionary of all available native class types.
func _load_native_class_cache():
	var internal_classes_count : int = 0
	var disabled_classes_count : int = 0

	_native_classes.clear()
	
	for native_class_name in ClassDB.get_class_list():
		if not ClassDB.is_class_enabled(native_class_name):
			disabled_classes_count += 1
			continue
		
		if not ClassDB.is_class_exposed(native_class_name):
			internal_classes_count += 1
			continue
		
		var native_class_obj := ClassUtils.get_type_unsafe(native_class_name)
		
		if native_class_obj:
			_native_classes[native_class_obj.get_instance_id()] = native_class_name
	
	if can_print_internal_messages:
		print("Loaded ClassDB references [Exposed:%s, Internal:%s, Disabled:%s]" % [_native_classes.size(), internal_classes_count, disabled_classes_count])


## Return true if the current engine version is equal or newer compared to the values provided
func is_engine_version_equal_or_newer(major:int, minor:int = 0, patch:int = 0) -> bool:
	var result = compare_to_engine_version(major, minor, patch)
	return result >= 0


## Return true if the current engine version is older compared to the values provided
func is_engine_version_older(major:int, minor:int = 0, patch:int = 0) -> bool:
	var result = compare_to_engine_version(major, minor, patch)
	return result < 0

## Compares the current engine version with a provided version.
## [br]Returns 1 when engine is newer, 0 when equal, -1 when older.
func compare_to_engine_version(major: int, minor: int = 0, patch: int = 0) -> int:
	var current_version:Dictionary = Engine.get_version_info()
	var comparand:Array[int] = [current_version.major, current_version.minor, current_version.patch]
	var reference:Array[int] = [major, minor, patch]
	
	return compare_version_numbers(comparand, reference)

## Compare two versions that are based on the Sematinc Versioning system. Numbers only.
func compare_version_numbers(comparand: Array[int], reference:Array[int]) -> int:
	while comparand.size() < reference.size():
		comparand.append(0)

	while comparand.size() > reference.size():
		reference.append(0)
	
	var is_newer:int = signi(comparand > reference)
	var is_older:int = signi(comparand < reference)
	
	return is_newer - is_older

static func reload_cache():
	GDScriptUtilities._load_native_class_cache()
