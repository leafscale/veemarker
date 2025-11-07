module main

import leafscale.veemarker

fn main() {
	println('Testing macro parameter default values...\n')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Test case: macro with default parameter values
	template := r'<#macro testMacro required optional="default value">
Required: ${required}
Optional: ${optional}
</#macro>

<@testMacro required="test" />'

	data := map[string]veemarker.Any{}

	result := engine.render_string(template, data) or {
		println('ERROR: ${err}')
		return
	}

	println('Template:')
	println(template)
	println('\nResult:')
	println(result)
	println('\nExpected:')
	println('Required: test')
	println('Optional: default value')

	if result.contains('default value') {
		println('\n✓ PASS - Default values work!')
	} else if result.contains('Optional: ') && !result.contains('default value') {
		println('\n✗ FAIL - Optional parameter is empty, default value not applied')
	} else {
		println('\n✗ FAIL - Unexpected result')
	}
}
