@tool
extends Node
## [GDScriptUtilities]
## The Plugin's core. Accessible as an autoloaded node.
##
## - Holds data related to the Native Classes available in GDScript.
## [br]- Caches class names, but loads instance IDs on every startup to avoid invalid values.

const NAME_AUTOLOAD := "GDScriptUtilities"
const NAME_MENU_RELOADCACHE := "Reload GDScript Utilities Cache"
const NAME_CACHE_GDVERSION := "GDVersion"
const NAME_CACHE_INVALIDCLASSES := "InvalidClasses"
const NAME_CACHE_DEFAULT_VALUE := "DefaultValue"

const PATH_PLUGIN_DIRECTORY := "res://addons/gdscript_utilities"
const PATH_PLUGIN_SETTINGS := "plugins/gdscript_utilities"
const PATH_PLUGIN_AUTOLOAD := PATH_PLUGIN_DIRECTORY +"/scripts/gdscript_utilities.gd"
const PATH_PLUGIN_EDITOR := PATH_PLUGIN_DIRECTORY +"/gdscript_utilities_plugin.gd"
const PATH_PLUGIN_CACHE_FILE := PATH_PLUGIN_DIRECTORY + "/plugin_cache.tres"
const PATH_SETTINGS_PRINT_INTERNAL_MSG := PATH_PLUGIN_SETTINGS + "/print_internal_messages"

# Invalid Classes that only exist during runtime
const RUNTIME_INVALID_CLASSES : Array[String] = [
	"RuntimeNodeSelect",
	]

## Check if log messages are allowed inside this plugin.
## [br]Change in the Project Settings > Plugins > [Plugin Name]
var can_print_internal_messages: bool:
	get:
		return ProjectSettings.get_setting(PATH_SETTINGS_PRINT_INTERNAL_MSG, true)


## Direct access to the cache. Use [member DefaultValue.instance] instead.
var default_value : DefaultValue:
	get:
		return _plugin_cache.get_meta(NAME_CACHE_DEFAULT_VALUE)


## Checks if the native classes were cached in the same version that the engine is currently running.
var is_class_cache_version_current : bool:
	get:
		var cached_version : String = _plugin_cache.get_meta(NAME_CACHE_GDVERSION, "")
		return cached_version != Engine.get_version_info().string


var _native_classes : Dictionary
## A dictionary containing a cache of the engine's valid native classes.
## [br]Key = instance_id  | Value = class name
var native_classes : Dictionary:
	get:
		return _native_classes


## A list containing a cache of the engine's native class names that are not accessible through GDScript.
var native_classes_invalid : Array:
	get:
		return _plugin_cache.get_meta(NAME_CACHE_INVALIDCLASSES, [])


var _plugin_cache : Resource


func _ready() -> void:
	_load_plugin_cache()
	_load_default_value_cache()
	_load_native_class_cache()


func _load_default_value_cache():
	if not _plugin_cache.has_meta(NAME_CACHE_DEFAULT_VALUE):
		_plugin_cache.set_meta(NAME_CACHE_DEFAULT_VALUE, DefaultValue.new())
		ResourceSaver.save(_plugin_cache)


# Load a dictionary of all available native class types. Will spam parse errors.
func _load_native_class_cache(reload: bool = false):
	var native_classes_error : Array[String]
	var errors_count : int = 0
	
	reload = reload or is_class_cache_version_current
	
	if reload:
		_native_classes.clear()
		native_classes_error += RUNTIME_INVALID_CLASSES
	else:
		native_classes_error = native_classes_invalid
		errors_count = native_classes_error.size()
	
	for native_class_name in ClassDB.get_class_list():
		var do_search := reload \
				or (not _native_classes.has(native_class_name) \
				and not native_classes_error.has(native_class_name))
		
		if do_search:
			var native_class_obj := ClassUtils.get_type_unsafe(native_class_name)
			
			if native_class_obj:
				_native_classes[native_class_obj.get_instance_id()] = native_class_name
			else:
				native_classes_error.append(native_class_name)
	
	if reload or errors_count < native_classes_error.size():
		_set_native_classes_invalid(native_classes_error)
	
	if can_print_internal_messages:
		print("Loaded ClassDB references [Accessible:%s, Inaccessible:%s]" % [_native_classes.size(), native_classes_error.size()])


func _load_plugin_cache():
	if not ResourceLoader.exists(PATH_PLUGIN_CACHE_FILE):
		ResourceSaver.save(Resource.new(), PATH_PLUGIN_CACHE_FILE)
		
		if Engine.is_editor_hint():
			var plugin_editor = load(PATH_PLUGIN_EDITOR)
			plugin_editor.refresh_filesystem(PATH_PLUGIN_CACHE_FILE)
	
	_plugin_cache = load(PATH_PLUGIN_CACHE_FILE)


func _set_native_classes_invalid(invalid_classes: Array):
		_plugin_cache.set_meta(NAME_CACHE_GDVERSION, Engine.get_version_info().string)
		_plugin_cache.set_meta(NAME_CACHE_INVALIDCLASSES, invalid_classes)
		ResourceSaver.save(_plugin_cache)


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

static func reload_cache(force_full_reload: bool):
	GDScriptUtilities._load_native_class_cache(force_full_reload)
