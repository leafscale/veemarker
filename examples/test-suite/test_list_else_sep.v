import leafscale.veemarker

fn main() {
	println('Testing VeeMarker list else/sep directives...')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	mut data := map[string]veemarker.Any{}

	// Test data - array with items
	mut items := []veemarker.Any{}
	items << 'apple'
	items << 'banana'
	items << 'cherry'
	data['fruits'] = items

	// Test data - empty array
	data['empty_list'] = []veemarker.Any{}

	// Test 1: Basic list with separator
	template1 := r'<#list fruits as fruit>${fruit}<#sep>, </#list>'
	result1 := engine.render_string(template1, data) or {
		println('Test 1 Error: $err')
		return
	}
	println('Test 1 (list with sep): "${result1}" (expected: "apple, banana, cherry")')

	// Test 2: List with else block - non-empty list (should not use else)
	template2 := r'<#list fruits as fruit>${fruit}<#else>No fruits found</#list>'
	result2 := engine.render_string(template2, data) or {
		println('Test 2 Error: $err')
		return
	}
	println('Test 2 (list with else, non-empty): "${result2}" (expected: "applebananacherry")')

	// Test 3: List with else block - empty list (should use else)
	template3 := r'<#list empty_list as item>${item}<#else>No items found</#list>'
	result3 := engine.render_string(template3, data) or {
		println('Test 3 Error: $err')
		return
	}
	println('Test 3 (list with else, empty): "${result3}" (expected: "No items found")')

	// Test 4: List with both separator and else block - non-empty
	template4 := r'<#list fruits as fruit>${fruit}<#sep> | <#else>Empty basket</#list>'
	result4 := engine.render_string(template4, data) or {
		println('Test 4 Error: $err')
		return
	}
	println('Test 4 (list with sep and else, non-empty): "${result4}" (expected: "apple | banana | cherry")')

	// Test 5: List with both separator and else block - empty
	template5 := r'<#list empty_list as item>${item}<#sep> | <#else>Empty list</#list>'
	result5 := engine.render_string(template5, data) or {
		println('Test 5 Error: $err')
		return
	}
	println('Test 5 (list with sep and else, empty): "${result5}" (expected: "Empty list")')

	// Test 6: Complex list formatting with HTML
	template6 := r'<ul><#list fruits as fruit><li>${fruit}</li><#else><li>No fruits available</li></#list></ul>'
	result6 := engine.render_string(template6, data) or {
		println('Test 6 Error: $err')
		return
	}
	println('Test 6 (HTML list): "${result6}" (expected: "<ul><li>apple</li><li>banana</li><li>cherry</li></ul>")')

	// Test 7: Complex separator - nested formatting
	template7 := r'Items: <#list fruits as fruit>${fruit}<#sep>, </#list>.'
	result7 := engine.render_string(template7, data) or {
		println('Test 7 Error: $err')
		return
	}
	println('Test 7 (formatted list): "${result7}" (expected: "Items: apple, banana, cherry.")')

	// Test 8: Single item list (no separator should be rendered)
	mut single_item := []veemarker.Any{}
	single_item << 'onlyone'
	data['single'] = single_item

	template8 := r'<#list single as item>${item}<#sep> | </#list>'
	result8 := engine.render_string(template8, data) or {
		println('Test 8 Error: $err')
		return
	}
	println('Test 8 (single item, no sep): "${result8}" (expected: "onlyone")')

	// Test 9: Verify existing list functionality still works
	template9 := r'<#list fruits as fruit>${fruit}_${fruit_index}</#list>'
	result9 := engine.render_string(template9, data) or {
		println('Test 9 Error: $err')
		return
	}
	println('Test 9 (existing functionality): "${result9}" (expected: "apple_0banana_1cherry_2")')

	println('\nAll list else/sep directive tests completed!')
}