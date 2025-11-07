module main

import leafscale.veemarker

fn main() {
	println('VeeMarker Assignments Example')
	println('==========================================')

	// Create the template engine
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Prepare template data with initial values
	mut data := map[string]veemarker.Any{}

	// Initial data that will be manipulated in the template
	data['base_price'] = 100.0
	data['tax_rate'] = 0.08
	data['discount_percentage'] = 10

	// User data
	data['first_name'] = 'John'
	data['last_name'] = 'Doe'

	// List data for calculations
	numbers := [
		veemarker.Any(10),
		veemarker.Any(20),
		veemarker.Any(30),
		veemarker.Any(40),
		veemarker.Any(50)
	]
	data['numbers'] = numbers

	// Product data
	mut products := []veemarker.Any{}

	mut p1 := map[string]veemarker.Any{}
	p1['name'] = 'Widget'
	p1['quantity'] = 3
	p1['price'] = 25.00
	products << p1

	mut p2 := map[string]veemarker.Any{}
	p2['name'] = 'Gadget'
	p2['quantity'] = 2
	p2['price'] = 45.00
	products << p2

	mut p3 := map[string]veemarker.Any{}
	p3['name'] = 'Doohickey'
	p3['quantity'] = 1
	p3['price'] = 99.00
	products << p3

	data['products'] = products

	// Load and render the template
	template := $embed_file('template.vtpl').to_string()

	result := engine.render_string(template, data) or {
		eprintln('Error rendering template: ${err}')
		return
	}

	println(result)
}