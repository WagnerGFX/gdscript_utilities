class_name IEnemy
extends Node

var attack : int

func apply_damage(modifier : float) -> int:
	return floor(attack * modifier)
