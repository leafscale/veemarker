module main

import leafscale.veemarker

fn main() {
	println('╔════════════════════════════════════════════════════════════╗')
	println('║  VeeMarker Greater Than (>) Bug Test                      ║')
	println('╚════════════════════════════════════════════════════════════╝')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Test 1: The reported bug - url?size > 0
	println('\n=== Test 1: url?size > 0 (Reported Bug) ===')
	template1 := '<#if url?size > 0>URL has content</#if>'
	mut data1 := map[string]veemarker.Any{}
	data1['url'] = veemarker.Any('https://example.com')

	result1 := engine.render_string(template1, data1) or {
		println('ERROR: ${err}')
		panic(err)
	}

	println('Template: ${template1}')
	println('Data: url="https://example.com" (length=20)')
	println('Result: "${result1}"')
	println('Expected: "URL has content"')
	if result1.trim_space() == 'URL has content' {
		println('Status: ✓ PASS')
	} else {
		println('Status: ✗ FAIL - Got: "${result1}"')
	}

	// Test 2: Simple variable > number
	println('\n=== Test 2: count > 5 ===')
	template2 := '<#if count > 5>Greater than 5</#if>'
	mut data2 := map[string]veemarker.Any{}
	data2['count'] = veemarker.Any(10)

	result2 := engine.render_string(template2, data2) or {
		println('ERROR: ${err}')
		panic(err)
	}

	println('Template: ${template2}')
	println('Data: count=10')
	println('Result: "${result2}"')
	println('Expected: "Greater than 5"')
	if result2.trim_space() == 'Greater than 5' {
		println('Status: ✓ PASS')
	} else {
		println('Status: ✗ FAIL - Got: "${result2}"')
	}

	// Test 3: Direct number comparison
	println('\n=== Test 3: 10 > 5 (Direct literals) ===')
	template3 := '<#if 10 > 5>Ten is greater</#if>'
	data3 := map[string]veemarker.Any{}

	result3 := engine.render_string(template3, data3) or {
		println('ERROR: ${err}')
		panic(err)
	}

	println('Template: ${template3}')
	println('Result: "${result3}"')
	println('Expected: "Ten is greater"')
	if result3.trim_space() == 'Ten is greater' {
		println('Status: ✓ PASS')
	} else {
		println('Status: ✗ FAIL - Got: "${result3}"')
	}

	// Test 4: >= operator (should work)
	println('\n=== Test 4: score >= 90 (Control test) ===')
	template4 := '<#if score >= 90>Excellent</#if>'
	mut data4 := map[string]veemarker.Any{}
	data4['score'] = veemarker.Any(95)

	result4 := engine.render_string(template4, data4) or {
		println('ERROR: ${err}')
		panic(err)
	}

	println('Template: ${template4}')
	println('Data: score=95')
	println('Result: "${result4}"')
	println('Expected: "Excellent"')
	if result4.trim_space() == 'Excellent' {
		println('Status: ✓ PASS')
	} else {
		println('Status: ✗ FAIL - Got: "${result4}"')
	}

	// Test 5: < operator (should work)
	println('\n=== Test 5: age < 18 (Control test) ===')
	template5 := '<#if age < 18>Minor</#if>'
	mut data5 := map[string]veemarker.Any{}
	data5['age'] = veemarker.Any(15)

	result5 := engine.render_string(template5, data5) or {
		println('ERROR: ${err}')
		panic(err)
	}

	println('Template: ${template5}')
	println('Data: age=15')
	println('Result: "${result5}"')
	println('Expected: "Minor"')
	if result5.trim_space() == 'Minor' {
		println('Status: ✓ PASS')
	} else {
		println('Status: ✗ FAIL - Got: "${result5}"')
	}

	println('\n╔════════════════════════════════════════════════════════════╗')
	println('║  Test Complete - Check results above                      ║')
	println('╚════════════════════════════════════════════════════════════╝')
}
