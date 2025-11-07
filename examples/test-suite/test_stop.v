import leafscale.veemarker

fn main() {
	println('Testing stop directive functionality...')

	// Template with stop directive
	template_content := 'Before stop
<#stop "Stopping here">
After stop (should not appear)'

	// Test data
	data := map[string]veemarker.Any{}

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	result := engine.render_string(template_content, data) or {
		println('Engine error: $err')
		return
	}

	println('Result:')
	println(result)

	// Test with message parameter
	println('\nTesting stop with message...')
	template_with_message := 'Content before
<#stop "Custom stop message">
Content after (should not appear)'

	result2 := engine.render_string(template_with_message, data) or {
		println('Engine error: $err')
		return
	}

	println('Result 2:')
	println(result2)
}