@tool
class_name ClassUtilsTests
extends Node


func _ready() -> void:
	run_tests()
	queue_free()


func run_tests():
	assert_get_inheritance_list()
	assert_get_type_name()
	assert_get_type()
	assert_is_native()
	assert_is_script()
	assert_is_valid()
	assert_is_class_of()


func assert_is_class_of():
	const assertion_item := "ClassUtils.is_class_of()"
	
	assert(not ClassUtils.is_class_of("",""), assertion_item)
	assert(not ClassUtils.is_class_of(null,null), assertion_item)
	assert(not ClassUtils.is_class_of("InvalidType","InvalidType"), assertion_item)
	assert(not ClassUtils.is_class_of("Object","InvalidType"), assertion_item)
	assert(not ClassUtils.is_class_of("Goblin","InvalidType"), assertion_item)
	
	assert(ClassUtils.is_class_of(Goblin, Goblin), assertion_item)
	assert(ClassUtils.is_class_of(Goblin, Character), assertion_item)
	assert(ClassUtils.is_class_of(Node, Node), assertion_item)
	assert(ClassUtils.is_class_of(Node2D, Node), assertion_item)
	assert(ClassUtils.is_class_of(Goblin, Sprite2D), assertion_item)
	assert(ClassUtils.is_class_of(Goblin, Node), assertion_item)
	assert(not ClassUtils.is_class_of(Sprite2D, Goblin), assertion_item)
	assert(not ClassUtils.is_class_of(Node, Goblin), assertion_item)
	assert(not ClassUtils.is_class_of(Goblin, Node3D), assertion_item)
	
	assert(ClassUtils.is_class_of("Goblin","Goblin"), assertion_item)
	assert(ClassUtils.is_class_of("Goblin","Character"), assertion_item)
	assert(ClassUtils.is_class_of("Node","Node"), assertion_item)
	assert(ClassUtils.is_class_of("Node2D", "Node"), assertion_item)
	assert(ClassUtils.is_class_of("Goblin","Sprite2D"), assertion_item)
	assert(ClassUtils.is_class_of("Goblin","Node"), assertion_item)
	assert(not ClassUtils.is_class_of("Sprite2D","Goblin"), assertion_item)
	assert(not ClassUtils.is_class_of("Node","Goblin"), assertion_item)
	assert(not ClassUtils.is_class_of("Goblin","Node3D"), assertion_item)
	
	assert(ClassUtils.is_class_of(MainScene, MainScene), assertion_item)
	assert(ClassUtils.is_class_of(MainResource, Resource), assertion_item)
	assert(ClassUtils.is_class_of(MainScene, Object), assertion_item)
	assert(not ClassUtils.is_class_of(Resource, MainResource), assertion_item)
	assert(not ClassUtils.is_class_of(Object, MainScene), assertion_item)
	assert(not ClassUtils.is_class_of(MainResource, Node), assertion_item)
	
	assert(ClassUtils.is_class_of("MainScene", "MainScene"), assertion_item)
	assert(ClassUtils.is_class_of("MainResource", "Resource"), assertion_item)
	assert(ClassUtils.is_class_of("MainScene", "Object"), assertion_item)
	assert(not ClassUtils.is_class_of("Resource", "MainResource"), assertion_item)
	assert(not ClassUtils.is_class_of("Object", "MainScene"), assertion_item)
	assert(not ClassUtils.is_class_of("MainResource", "Node"), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_is_script():
	const assertion_item := "ClassUtils.is_script()"
	
	assert(not ClassUtils.is_script(null), assertion_item)
	assert(not ClassUtils.is_script(""), assertion_item)
	assert(not ClassUtils.is_script("InvalidType"), assertion_item)
	
	assert(ClassUtils.is_script(Goblin), assertion_item)
	assert(ClassUtils.is_script(MainScene), assertion_item)
	assert(ClassUtils.is_script(TestObj.Foo), assertion_item)
	assert(not ClassUtils.is_script(Node), assertion_item)
	assert(not ClassUtils.is_script(Resource), assertion_item)
	assert(not ClassUtils.is_script(Object), assertion_item)
	assert(not ClassUtils.is_script(GDScript), assertion_item)
	
	assert(not ClassUtils.is_script(Goblin.new()), assertion_item)
	assert(not ClassUtils.is_script(get_tree()), assertion_item)
	assert(not ClassUtils.is_script(get_tree().get_class()), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_is_native():
	const assertion_item := "ClassUtils.is_native()"
	
	assert(not ClassUtils.is_native(null), assertion_item)
	assert(not ClassUtils.is_native(""), assertion_item)
	assert(not ClassUtils.is_native("InvalidType"), assertion_item)
	
	assert(not ClassUtils.is_native(Goblin), assertion_item)
	assert(not ClassUtils.is_native(MainScene), assertion_item)
	assert(ClassUtils.is_native(Node), assertion_item)
	assert(ClassUtils.is_native(Resource), assertion_item)
	assert(ClassUtils.is_native(Object), assertion_item)
	
	assert(ClassUtils.is_native(get_tree().get_class()), assertion_item)
	assert(not ClassUtils.is_native(get_tree()), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_is_valid():
	const assertion_item := "ClassUtils.is_valid()"
	
	assert(not ClassUtils.is_valid(""), assertion_item)
	assert(not ClassUtils.is_valid("InvalidType"), assertion_item)
	
	assert(ClassUtils.is_valid("Node"), assertion_item)
	assert(ClassUtils.is_valid("Resource"), assertion_item)
	assert(ClassUtils.is_valid("Object"), assertion_item)
	assert(ClassUtils.is_valid("Goblin"), assertion_item)
	assert(ClassUtils.is_valid("MainScene"), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_get_type_name():
	const assertion_item := "ClassUtils.get_type_name()"
	
	assert(ClassUtils.get_type_name(null) == type_string(TYPE_NIL), assertion_item)
	assert(ClassUtils.get_type_name(34) == type_string(TYPE_INT), assertion_item)
	assert(ClassUtils.get_type_name("Object") == type_string(TYPE_STRING), assertion_item)
	assert(ClassUtils.get_type_name([]) == type_string(TYPE_ARRAY), assertion_item)
	assert(ClassUtils.get_type_name(Object) == "Object", assertion_item)
	assert(ClassUtils.get_type_name(RefCounted) == "RefCounted", assertion_item)
	assert(ClassUtils.get_type_name(Resource) == "Resource", assertion_item)
	assert(ClassUtils.get_type_name(Node) == "Node", assertion_item)
	assert(ClassUtils.get_type_name(Goblin) == "Goblin", assertion_item)
	assert(ClassUtils.get_type_name(MainScene) == "MainScene")
	assert(ClassUtils.get_type_name(GDScriptUtilities._plugin_cache) == "Resource", assertion_item)
	assert(ClassUtils.get_type_name(get_tree()) == "SceneTree", assertion_item)
	assert(ClassUtils.get_type_name(TestObj.Foo) == "GDScript", assertion_item)
	assert(ClassUtils.get_type_name(TestObj.Foo.new()) == "RefCounted", assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_get_inheritance_list():
	const assertion_item := "ClassUtils.get_inheritance_list()"
	
	assert(not ClassUtils.get_inheritance_list(Node).has("Node"), assertion_item)
	assert(ClassUtils.get_inheritance_list(Node, true).has("Node"), assertion_item)
	
	assert(not ClassUtils.get_inheritance_list(Resource).has("Node"), assertion_item)
	assert(ClassUtils.get_inheritance_list(Resource).has("Object"), assertion_item)
	
	assert(ClassUtils.get_inheritance_list(Goblin).has("Character"), assertion_item)
	assert(ClassUtils.get_inheritance_list(Goblin).has("Node"), assertion_item)
	assert(not ClassUtils.get_inheritance_list(Goblin).has("Node3D"), assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)


func assert_get_type():
	const assertion_item := "ClassUtils.get_type()"
	
	assert(not ClassUtils.get_type(""), assertion_item)
	assert(not ClassUtils.get_type("InvalidType"), assertion_item)
	assert(not ClassUtils.get_type("GDScriptNativeClass"), assertion_item)
	
	assert(ClassUtils.get_type("Object") == Object, assertion_item)
	assert(ClassUtils.get_type("RefCounted") == RefCounted, assertion_item)
	assert(ClassUtils.get_type("Resource") == Resource, assertion_item)
	assert(ClassUtils.get_type("Node") == Node, assertion_item)
	assert(ClassUtils.get_type("Goblin") == Goblin, assertion_item)
	assert(ClassUtils.get_type("MainScene") == MainScene, assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)
