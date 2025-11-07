module main

import leafscale.veemarker

fn main() {
	println('VeeMarker Strings Example')
	println('==========================================')

	// Create the template engine
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Prepare template data with string examples
	mut data := map[string]veemarker.Any{}

	// Various strings for manipulation
	data['title'] = 'hello world'
	data['sentence'] = '  The quick brown fox jumps over the lazy dog  '
	data['email'] = 'John.Doe@Example.COM'
	data['path'] = '/usr/local/bin/app'
	data['code'] = 'function_name_here'
	data['description'] = 'This is a sample description with some text'
	data['url'] = 'https://www.example.com/page'

	// Numbers for string conversion
	data['price'] = 42.99
	data['quantity'] = 5
	data['is_active'] = true
	data['is_disabled'] = false

	// Empty and whitespace strings
	data['empty'] = ''
	data['whitespace'] = '   '
	data['text_with_spaces'] = 'hello   world'

	// Load and render the template
	template := $embed_file('template.vtpl').to_string()

	result := engine.render_string(template, data) or {
		eprintln('Error rendering template: ${err}')
		return
	}

	println(result)
}