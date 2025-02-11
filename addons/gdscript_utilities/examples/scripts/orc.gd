class_name Orc
extends Sprite2D
## Example script with the same structure of Goblin, but no relationship or inheritance path
## [br]Created to unit test [PackedSceneUtils].

@export var health : int
@export var attack : int = 10
@export var defense : int = 15

static var can_jump := true
var is_magical := false


func receive_damage(damage :int) -> void:
	health -= maxi(damage - defense, 0)


func apply_damage(modifier : float) -> int:
	return floor(attack * modifier)
