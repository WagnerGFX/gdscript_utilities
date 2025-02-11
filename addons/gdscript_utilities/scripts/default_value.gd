@tool
class_name DefaultValue
extends Resource
## Represents unmodified default values from scene files.
##
## [PackedScene] files only save changed properties, default ones are evaluated only after
## instancing the Scene.
## [br][br]This class is then used to represent a property default value, to differentiate
## from [code]null[/code], that represents deleted property data.
## [br][br]Do [b]NOT[/b] instantiate this class, use [member instance] instead.
## That way, comparing default values will return [code]true[/code].


const _DISPLAY_NAME := "<default>"


## Will always return the same cached instance.
static var instance: DefaultValue:
	get:
		return GDScriptUtilities.default_value


func _to_string():
	return _DISPLAY_NAME
