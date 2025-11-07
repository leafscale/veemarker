module main

import leafscale.veemarker

fn main() {
	println('Testing copyButton macro from bug report...\n')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Exact template from bug report
	template := r'<#macro copyButton text label="Copy" successLabel="✓ Copied!" class="">
<div x-data="{ copied: false }" class="inline-block ${class}">
    <button type="button" class="btn btn-copy">
        <span x-show="!copied">${label}</span>
        <span x-show="copied" x-cloak>${successLabel}</span>
    </button>
</div>
</#macro>

<@copyButton text="https://example.com/short" />'

	mut data := map[string]veemarker.Any{}
	data['itemShortUrl'] = veemarker.Any('https://example.com/short')

	result := engine.render_string(template, data) or {
		println('ERROR: ${err}')
		return
	}

	println('Template: copyButton macro with defaults')
	println('\nResult:')
	println(result)

	// Verify the defaults were applied
	if result.contains('<span x-show="!copied">Copy</span>') {
		println('\n✓ PASS - Default label="Copy" was applied')
	} else {
		println('\n✗ FAIL - Default label was not applied')
	}

	if result.contains('<span x-show="copied" x-cloak>✓ Copied!</span>') {
		println('✓ PASS - Default successLabel="✓ Copied!" was applied')
	} else {
		println('✗ FAIL - Default successLabel was not applied')
	}

	if result.contains('class="inline-block "') {
		println('✓ PASS - Default class="" (empty string) was applied')
	} else {
		println('✗ FAIL - Default class was not applied')
	}
}
