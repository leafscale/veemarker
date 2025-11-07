module main

import leafscale.veemarker

fn main() {
	println('Testing ? built-in with directive end...\\n')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Test with ?has_content
	template := r'<#if itemName?has_content>Has content</#if>'
	mut data := map[string]veemarker.Any{}
	data['itemName'] = veemarker.Any('test')

	result := engine.render_string(template, data) or {
		println('ERROR: ${err}')
		return
	}

	println('Template: ${template}')
	println('Result: "${result}"')
	if result.trim_space() == 'Has content' {
		println('✓ PASS')
	} else {
		println('✗ FAIL')
	}
}
