module main

import leafscale.veemarker

fn main() {
	println('Testing real template scenario...\n')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Exact template snippet from user's file
	template := r'<#list url as item>
<#assign itemShortUrl = base_url + "/" + item.short_code>
Item: ${itemShortUrl}
</#list>'

	mut data := map[string]veemarker.Any{}

	// Create test data
	mut item1 := map[string]veemarker.Any{}
	item1['short_code'] = veemarker.Any('abc123')
	item1['id'] = veemarker.Any(1)

	data['base_url'] = veemarker.Any('https://example.com')
	data['url'] = veemarker.Any([veemarker.Any(item1)])

	result := engine.render_string(template, data) or {
		println('ERROR: ${err}')
		println('\nThis is the exact error from the real template!')
		return
	}

	println('SUCCESS!')
	println('Result:')
	println(result)
}
