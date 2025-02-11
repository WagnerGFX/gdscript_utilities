@tool
class_name GDScriptUtilitiesEditorPlugin
extends EditorPlugin
## The Editor side of the GDScript Utilities Plugin.
##
## Setup plugin settings, add menus options and executes any editor only code.

var gdscript_utilities := preload("res://addons/gdscript_utilities/scripts/gdscript_utilities.gd")

func _enter_tree():
	_create_project_settings()
	add_tool_menu_item(gdscript_utilities.NAME_MENU_RELOADCACHE, _show_reload_cache_popup)


func _exit_tree():
	remove_tool_menu_item(gdscript_utilities.NAME_MENU_RELOADCACHE)


func _enable_plugin():
	add_autoload_singleton(gdscript_utilities.NAME_AUTOLOAD, gdscript_utilities.PATH_PLUGIN_AUTOLOAD)


func _disable_plugin():
	remove_autoload_singleton(gdscript_utilities.NAME_AUTOLOAD)


# Isolated to avoid Editor references on exported projects
static func refresh_filesystem(filepath: String):
	while EditorInterface.get_resource_filesystem().is_scanning():
		await EditorInterface.get_resource_filesystem().filesystem_changed
	EditorInterface.get_resource_filesystem().update_file(filepath)


func _create_project_settings():
	if not ProjectSettings.has_setting(gdscript_utilities.PATH_SETTINGS_PRINT_INTERNAL_MSG):
		var property_info := {
			"name": gdscript_utilities.PATH_SETTINGS_PRINT_INTERNAL_MSG,
			"type": TYPE_BOOL,
		}
		
		ProjectSettings.add_property_info(property_info)
		ProjectSettings.set_setting(gdscript_utilities.PATH_SETTINGS_PRINT_INTERNAL_MSG, true)


func _show_reload_cache_popup():
	var option_dialog = AcceptDialog.new()
	option_dialog.title = gdscript_utilities.NAME_MENU_RELOADCACHE
	option_dialog.dialog_text = "Force complete reload?"
	option_dialog.ok_button_text = "Yes"
	option_dialog.add_button("No", true, "denied")
	option_dialog.add_cancel_button("Cancel")
	
	option_dialog.confirmed.connect(func():
		gdscript_utilities.reload_cache(true))
	
	option_dialog.custom_action.connect(func(action_name: String):
		option_dialog.visible = false
		gdscript_utilities.reload_cache(false))
	
	EditorInterface.popup_dialog_centered(option_dialog)
