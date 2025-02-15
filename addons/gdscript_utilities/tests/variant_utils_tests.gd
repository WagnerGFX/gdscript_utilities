@tool
class_name VariantUtilsTests
extends Node

func _ready() -> void:
	run_tests()
	queue_free()


func run_tests():
	assert_is_builtin()
	assert_is_collection()
	assert_collection_contains()
	assert_get_typed_array_name()
	assert_get_typed_dictionary_name()


func assert_is_builtin():
	const assertion_item := "VariantUtils.is_builtin() ## value and type"
	
	var test_object := TestObj.new()
	
	assert(not VariantUtils.is_value_builtin(Node))
	assert(not VariantUtils.is_value_builtin(Goblin))
	assert(not VariantUtils.is_value_builtin(Goblin.new()))
	assert(not VariantUtils.is_value_builtin(get_tree()))
	
	assert(VariantUtils.is_value_builtin(null))
	assert(VariantUtils.is_value_builtin(true))
	assert(VariantUtils.is_value_builtin(false))
	assert(VariantUtils.is_value_builtin(""))
	assert(VariantUtils.is_value_builtin("Node"))
	assert(VariantUtils.is_value_builtin(0))
	assert(VariantUtils.is_value_builtin(0.0))
	assert(VariantUtils.is_value_builtin([]))
	assert(VariantUtils.is_value_builtin(Vector3(0,0,0)))
	
	
	var test_func_variable = func(): pass
	assert(VariantUtils.is_value_builtin(test_func_variable))
	assert(VariantUtils.is_value_builtin(test_object.do_nothing))
	assert(VariantUtils.is_value_builtin(test_object.something_happened))
	
	assert(not VariantUtils.is_value_builtin(null, [TYPE_NIL]))
	assert(not VariantUtils.is_value_builtin(true, [TYPE_NIL, TYPE_BOOL]))
	assert(not VariantUtils.is_value_builtin(false, [TYPE_BOOL, TYPE_NIL]))
	assert(not VariantUtils.is_value_builtin([], [TYPE_ARRAY]))
	
	assert(not VariantUtils.is_value_builtin(test_object.do_nothing, [TYPE_CALLABLE]))
	assert(not VariantUtils.is_value_builtin(test_object.something_happened, [TYPE_SIGNAL]))
	
	
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_is_collection():
	const assertion_item := "VariantUtils.is_collection() ## value and type"
	
	var assert_collection = func(test_item, is_array: bool, is_dictionary: bool, is_collection: bool):
		assert(VariantUtils.is_value_any_array(test_item) == is_array, assertion_item)
		assert(VariantUtils.is_value_dictionary(test_item) == is_dictionary, assertion_item)
		assert(VariantUtils.is_value_collection(test_item) == is_collection, assertion_item)
	
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


func assert_get_typed_array_name():
	const assertion_item := "VariantUtils._get_typed_array_name()"
	
	assert(VariantUtils._get_typed_array_name([]) == type_string(TYPE_ARRAY), assertion_item)
	
	var assert_typed_array = func(array_value, type_used : String):
		var expected_name = "%s[%s]" % [type_string(TYPE_ARRAY), type_used]
		var assertion_message = "%s | %s" % [assertion_item, type_used]
		assert(VariantUtils._get_typed_array_name(array_value) == expected_name, assertion_message)
	
	assert_typed_array.call([] as Array[String], type_string(TYPE_STRING))
	assert_typed_array.call([] as Array[bool], type_string(TYPE_BOOL))
	assert_typed_array.call([] as Array[int], type_string(TYPE_INT))
	assert_typed_array.call([] as Array[Array], type_string(TYPE_ARRAY))
	assert_typed_array.call([] as Array[Callable], type_string(TYPE_CALLABLE))
	assert_typed_array.call([] as Array[Signal], type_string(TYPE_SIGNAL))
	
	assert_typed_array.call([] as Array[Node], "Node")
	assert_typed_array.call([] as Array[RefCounted], "RefCounted")
	assert_typed_array.call([] as Array[Object], "Object")
	assert_typed_array.call([] as Array[Goblin], "Goblin")
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_get_typed_dictionary_name():
	const assertion_item := "VariantUtils._get_typed_dictionary_name()"
	
	assert(VariantUtils._get_typed_dictionary_name({}) == type_string(TYPE_DICTIONARY), assertion_item)
	
	if GDScriptUtilities.is_engine_version_equal_or_newer(4,4):
		# This is necessary to not break in previous versions
		const script_body := "static func get_typed_dictionary(): return {} as Dictionary[%s,%s]"
		var script_instance := GDScript.new()
	
		var assert_typed_dictionary = func(key_type : String, value_type : String):
			var assertion_message = "%s | [%s,%s]" % [assertion_item, key_type, value_type]
			
			script_instance.set_source_code(script_body % [key_type, value_type])
			var error := script_instance.reload()
			var typed_dict_value
			
			if error == OK:
				typed_dict_value = script_instance.get_typed_dictionary()
				var result_name = VariantUtils._get_typed_dictionary_name(typed_dict_value)
				var expected_name = "%s[%s,%s]" % [type_string(TYPE_DICTIONARY), key_type, value_type]
				assert(result_name == expected_name, assertion_message)
			else:
				assert(false, assertion_message)
		
		for type_id in range(1, TYPE_MAX):
			assert_typed_dictionary.call(type_string(TYPE_INT), type_string(type_id))
		
		for type_id in range(1, TYPE_MAX):
			assert_typed_dictionary.call(type_string(type_id), type_string(TYPE_STRING))
		
		assert_typed_dictionary.call(ClassUtils.get_type_name(RefCounted), ClassUtils.get_type_name(Node))
		assert_typed_dictionary.call(ClassUtils.get_type_name(Node), ClassUtils.get_type_name(GDScript))
		assert_typed_dictionary.call(ClassUtils.get_type_name(GDScript), ClassUtils.get_type_name(Character))
		assert_typed_dictionary.call(ClassUtils.get_type_name(Character), ClassUtils.get_type_name(Goblin))
		assert_typed_dictionary.call(ClassUtils.get_type_name(Goblin), ClassUtils.get_type_name(Orc))
	
	UnitTests.print_assertion_passed(assertion_item)
