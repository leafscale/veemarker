module main

import veemarker

// Example from bug report - shows the CORRECT way to handle structs
struct Customer {
pub:
	id    int
	name  string
	email string
}

fn main() {
	println('VeeMarker Struct Conversion Example')
	println('====================================\n')

	// Create array of customers (from database, API, etc.)
	customers := [
		Customer{id: 1, name: 'Alice', email: 'alice@example.com'},
		Customer{id: 2, name: 'Bob', email: 'bob@example.com'},
	]

	// CORRECT: Convert structs to map[string]Any using helper
	data := {
		'customers': veemarker.to_map_array(customers)
		'title':     veemarker.Any('Customer List')
	}

	// Template with list directive
	template := $embed_file('template.vtpl').to_string()

	// Render template
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	html := engine.render_string(template, data) or {
		eprintln('Error rendering template: ${err}')
		return
	}

	println(html)
}
