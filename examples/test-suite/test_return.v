import leafscale.veemarker

fn main() {
	println('Testing return directive functionality...')

	// Template with macro and return directive
	template_content := '<#macro test>
Before return in macro
<#return>
After return (should not appear)
</#macro>

<@test/>
After macro call'

	// Test data
	data := map[string]veemarker.Any{}

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	result := engine.render_string(template_content, data) or {
		println('Engine error: $err')
		return
	}

	println('Result:')
	println('|${result}|')

	// Test with return message in macro
	println('\nTesting return with message in macro...')
	template_with_message := '<#macro test2>
Before return in macro
<#return "Custom return message">
After return (should not appear)
</#macro>

<@test2/>
After macro call'

	result2 := engine.render_string(template_with_message, data) or {
		println('Engine error: $err')
		return
	}

	println('Result 2:')
	println('|${result2}|')
}