import veemarker

fn main() {
	println('Testing macro functionality...')

	// Template with macro definition and macro call
	template_content := '<#macro greet name>
Hello, \${name}! Welcome to VeeMarker.
</#macro>

<@greet name="World"/>
<@greet name="Alice"/>
<@greet name="Bob"/>'

	// Test data
	data := map[string]veemarker.Any{}

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	result := engine.render_string(template_content, data) or {
		println('Engine error: $err')
		return
	}

	println('Result:')
	println(result)
}