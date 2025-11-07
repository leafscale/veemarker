module main

import leafscale.veemarker

fn main() {
	println('Testing Alpine.js @ syntax in macro...\n')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Template with macro containing Alpine.js @ syntax
	template := r'<#macro toastContainer>
<div @toast.window="show($event.detail.message)">
	Toast container
</div>
</#macro>

<@toastContainer />
'

	mut data := map[string]veemarker.Any{}

	result := engine.render_string(template, data) or {
		println('ERROR: ${err}')
		println('\nThis reproduces the Alpine.js @ bug!')
		return
	}

	println('SUCCESS!')
	println('Result:')
	println(result)
}
