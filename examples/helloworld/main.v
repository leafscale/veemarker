module main

import veemarker
import os

fn main() {
	println('VeeMarker Hello World Example')
	println('='.repeat(40))

	// Create the template engine
	mut engine := veemarker.new_engine(veemarker.EngineConfig{
		template_dir: '.'
		dev_mode: true
	})

	// Prepare template data
	mut data := map[string]veemarker.Any{}

	// Simple data
	data['greeting'] = veemarker.Any('Hello')
	data['name'] = veemarker.Any('World')

	// A list of items
	items := [
		veemarker.Any('Learn VeeMarker'),
		veemarker.Any('Create templates'),
		veemarker.Any('Build amazing apps')
	]
	data['items'] = veemarker.Any(items)

	// Nested object
	mut user := map[string]veemarker.Any{}
	user['username'] = veemarker.Any('developer')
	user['level'] = veemarker.Any(42)
	user['premium'] = veemarker.Any(true)
	data['user'] = veemarker.Any(user)

	// Numbers for calculations
	data['year'] = veemarker.Any(2025)
	data['pi'] = veemarker.Any(3.14159)

	// Render from string template first
	println('\n1. String Template Example:')
	println('-'.repeat(30))

	simple_template := r'${greeting}, ${name}!'
	result := engine.render_string(simple_template, data) or {
		eprintln('Error rendering string template: ${err}')
		return
	}
	println(result)

	// Render from file template
	println('\n2. File Template Example:')
	println('-'.repeat(30))

	// Check if template file exists
	if !os.exists('hello.vtpl') {
		eprintln('Template file hello.vtpl not found!')
		eprintln('Please run this example from the helloworld directory')
		return
	}

	file_result := engine.render('hello.vtpl', data) or {
		eprintln('Error rendering file template: ${err}')
		return
	}
	println(file_result)

	println('\n' + '='.repeat(40))
	println('Example completed successfully!')
}