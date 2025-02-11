@tool
class_name VariantUtilsTests
extends Node

func _ready() -> void:
	run_tests()
	queue_free()


func run_tests():
	assert_is_collection()
	assert_collection_contains()


func assert_is_collection():
	const assertion_item := "VariantUtils.is_collection()"
	
	var assert_collection = func(test_item, is_array: bool, is_dictionary: bool, is_collection: bool):
		assert(VariantUtils.is_any_array(test_item) == is_array, assertion_item)
		assert(VariantUtils.is_dictionary(test_item) == is_dictionary, assertion_item)
		assert(VariantUtils.is_collection(test_item) == is_collection, assertion_item)
	
	var test
	
	test = null
	assert_collection.call(test, false, false, false)
	
	test = "Array()"
	assert_collection.call(test, false, false, false)
	
	test = 0
	assert_collection.call(test, false, false, false)
	
	test = 0.0
	assert_collection.call(test, false, false, false)
	
	test = true
	assert_collection.call(test, false, false, false)
	
	test = false
	assert_collection.call(test, false, false, false)
	
	test = Object
	assert_collection.call(test, false, false, false)
	
	test = Goblin
	assert_collection.call(test, false, false, false)
	
	test = [ ]
	assert_collection.call(test, true, false, true)
	
	test = ["", ""] as Array[String]
	assert_collection.call(test, true, false, true)
	
	test = [0, 1] as Array[int]
	assert_collection.call(test, true, false, true)
	
	test = PackedStringArray()
	assert_collection.call(test, true, false, true)
	
	test = PackedInt32Array()
	assert_collection.call(test, true, false, true)
	
	test = Dictionary()
	assert_collection.call(test, false, true, true)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_collection_contains():
	const assertion_item := "VariantUtils._collection_contains()"
	
	var coll_data : Array = [
		"Orc",
		35,
		null,
		false,
		{	"type":Node,
			"value":self,
			true:"true",
		},
	]
	
	var coll_compare : Array = [
		false,
		{	true:"true",
		},
		"Orc",
	]
	assert(VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	
	coll_compare = [
		50,
		null,
		true,
		{	"type":Object,
			true:"false",
		},
	]
	assert(not VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	
	coll_compare = [ ]
	assert(VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	coll_compare = [{ }]
	assert(VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	coll_compare = [null]
	assert(VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	coll_compare = [null, { }]
	assert(VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	coll_compare = [{null:null}]
	assert(not VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	
	coll_compare = ["Orc"]
	assert(VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	coll_compare = [35]
	assert(VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	coll_compare = [false]
	assert(VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	
	coll_compare = [{true:"true"}]
	assert(VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	coll_compare = [{true:true}]
	assert(not VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	coll_compare = [{"type":Node}]
	assert(VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	coll_compare = [{"type":Object}]
	assert(not VariantUtils._collection_contains(coll_data, coll_compare), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)
