@tool
class_name MainScene
extends Node


## Scene must be of type Goblin
@export var typed_scene : PackedScene :
	get:
		return typed_scene
	set(value):
		if(PackedSceneValidator.is_class_of(
				self,
				"typed_scene",
				value,
				Goblin)):
			typed_scene = value
			update_configuration_warnings()


## Scene must be tagged 'Enemy' and 'Damageable'
@export var tagged_scene : PackedScene :
	get:
		return tagged_scene
	set(value):
		if PackedSceneValidator.has_properties_with_values(
				self,
				"tagged_scene",
				value,
				{ "metadata/Tags": [ "Enemy","Damageable" ]}):
			tagged_scene = value
			update_configuration_warnings()


## Scene must implement IEnemy and IDamageable
@export var interfaced_scene : PackedScene :
	get:
		return interfaced_scene
	set(value):
		if PackedSceneValidator.has_interfaces(
				self,
				"interfaced_scene",
				value,
				[ IEnemy, IDamageable ]):
			interfaced_scene = value
			update_configuration_warnings()


func _get_configuration_warnings():
	var warning_messages : Array[String] = [ ]
	
	if(not typed_scene):
		warning_messages.append("Typed Scene: No scene selected")
	
	if(not tagged_scene):
		warning_messages.append("Tagged Scene: No scene selected")
	
	if(not interfaced_scene):
		warning_messages.append("Interfaced Scene: No scene selected")
	
	return warning_messages


func _ready():
	# Run unit tests on startup
	add_child(UnitTests.new())
