import os
import veemarker

fn main() {
	template_content := os.read_file('test_elseif.vtpl') or {
		println('Error reading template: ${err}')
		return
	}

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	result := engine.render_string(template_content, {}) or {
		println('Template error: ${err}')
		return
	}

	println('Template rendered successfully:')
	println(result)
}