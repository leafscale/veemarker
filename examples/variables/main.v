module main

import veemarker

fn main() {
	println('VeeMarker Variables Example')
	println('==========================================')

	// Create the template engine
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Prepare template data with different variable types
	mut data := map[string]veemarker.Any{}

	// Simple variables
	data['name'] = 'Alice'
	data['age'] = 28
	data['pi'] = 3.14159
	data['active'] = true

	// Nested object
	mut address := map[string]veemarker.Any{}
	address['street'] = '123 Main St'
	address['city'] = 'Springfield'
	address['zip'] = '12345'
	data['address'] = address

	// Array
	hobbies := [
		veemarker.Any('reading'),
		veemarker.Any('coding'),
		veemarker.Any('hiking')
	]
	data['hobbies'] = hobbies

	// Load and render the template
	template := $embed_file('template.vtpl').to_string()

	result := engine.render_string(template, data) or {
		eprintln('Error rendering template: ${err}')
		return
	}

	println(result)
}