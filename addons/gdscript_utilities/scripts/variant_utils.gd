@tool
class_name VariantUtils
## This class provides utility functions for types of variables.


static var _array_types : Array[int] = [
	TYPE_ARRAY,
	TYPE_PACKED_BYTE_ARRAY,
	TYPE_PACKED_INT32_ARRAY,
	TYPE_PACKED_INT64_ARRAY,
	TYPE_PACKED_FLOAT32_ARRAY,
	TYPE_PACKED_FLOAT64_ARRAY,
	TYPE_PACKED_STRING_ARRAY,
	TYPE_PACKED_VECTOR2_ARRAY,
	TYPE_PACKED_VECTOR3_ARRAY,
	TYPE_PACKED_COLOR_ARRAY,
]


static func _static_init():
	if TYPE_MAX > 38:
		# TYPE_PACKED_VECTOR4_ARRAY added in Godot 4.3
		_array_types.append(38)


## Checks if a given object is a type of array.
static func is_any_array(obj) -> bool:
	return _array_types.has(typeof(obj))


## Checks if a given object is an array or dictionary.
static func is_collection(obj) -> bool:
	return is_dictionary(obj) or is_any_array(obj)


## Checks if a given object is a dictionary.
static func is_dictionary(obj) -> bool:
	return typeof(obj) == TYPE_DICTIONARY


static func _compare_value_only(data_item, compare_item) -> bool:
	var is_data_value_type_pair = is_dictionary(data_item) \
			and data_item.size() == 2 \
			and data_item.has(PackedSceneUtils.KEY_VALUE) \
			and data_item.has(PackedSceneUtils.KEY_TYPE)
	
	var is_compare_value_type_pair = is_dictionary(compare_item) \
			and compare_item.size() == 2 \
			and compare_item.has(PackedSceneUtils.KEY_VALUE) \
			and compare_item.has(PackedSceneUtils.KEY_TYPE)
	
	return is_data_value_type_pair and not is_compare_value_type_pair


# Function created primarily for use inside [member PackedSceneUtils.has_properties_with_values]
#
# Searches [param data_collection] to find keys and values given by [param compare_collection].
# Returns [code]true[/code] when all compared keys and values are found.
#
# The search handles recursive data structures, but also expects them to be of similar type
# (can't compare Dictionaries with Arrays) and the data must be in the same layer.
#
# As a special case, a Dictionary with only "value" and "type" as keys will be treated 
# as a definition for the property.
static func _collection_contains(data_collection, compare_collection) -> bool:
	if compare_collection.is_empty():
		return true
	
	var is_valid := false
	
	# compare array values
	if is_any_array(data_collection) and is_any_array(compare_collection):
		for compare_item in compare_collection:
			var has_valid_data := false
			
			for data_item in data_collection:
				var data_value
				
				if _compare_value_only(data_item, compare_item):
					data_value = data_item[PackedSceneUtils.KEY_VALUE]
				else:
					data_value = data_item
					
				if is_collection(data_value) and is_collection(compare_item):
					has_valid_data = _collection_contains(data_value, compare_item)
				elif typeof(data_value) == typeof(compare_item):
					has_valid_data = (data_value == compare_item)
				
				if has_valid_data:
					is_valid = true
					break
			
			if not has_valid_data:
				is_valid = false
				break
	
	# compare dictionary key-value pair
	elif is_dictionary(data_collection) and is_dictionary(compare_collection):
		for compare_key in compare_collection:
			var compare_item = compare_collection[compare_key]
			
			if data_collection.has(compare_key):
				var data_item = data_collection[compare_key]
				var data_value
				
				if _compare_value_only(data_item, compare_item):
					data_value = data_item[PackedSceneUtils.KEY_VALUE]
				else:
					data_value = data_item
				
				if is_collection(data_value) and is_collection(compare_item):
					is_valid = _collection_contains(data_value, compare_item)
					
				elif typeof(data_value) == typeof(compare_item):
					is_valid = (data_value == compare_item)
			else:
				is_valid = false
			
			if not is_valid:
				break
			
	return is_valid
