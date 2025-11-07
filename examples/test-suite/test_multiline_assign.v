module main

import leafscale.veemarker

fn main() {
	// Test template with multi-line assign
	template_str := '<#assign page_styles>
.login-container {
    color: red;
}
</#assign>
<#assign body_content>
<div class="content">Test</div>
</#assign>
\${page_styles}
\${body_content}'

	mut engine := veemarker.new_engine(veemarker.EngineConfig{
		dev_mode: true
	})

	data := map[string]veemarker.Any{}

	result := engine.render_string(template_str, data) or {
		eprintln('Error: ${err}')
		return
	}

	println('Result:')
	println(result)
}