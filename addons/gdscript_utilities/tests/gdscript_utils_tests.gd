@tool
class_name GDScriptUtilsTests
extends Node


func _ready() -> void:
	run_tests()
	queue_free()


func run_tests():
	assert_compare_engine_versions()


func assert_compare_engine_versions():
	const assertion_item := "GDScriptUtilities.compare_engine_version_numbers()"

	assert(GDScriptUtilities.compare_version_numbers([4]    , [4]    ) == 0, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4]    , [4,0,0]) == 0, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,0,0], [4]    ) == 0, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,1]  , [4,1]  ) == 0, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,0,1], [4,0,1]) == 0, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,2,3], [4,2,3]) == 0, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,3,2], [4,3,2]) == 0, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([14,97,153], [14,97,153]) == 0, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([153,0,9999], [153,0,9999]) == 0, assertion_item)
	
	assert(GDScriptUtilities.compare_version_numbers([4]    , [4,4]  ) == -1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4]    , [4,4,2]) == -1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,4]  , [4,5]  ) == -1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,4]  , [4,4,2]) == -1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,4.1], [4,4,2]) == -1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,4,5], [4,5]  ) == -1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([3]    , [4]    ) == -1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([3,4,1], [4]    ) == -1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([3,4,1], [4,5]  ) == -1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([3,4,1], [4,5,2]) == -1, assertion_item)
	
	assert(GDScriptUtilities.compare_version_numbers([4,4]  , [4]    ) == 1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,4,2], [4]    ) == 1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,5]  , [4,4]  ) == 1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,4,2], [4,4]  ) == 1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,4,2], [4,4.1]) == 1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,5]  , [4,4,5]) == 1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4]    , [3]    ) == 1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4]    , [3,4,1]) == 1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,5]  , [3,4,1]) == 1, assertion_item)
	assert(GDScriptUtilities.compare_version_numbers([4,5,2], [3,4,1]) == 1, assertion_item)
	
	UnitTests.print_assertion_passed(assertion_item)
