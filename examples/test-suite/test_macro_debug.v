import veemarker

fn main() {
	println('Testing macro tokenization and parsing...')

	// Test 1: Simple macro definition only
	template1 := '<#macro hello>Hello World</#macro>'
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	data := map[string]veemarker.Any{}

	result1 := engine.render_string(template1, data) or {
		println('Test 1 Error: $err')
		return
	}
	println('Test 1 (macro definition only): |${result1}|')

	// Test 2: Macro call only (no definition) - should fail
	template2 := '<@hello/>'
	result2 := engine.render_string(template2, data) or {
		println('Test 2 Error (expected): $err')
		''
	}
	println('Test 2 (call without definition): |${result2}|')

	// Test 3: Macro definition + call
	template3 := '<#macro hello>Hello World</#macro><@hello/>'
	result3 := engine.render_string(template3, data) or {
		println('Test 3 Error: $err')
		return
	}
	println('Test 3 (definition + call): |${result3}|')

	// Test 4: Check if the call is being parsed as text
	template4 := 'Before <@hello/> After'
	result4 := engine.render_string(template4, data) or {
		println('Test 4 Error: $err')
		return
	}
	println('Test 4 (call as text): |${result4}|')
}