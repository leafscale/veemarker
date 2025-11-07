module main

import leafscale.veemarker
import os

fn main() {
	println('VeeMarker Includes Example')
	println('==========================================')

	// Create the template engine with the includes directory as template path
	mut engine := veemarker.new_engine(veemarker.EngineConfig{
		template_dir: os.dir(@FILE)  // Use current directory for templates
	})

	// Prepare template data
	mut data := map[string]veemarker.Any{}

	data['page_title'] = 'Welcome to VeeMarker'
	data['username'] = 'John Doe'
	data['site_name'] = 'VeeMarker Examples'

	// Navigation items
	nav_items := [
		veemarker.Any('Home'),
		veemarker.Any('About'),
		veemarker.Any('Services'),
		veemarker.Any('Contact')
	]
	data['nav_items'] = nav_items

	// Footer info
	data['copyright_year'] = 2024
	data['company_name'] = 'VeeMarker Inc.'

	// Main content
	data['main_heading'] = 'Understanding Template Includes'
	data['description'] = 'Template includes allow you to reuse common template parts across multiple pages.'

	// Load and render the main template
	template := $embed_file('template.vtpl').to_string()

	result := engine.render_string(template, data) or {
		eprintln('Error rendering template: ${err}')
		return
	}

	println(result)
}