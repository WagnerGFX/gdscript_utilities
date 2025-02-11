class_name InterfaceNames
## Set interface names as const properties to ease their use with GDScript Interfaces Plugin.
##
## Avoid the need to use [code]preload()[/code] in other scripts.
## [br][br]Example:
## [codeblock lang=gdscript]
## const implements = [InterfaceNames.I_Enemy, InterfaceNames.I_Damageable]
## [/codeblock]

const _INTERFACES_PATH := GDScriptUtilities.PATH_PLUGIN_DIRECTORY + "/examples/interfaces"

const I_Enemy := preload(_INTERFACES_PATH + "/i_enemy.gd")
const I_Damageable := preload(_INTERFACES_PATH + "/i_damageable.gd")
