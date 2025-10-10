import veemarker

fn main() {
	println('Testing VeeMarker switch/case statements...')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	mut data := map[string]veemarker.Any{}

	// Test data
	data['grade'] = 'A'
	data['status'] = 1
	data['category'] = 'premium'
	data['level'] = 5
	data['type'] = 'unknown'

	// Test 1: Basic string switch/case
	template1 := r'<#switch grade><#case "A">Excellent<#case "B">Good<#case "C">Average<#default>Poor</#switch>'
	result1 := engine.render_string(template1, data) or {
		println('Test 1 Error: $err')
		return
	}
	println('Test 1 (string switch): "${result1}" (expected: "Excellent")')

	// Test 2: Numeric switch/case
	template2 := r'<#switch status><#case 1>Active<#case 2>Inactive<#case 3>Pending<#default>Unknown</#switch>'
	result2 := engine.render_string(template2, data) or {
		println('Test 2 Error: $err')
		return
	}
	println('Test 2 (numeric switch): "${result2}" (expected: "Active")')

	// Test 3: Switch with default case
	template3 := r'<#switch type><#case "basic">Basic Plan<#case "premium">Premium Plan<#default>Unknown Plan</#switch>'
	result3 := engine.render_string(template3, data) or {
		println('Test 3 Error: $err')
		return
	}
	println('Test 3 (default case): "${result3}" (expected: "Unknown Plan")')

	// Test 4: Switch without default - no match
	template4 := r'<#switch type><#case "basic">Basic<#case "premium">Premium</#switch>'
	result4 := engine.render_string(template4, data) or {
		println('Test 4 Error: $err')
		return
	}
	println('Test 4 (no match, no default): "${result4}" (expected: "")')

	// Test 5: Switch with multi-line case blocks
	template5 := r'<#switch category>
<#case "basic">
Basic tier
Features: Limited
<#case "premium">
Premium tier
Features: Unlimited
<#default>
Standard tier
Features: Standard
</#switch>'
	result5 := engine.render_string(template5, data) or {
		println('Test 5 Error: $err')
		return
	}
	println('Test 5 (multi-line): "${result5}" (expected: "\\nPremium tier\\nFeatures: Unlimited\\n")')

	// Test 6: Switch with expressions in cases
	template6 := r'<#switch level><#case 1>Beginner<#case 2>Novice<#case 3>Intermediate<#case 4>Advanced<#case 5>Expert<#default>Invalid</#switch>'
	result6 := engine.render_string(template6, data) or {
		println('Test 6 Error: $err')
		return
	}
	println('Test 6 (expression cases): "${result6}" (expected: "Expert")')

	// Test 7: Nested switch statements
	data['outer'] = 'test'
	data['inner'] = 'nested'
	template7 := r'<#switch outer><#case "test">Outer: <#switch inner><#case "nested">Inner Match<#default>No Inner Match</#switch><#default>No Outer Match</#switch>'
	result7 := engine.render_string(template7, data) or {
		println('Test 7 Error: $err')
		return
	}
	println('Test 7 (nested switch): "${result7}" (expected: "Outer: Inner Match")')

	// Test 8: Switch with interpolation in case blocks
	data['user'] = 'John'
	template8 := r'<#switch grade><#case "A">Congratulations ${user}! Perfect score!<#case "B">Well done ${user}!<#default>Try harder ${user}.</#switch>'
	result8 := engine.render_string(template8, data) or {
		println('Test 8 Error: $err')
		return
	}
	println('Test 8 (interpolation): "${result8}" (expected: "Congratulations John! Perfect score!")')

	// Test 9: Empty switch block
	data['empty_var'] = ''
	template9 := r'<#switch empty_var></#switch>'
	result9 := engine.render_string(template9, data) or {
		println('Test 9 Error: $err')
		return
	}
	println('Test 9 (empty switch): "${result9}" (expected: "")')

	// Test 10: Switch with boolean values
	data['flag'] = true
	template10 := r'<#switch flag><#case true>Flag is true<#case false>Flag is false<#default>Flag is unknown</#switch>'
	result10 := engine.render_string(template10, data) or {
		println('Test 10 Error: $err')
		return
	}
	println('Test 10 (boolean switch): "${result10}" (expected: "Flag is true")')

	// Test 11: Switch with variable expressions
	data['test_var'] = 'premium'
	template11 := r'<#switch test_var><#case "basic">Basic<#case "premium">Premium<#default>Unknown</#switch>'
	result11 := engine.render_string(template11, data) or {
		println('Test 11 Error: $err')
		return
	}
	println('Test 11 (variable expression): "${result11}" (expected: "Premium")')

	println('\nAll switch/case statement tests completed!')
}