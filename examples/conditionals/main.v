module main

import leafscale.veemarker

fn main() {
	println('VeeMarker Conditionals Example')
	println('==========================================')

	// Create the template engine
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Prepare template data with different scenarios
	mut data := map[string]veemarker.Any{}

	// User data
	mut user := map[string]veemarker.Any{}
	user['name'] = 'Bob'
	user['age'] = 25
	user['premium'] = true
	user['level'] = 42
	data['user'] = user

	// Stock levels for different scenarios
	data['stock_count'] = 5
	data['temperature'] = 22
	data['is_weekend'] = false

	// Grade for demonstrating elseif chains
	data['score'] = 85

	// Load and render the template
	template := $embed_file('template.vtpl').to_string()

	result := engine.render_string(template, data) or {
		eprintln('Error rendering template: ${err}')
		return
	}

	println(result)
}