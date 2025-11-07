module main

import leafscale.veemarker

fn main() {
	println('VeeMarker Macros Example')
	println('==========================================')

	// Create the template engine
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Prepare template data for macro demonstrations
	mut data := map[string]veemarker.Any{}

	// Create some user data for the macro examples
	mut users := []veemarker.Any{}

	mut user1 := map[string]veemarker.Any{}
	user1['name'] = 'Alice Johnson'
	user1['role'] = 'Administrator'
	user1['email'] = 'alice@example.com'
	users << user1

	mut user2 := map[string]veemarker.Any{}
	user2['name'] = 'Bob Smith'
	user2['role'] = 'Developer'
	user2['email'] = 'bob@example.com'
	users << user2

	mut user3 := map[string]veemarker.Any{}
	user3['name'] = 'Charlie Brown'
	user3['role'] = 'Designer'
	user3['email'] = 'charlie@example.com'
	users << user3

	data['users'] = users
	data['site_title'] = 'VeeMarker Examples'
	data['current_year'] = 2024

	// Product data for another macro example
	mut products := []veemarker.Any{}

	mut product1 := map[string]veemarker.Any{}
	product1['name'] = 'Laptop'
	product1['price'] = 999.99
	product1['in_stock'] = true
	products << product1

	mut product2 := map[string]veemarker.Any{}
	product2['name'] = 'Mouse'
	product2['price'] = 29.99
	product2['in_stock'] = true
	products << product2

	mut product3 := map[string]veemarker.Any{}
	product3['name'] = 'Keyboard'
	product3['price'] = 79.99
	product3['in_stock'] = false
	products << product3

	data['products'] = products

	// Load and render the template
	template := $embed_file('template.vtpl').to_string()

	result := engine.render_string(template, data) or {
		eprintln('Error rendering template: ${err}')
		return
	}

	println(result)
}