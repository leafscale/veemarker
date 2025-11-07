module main

import leafscale.veemarker

fn main() {
	println('Testing <#else> directive...\n')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	template := r'<#if true>
True branch
<#else>
False branch
</#if>'

	data := map[string]veemarker.Any{}

	result := engine.render_string(template, data) or {
		println('ERROR: ${err}')
		return
	}

	println('SUCCESS!')
	println('Result:')
	println(result)
}
