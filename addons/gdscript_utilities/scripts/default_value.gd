@tool
class_name DefaultValue
extends Resource
## Represents unmodified default values from scene files.
##
## [PackedScene] files only save changed properties, default ones are evaluated only after
## instancing the Scene.
## [br][br]
## This class is then used to represent a property default value, to differentiate
## from [code]null[/code], that represents deleted property data.
## [br][br]
## For runtime variables, use [member instance] instead of creating new instances.
## That way, the comparison between two variables will always return [code]true[/code].
## [br][br]
## If you need to save the value to a file and reload it later, or need a safer
## comparison, then use [code](value is DefaultValue)[/code].

const _DISPLAY_NAME := "<default>"


## Will always return the same cached instance.
static var instance: DefaultValue:
	get:
		return GDScriptUtilities.default_value


func _to_string():
	return _DISPLAY_NAME
