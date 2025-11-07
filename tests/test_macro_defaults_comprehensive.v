module main

import leafscale.veemarker

fn test_simple_default() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#macro greet name greeting="Hello">
${greeting}, ${name}!
</#macro>
<@greet name="World" />'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or { return false }
	return result.contains('Hello, World!')
}

fn test_override_default() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#macro greet name greeting="Hello">
${greeting}, ${name}!
</#macro>
<@greet name="World" greeting="Hi" />'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or { return false }
	return result.contains('Hi, World!')
}

fn test_multiple_defaults() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#macro copyButton text label="Copy" successLabel="✓ Copied!" class="">
Label: ${label}, Success: ${successLabel}, Class: ${class}, Text: ${text}
</#macro>
<@copyButton text="test.com" />'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or { return false }
	return result.contains('Label: Copy') &&
	       result.contains('Success: ✓ Copied!') &&
	       result.contains('Class: ') &&
	       result.contains('Text: test.com')
}

fn test_partial_override() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#macro copyButton text label="Copy" successLabel="✓ Copied!" class="">
Label: ${label}, Success: ${successLabel}, Class: ${class}
</#macro>
<@copyButton text="test.com" label="Click Me" />'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or { return false }
	return result.contains('Label: Click Me') &&
	       result.contains('Success: ✓ Copied!')
}

fn test_empty_string_default() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#macro button text class="">
Button: ${text}, Class: [${class}]
</#macro>
<@button text="Click" />'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or { return false }
	return result.contains('Button: Click, Class: []')
}

fn test_mixed_params() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#macro card title content footer="Learn More">
Title: ${title}
Content: ${content}
Footer: ${footer}
</#macro>
<@card title="Hello" content="World" />'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or { return false }
	return result.contains('Title: Hello') &&
	       result.contains('Content: World') &&
	       result.contains('Footer: Learn More')
}

fn main() {
	println('╔════════════════════════════════════════════════════════════╗')
	println('║  Macro Default Parameters Comprehensive Test Suite        ║')
	println('╚════════════════════════════════════════════════════════════╝')

	tests := [
		test_simple_default,
		test_override_default,
		test_multiple_defaults,
		test_partial_override,
		test_empty_string_default,
		test_mixed_params
	]

	test_names := [
		'Simple default parameter (greeting="Hello")',
		'Override default parameter',
		'Multiple default parameters (copyButton example)',
		'Partial override (some defaults, some overridden)',
		'Empty string default (class="")',
		'Mixed required and optional parameters'
	]

	mut passed := 0
	mut failed := 0

	for i, test_fn in tests {
		println('\n=== Test ${i+1}: ${test_names[i]} ===')
		if test_fn() {
			println('✓ PASS')
			passed++
		} else {
			println('✗ FAIL')
			failed++
		}
	}

	println('\n╔════════════════════════════════════════════════════════════╗')
	println('║  Test Results                                              ║')
	println('╠════════════════════════════════════════════════════════════╣')
	println('║  Passed: ${passed:2}/${tests.len}                                              ║')
	println('║  Failed: ${failed:2}/${tests.len}                                              ║')
	println('╚════════════════════════════════════════════════════════════╝')

	if failed > 0 {
		exit(1)
	}
}
