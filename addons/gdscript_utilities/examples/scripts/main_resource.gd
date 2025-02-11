@tool
class_name MainResource
extends Resource


## Scene must be of type Goblin
@export var typed_scene : PackedScene :
	get:
		return typed_scene
	set(value):
		if PackedSceneValidator.is_class_of(
				self,
				"typed_scene",
				value,
				Goblin):
			typed_scene = value


## Scene must be tagged 'Enemy' and 'Damageable' 
@export var tagged_scene : PackedScene :
	get:
		return tagged_scene
	set(value):
		if PackedSceneValidator.has_properties_with_values(
				self,
				"tagged_scene",
				value,
				{ "metadata/Tags" : [ "Enemy","Damageable" ] } ):
			tagged_scene = value


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
