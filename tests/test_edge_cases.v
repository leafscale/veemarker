module main

import leafscale.veemarker

fn test_space_before_gt() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	// Space before > in list directive
	template := r'<#list items as x >${x}</#list>'
	mut data := map[string]veemarker.Any{}
	data['items'] = veemarker.Any([veemarker.Any('a')])
	result := engine.render_string(template, data) or {
		println('  Error: ${err}')
		return false
	}
	return result.trim_space() == 'a'
}

fn test_comparison_then_directive_end() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	// Comparison followed by immediate directive end
	template := r'<#if 5 > 3>yes</#if>'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or {
		println('  Error: ${err}')
		return false
	}
	return result.trim_space() == 'yes'
}

fn test_chained_property_access() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	// Multiple levels of property access
	template := r'<#assign url = obj.nested.deep.prop>Value: ${url}'
	mut nested := map[string]veemarker.Any{}
	mut deep := map[string]veemarker.Any{}
	deep['prop'] = veemarker.Any('result')
	nested['deep'] = veemarker.Any(deep)
	mut obj := map[string]veemarker.Any{}
	obj['nested'] = veemarker.Any(nested)
	mut data := map[string]veemarker.Any{}
	data['obj'] = veemarker.Any(obj)
	result := engine.render_string(template, data) or {
		println('  Error: ${err}')
		return false
	}
	return result.contains('result')
}

fn test_alpine_multiple_attributes() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	// Multiple Alpine.js attributes
	template := r'<#macro comp>
<div @click="fn1()" @mouseover="fn2()" :class="cls" x-data="{}">
	Content
</div>
</#macro>
<@comp />'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or {
		println('  Error: ${err}')
		return false
	}
	return result.contains('@click') && result.contains('@mouseover') && result.contains(':class')
}

fn test_gt_in_string_literal() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	// > character inside string literal
	template := r'<#assign msg = "value > 5">Text: ${msg}'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or {
		println('  Error: ${err}')
		return false
	}
	return result.contains('value > 5')
}

fn main() {
	println('╔════════════════════════════════════════════════════════════╗')
	println('║  Edge Case Testing                                        ║')
	println('╚════════════════════════════════════════════════════════════╝')

	tests := [
		test_space_before_gt,
		test_comparison_then_directive_end,
		test_chained_property_access,
		test_alpine_multiple_attributes,
		test_gt_in_string_literal
	]

	test_names := [
		'Space before > in directive',
		'Comparison then immediate directive end',
		'Chained property access',
		'Multiple Alpine.js special attributes',
		'> character inside string literal'
	]

	mut passed := 0
	mut failed := 0

	for i, test_fn in tests {
		println('\n=== Test ${i+1}: ${test_names[i]} ===')
		if test_fn() {
			println('✓ PASS')
			passed++
		} else {
			println('✗ FAIL')
			failed++
		}
	}

	println('\n╔════════════════════════════════════════════════════════════╗')
	println('║  Test Results                                              ║')
	println('╠════════════════════════════════════════════════════════════╣')
	println('║  Passed: ${passed:2}/${tests.len}                                              ║')
	println('║  Failed: ${failed:2}/${tests.len}                                              ║')
	println('╚════════════════════════════════════════════════════════════╝')

	if failed > 0 {
		exit(1)
	}
}
