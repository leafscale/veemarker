import leafscale.veemarker
import os

fn main() {
	println('Testing attempt/recover functionality...')

	// Test success case
	data := {
		'name': 'Alice'
		'greeting': 'Hello World'
	}

	mut engine := veemarker.new_engine(veemarker.EngineConfig{
		template_dir: './08-error-handling'
	})

	// Test attempt succeeds
	println('\n--- Testing attempt success case ---')
	result1 := engine.render_template_string(os.read_file('./08-error-handling/attempt_success.vtpl') or { '' }, data) or {
		println('Error: $err')
		''
	}
	println('Result: $result1')

	// Test attempt fails and recover runs
	println('\n--- Testing attempt/recover case ---')
	result2 := engine.render_template_string(os.read_file('./08-error-handling/attempt_recover.vtpl') or { '' }, data) or {
		println('Error: $err')
		''
	}
	println('Result: $result2')
}