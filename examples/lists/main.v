module main

import leafscale.veemarker

fn main() {
	println('VeeMarker Lists Example')
	println('==========================================')

	// Create the template engine
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Prepare template data with various list scenarios
	mut data := map[string]veemarker.Any{}

	// Simple list of strings
	products := [
		veemarker.Any('Laptop'),
		veemarker.Any('Mouse'),
		veemarker.Any('Keyboard'),
		veemarker.Any('Monitor'),
		veemarker.Any('Headphones')
	]
	data['products'] = products

	// List of objects (users)
	mut users := []veemarker.Any{}

	mut user1 := map[string]veemarker.Any{}
	user1['name'] = 'Alice'
	user1['role'] = 'Admin'
	user1['active'] = true
	users << user1

	mut user2 := map[string]veemarker.Any{}
	user2['name'] = 'Bob'
	user2['role'] = 'Editor'
	user2['active'] = true
	users << user2

	mut user3 := map[string]veemarker.Any{}
	user3['name'] = 'Charlie'
	user3['role'] = 'Viewer'
	user3['active'] = false
	users << user3

	data['users'] = users

	// Nested list structure (categories with items)
	mut categories := []veemarker.Any{}

	mut cat1 := map[string]veemarker.Any{}
	cat1['name'] = 'Electronics'
	cat1['items'] = [
		veemarker.Any('Phone'),
		veemarker.Any('Tablet'),
		veemarker.Any('Smartwatch')
	]
	categories << cat1

	mut cat2 := map[string]veemarker.Any{}
	cat2['name'] = 'Books'
	cat2['items'] = [
		veemarker.Any('Fiction'),
		veemarker.Any('Non-Fiction'),
		veemarker.Any('Technical')
	]
	categories << cat2

	mut cat3 := map[string]veemarker.Any{}
	cat3['name'] = 'Clothing'
	cat3['items'] = []veemarker.Any{}  // Empty list for demonstration
	categories << cat3

	data['categories'] = categories

	// Numbers for demonstration
	data['numbers'] = [
		veemarker.Any(1),
		veemarker.Any(2),
		veemarker.Any(3),
		veemarker.Any(4),
		veemarker.Any(5)
	]

	// Empty list for else demonstration
	data['empty_list'] = []veemarker.Any{}

	// Load and render the template
	template := $embed_file('template.vtpl').to_string()

	result := engine.render_string(template, data) or {
		eprintln('Error rendering template: ${err}')
		return
	}

	println(result)
}