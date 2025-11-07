module main

import leafscale.veemarker

fn main() {
	println('╔════════════════════════════════════════════════════════════╗')
	println('║  VeeMarker Assign with > Test (Property Access Case)     ║')
	println('╚════════════════════════════════════════════════════════════╝')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Test: The exact pattern from the bug report - property access followed by >
	println('\n=== Test: <#assign itemShortUrl = base_url + "/" + item.short_code> ===')
	template := '<#assign itemShortUrl = base_url + \"/\" + item.short_code>Done'
	mut data := map[string]veemarker.Any{}

	// Create item with short_code property
	mut item := map[string]veemarker.Any{}
	item['short_code'] = veemarker.Any('abc123')

	data['base_url'] = veemarker.Any('https://example.com')
	data['item'] = veemarker.Any(item)

	result := engine.render_string(template, data) or {
		println('ERROR: ${err}')
		panic(err)
	}

	println('Template: ${template}')
	println('Data: base_url="https://example.com", item.short_code="abc123"')
	println('Result: "${result}"')
	println('Expected: "Done"')
	if result.trim_space() == 'Done' {
		println('Status: ✓ PASS - The > after property access was correctly recognized as directive_end')
	} else {
		println('Status: ✗ FAIL - Got: "${result}"')
	}

	println('\n╔════════════════════════════════════════════════════════════╗')
	println('║  Test Complete                                             ║')
	println('╚════════════════════════════════════════════════════════════╝')
}
