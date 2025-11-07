import leafscale.veemarker

fn main() {
	println('Testing VeeMarker sequence methods...')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	mut data := map[string]veemarker.Any{}

	// Test data arrays
	mut numbers := []veemarker.Any{}
	numbers << 1
	numbers << 5
	numbers << 3
	numbers << 9
	numbers << 2
	data['numbers'] = numbers

	mut words := []veemarker.Any{}
	words << 'apple'
	words << 'banana'
	words << 'cherry'
	data['words'] = words

	mut mixed := []veemarker.Any{}
	mixed << 10
	mixed << 'test'
	mixed << 20
	mixed << 'hello'
	data['mixed'] = mixed

	data['empty'] = []veemarker.Any{}

	// Test 1: min on numbers
	template1 := r'${numbers?min}'
	result1 := engine.render_string(template1, data) or {
		println('Test 1 Error: $err')
		return
	}
	println('Test 1 (min numbers): "${result1}" (expected: "1")')

	// Test 2: max on numbers
	template2 := r'${numbers?max}'
	result2 := engine.render_string(template2, data) or {
		println('Test 2 Error: $err')
		return
	}
	println('Test 2 (max numbers): "${result2}" (expected: "9")')

	// Test 3: min on strings (alphabetical)
	template3 := r'${words?min}'
	result3 := engine.render_string(template3, data) or {
		println('Test 3 Error: $err')
		return
	}
	println('Test 3 (min strings): "${result3}" (expected: "apple")')

	// Test 4: max on strings (alphabetical)
	template4 := r'${words?max}'
	result4 := engine.render_string(template4, data) or {
		println('Test 4 Error: $err')
		return
	}
	println('Test 4 (max strings): "${result4}" (expected: "cherry")')

	// Test 5: seq_contains - found
	template5 := r'${numbers?seq_contains(5)}'
	result5 := engine.render_string(template5, data) or {
		println('Test 5 Error: $err')
		return
	}
	println('Test 5 (seq_contains found): "${result5}" (expected: "true")')

	// Test 6: seq_contains - not found
	template6 := r'${numbers?seq_contains(99)}'
	result6 := engine.render_string(template6, data) or {
		println('Test 6 Error: $err')
		return
	}
	println('Test 6 (seq_contains not found): "${result6}" (expected: "false")')

	// Test 7: seq_contains with string
	template7 := r'${words?seq_contains("banana")}'
	result7 := engine.render_string(template7, data) or {
		println('Test 7 Error: $err')
		return
	}
	println('Test 7 (seq_contains string): "${result7}" (expected: "true")')

	// Test 8: Verify existing methods still work - first
	template8 := r'${numbers?first}'
	result8 := engine.render_string(template8, data) or {
		println('Test 8 Error: $err')
		return
	}
	println('Test 8 (first): "${result8}" (expected: "1")')

	// Test 9: Verify existing methods still work - last
	template9 := r'${numbers?last}'
	result9 := engine.render_string(template9, data) or {
		println('Test 9 Error: $err')
		return
	}
	println('Test 9 (last): "${result9}" (expected: "2")')

	// Test 10: Verify existing methods still work - length
	template10 := r'${numbers?length}'
	result10 := engine.render_string(template10, data) or {
		println('Test 10 Error: $err')
		return
	}
	println('Test 10 (length): "${result10}" (expected: "5")')

	// Test 11: Error case - min on empty array
	template11 := r'${empty?min}'
	result11 := engine.render_string(template11, data) or {
		println('Test 11 Error (expected): $err')
		println('Test 11 (min empty): Error correctly caught')
		return
	}
	println('Test 11 (min empty): Should have failed but got "${result11}"')

	println('\nAll sequence method tests completed!')
}