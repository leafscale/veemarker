import veemarker

fn main() {
	// Test noparse directive
	template := '<#noparse>
	This is literal text with $' + '{interpolation} that should not be processed.
	Even directives like <#if true>test</#if> should be preserved.
	</#noparse>

	Normal interpolation: $' + '{name}'

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	mut data := map[string]veemarker.Any{}
	data['name'] = 'Alice'

	result := engine.render_string(template, data) or {
		eprintln('Error: ${err}')
		return
	}

	println('Result:')
	println(result)
}