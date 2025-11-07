import leafscale.veemarker

fn main() {
	println('Testing VeeMarker string methods...')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	mut data := map[string]veemarker.Any{}
	data['text'] = 'Hello World'
	data['message'] = '  Test Message  '
	data['word'] = 'example'

	// Test 1: New capitalize method (alias for cap_first)
	template1 := r'${text?capitalize}'
	result1 := engine.render_string(template1, data) or {
		println('Test 1 Error: $err')
		return
	}
	println('Test 1 (capitalize): "${result1}" (expected: "Hello World")')

	// Test 2: Existing cap_first method (should still work)
	template2 := r'${word?cap_first}'
	result2 := engine.render_string(template2, data) or {
		println('Test 2 Error: $err')
		return
	}
	println('Test 2 (cap_first): "${result2}" (expected: "Example")')

	// Test 3: substring with start only
	template3 := r'${text?substring(6)}'
	result3 := engine.render_string(template3, data) or {
		println('Test 3 Error: $err')
		return
	}
	println('Test 3 (substring start only): "${result3}" (expected: "World")')

	// Test 4: substring with start and end
	template4 := r'${text?substring(0, 5)}'
	result4 := engine.render_string(template4, data) or {
		println('Test 4 Error: $err')
		return
	}
	println('Test 4 (substring start+end): "${result4}" (expected: "Hello")')

	// Test 5: Verify existing methods still work - upper_case
	template5 := r'${word?upper_case}'
	result5 := engine.render_string(template5, data) or {
		println('Test 5 Error: $err')
		return
	}
	println('Test 5 (upper_case): "${result5}" (expected: "EXAMPLE")')

	// Test 6: Verify existing methods still work - lower_case
	template6 := r'${text?lower_case}'
	result6 := engine.render_string(template6, data) or {
		println('Test 6 Error: $err')
		return
	}
	println('Test 6 (lower_case): "${result6}" (expected: "hello world")')

	// Test 7: Verify existing methods still work - trim
	template7 := r'${message?trim}'
	result7 := engine.render_string(template7, data) or {
		println('Test 7 Error: $err')
		return
	}
	println('Test 7 (trim): "${result7}" (expected: "Test Message")')

	// Test 8: Verify existing methods still work - length
	template8 := r'${text?length}'
	result8 := engine.render_string(template8, data) or {
		println('Test 8 Error: $err')
		return
	}
	println('Test 8 (length): "${result8}" (expected: "11")')

	// Test 9: Verify existing methods still work - starts_with
	template9 := r'${text?starts_with("Hello")}'
	result9 := engine.render_string(template9, data) or {
		println('Test 9 Error: $err')
		return
	}
	println('Test 9 (starts_with): "${result9}" (expected: "true")')

	// Test 10: Verify existing methods still work - ends_with
	template10 := r'${text?ends_with("World")}'
	result10 := engine.render_string(template10, data) or {
		println('Test 10 Error: $err')
		return
	}
	println('Test 10 (ends_with): "${result10}" (expected: "true")')

	// Test 11: Verify existing methods still work - contains
	template11 := r'${text?contains("llo")}'
	result11 := engine.render_string(template11, data) or {
		println('Test 11 Error: $err')
		return
	}
	println('Test 11 (contains): "${result11}" (expected: "true")')

	// Test 12: Verify existing methods still work - replace
	template12 := r'${text?replace("World", "Universe")}'
	result12 := engine.render_string(template12, data) or {
		println('Test 12 Error: $err')
		return
	}
	println('Test 12 (replace): "${result12}" (expected: "Hello Universe")')

	// Test 13: Edge case - substring bounds checking
	template13 := r'${text?substring(15)}'
	result13 := engine.render_string(template13, data) or {
		println('Test 13 Error (expected): $err')
		println('Test 13 (substring bounds): Error correctly caught')
		return
	}
	println('Test 13 (substring bounds): Should have failed but got "${result13}"')

	println('\nAll string method tests completed!')
}