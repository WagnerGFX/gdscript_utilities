@tool
class_name UnitTests
extends Node

const ASSERTION_PASSED_MSG : String = "✔ Assertion passed: "

static var passed_assertions_count : int = 0


func _ready():
	add_sibling(ClassUtilsTests.new())
	add_sibling(VariantUtilsTests.new())
	add_sibling(PackedSceneUtilsTests.new())
	queue_free()


func _exit_tree() -> void:
	print("✔ Total assertions passed: ", passed_assertions_count)
	passed_assertions_count = 0


static func print_assertion_passed(assertion_item):
	print(ASSERTION_PASSED_MSG, assertion_item)
	passed_assertions_count += 1
