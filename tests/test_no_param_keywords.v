module main

import leafscale.veemarker

fn test_else() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#if false>A<#else>B</#if>'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or { return false }
	return result.trim_space() == 'B'
}

fn test_attempt_recover() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#attempt>${missing}<#recover>Error handled</#attempt>'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or {
		// Lexer should succeed even if evaluator/parser has issues
		println('  Error: ${err}')
		return false
	}
	return result.contains('Error handled')
}

fn test_noparse() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#noparse>${var}</#noparse>'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or { return false }
	return result.contains(r'${var}')
}

fn test_switch_default() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#switch val><#case 1>One<#case 2>Two<#default>Other</#switch>'
	mut data := map[string]veemarker.Any{}
	data['val'] = veemarker.Any(99)
	result := engine.render_string(template, data) or { return false }
	return result.trim_space() == 'Other'
}

fn main() {
	println('╔════════════════════════════════════════════════════════════╗')
	println('║  Testing No-Parameter Keywords                            ║')
	println('╚════════════════════════════════════════════════════════════╝')

	tests := [
		test_else,
		test_attempt_recover,
		test_noparse,
		test_switch_default
	]

	test_names := [
		'<#else> directive',
		'<#attempt> and <#recover> directives',
		'<#noparse> directive',
		'<#default> in switch directive'
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
