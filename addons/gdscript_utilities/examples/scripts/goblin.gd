class_name Goblin
extends Character

const implements = [InterfaceNames.I_Enemy, InterfaceNames.I_Damageable]

@export var health : int
@export var attack : int = 5
@export var defense : int = 10

static var can_jump := false
var is_magical := true


func receive_damage(damage :int):
	health -= maxi(damage - defense, 0)


func apply_damage(modifier : float) -> int:
	return floor(attack * modifier)
