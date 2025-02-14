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
	if GDScriptUtilities.is_engine_version_equal_or_newer(4,3):
		_array_types.append(38) # TYPE_PACKED_VECTOR4_ARRAY


## Checks if a given object is a type of array.
static func is_any_array(obj) -> bool:
	return _array_types.has(typeof(obj))


## Checks if a given object is an array or dictionary.
static func is_collection(obj) -> bool:
	return is_dictionary(obj) or is_any_array(obj)


## Checks if a given object is a dictionary.
static func is_dictionary(obj) -> bool:
	return typeof(obj) == TYPE_DICTIONARY


## Checks if a given value is a builtin variant of any type, except TYPE_OBJECT.
## Can optionally allow null values.
static func is_builtin(value, allow_null = false) -> bool:
	if typeof(value) == TYPE_OBJECT:
		return false
	
	if(typeof(value) == TYPE_NIL and not allow_null):
		return false
	else:
		return true


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


# Used internally by ClassUtils.get_type_name
static func _get_typed_array_name(value : Array) -> String:
	var array_name := type_string(typeof(value))
	
	# Not a typed Array
	if not value.is_typed():
		return array_name
	
	var typed_array_name := ""
	if is_builtin(value.get_typed_builtin()):
		typed_array_name = type_string(value.get_typed_builtin())
	elif value.get_typed_script() != null:
		typed_array_name = ClassUtils.get_type_name(value.get_typed_script())
	else:
		typed_array_name = value.get_typed_class_name()
	
	return  "%s[%s]" % [array_name, typed_array_name]


# Used internally by ClassUtils.get_type_name
static func _get_typed_dictionary_name(value) -> String:
	var dictionary_name := type_string(typeof(value))
	
	# Before Godot v4.4
	if GDScriptUtilities.is_engine_version_older(4,4):
		return dictionary_name
	
	# Not a typed Dictionary
	if not value.is_typed():
		return dictionary_name
	
	# Key
	var dictionary_key_type_name := ""
	if not value.is_typed_key():
		dictionary_key_type_name = "any"
	elif is_builtin(value.get_typed_key_builtin()):
		dictionary_key_type_name = type_string(value.get_typed_key_builtin())
	elif value.get_typed_key_script() != null:
		dictionary_key_type_name = ClassUtils.get_type_name(value.get_typed_key_script())
	else:
		dictionary_key_type_name = value.get_typed_key_class_name()
	
	# Value
	var dictionary_value_type_name := ""
	if not value.is_typed_value():
		dictionary_value_type_name = "any"
	elif is_builtin(value.get_typed_value_builtin()):
		dictionary_value_type_name = type_string(value.get_typed_value_builtin())
	elif value.get_typed_value_script() != null:
		dictionary_value_type_name = ClassUtils.get_type_name(value.get_typed_value_script())
	else:
		dictionary_value_type_name = value.get_typed_value_class_name()
	
	return "%s[%s,%s]" % [dictionary_name, dictionary_key_type_name, dictionary_value_type_name]
