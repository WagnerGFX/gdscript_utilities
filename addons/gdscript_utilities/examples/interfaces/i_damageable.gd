class_name IDamageable
extends Node

var health : int

func receive_damage(damage :int):
	health -= damage
