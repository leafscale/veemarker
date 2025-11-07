module main

import leafscale.veemarker

fn main() {
	println('Testing < operator...\n')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Test < comparison
	template := r'<#if age < 18>Minor<#else>Adult</#if>'
	mut data := map[string]veemarker.Any{}
	data['age'] = veemarker.Any(15)

	result := engine.render_string(template, data) or {
		println('ERROR: ${err}')
		return
	}

	println('Template: ${template}')
	println('Result: "${result}"')
	if result.trim_space() == 'Minor' {
		println('✓ PASS')
	} else {
		println('✗ FAIL')
	}
}
