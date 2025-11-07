module main

import leafscale.veemarker
import os

fn main() {
	println('Testing attempt/recover functionality...')

	// Test data with missing variable to trigger attempt/recover
	data := {
		'name': 'Alice'
		'greeting': 'Hello World'
	}

	// Test template with attempt/recover
	template_content := '<#attempt>
Attempting to access: ${missing_var}
This should fail!
<#recover>
Error handled gracefully - fallback content shown
</#attempt>

Done!'

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	result := engine.render_string(template_content, data) or {
		println('Engine error: $err')
		return
	}

	println('Result:')
	println(result)
}