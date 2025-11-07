module main

import leafscale.veemarker

fn test_comparison_operator() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#if url?size > 0>Has content</#if>'
	mut data := map[string]veemarker.Any{}
	data['url'] = veemarker.Any('test')
	result := engine.render_string(template, data) or { return false }
	return result.trim_space() == 'Has content'
}

fn test_property_access() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#assign url = base + "/" + item.code>URL: ${url}'
	mut data := map[string]veemarker.Any{}
	mut item := map[string]veemarker.Any{}
	item['code'] = veemarker.Any('abc')
	data['base'] = veemarker.Any('http://x.co')
	data['item'] = veemarker.Any(item)
	result := engine.render_string(template, data) or { return false }
	return result.contains('http://x.co/abc')
}

fn test_include_keyword() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#include "nonexistent.vtpl">'
	data := map[string]veemarker.Any{}
	_ := engine.render_string(template, data) or {
		// Lexer succeeded if we get file not found, not lexer error
		return err.msg().contains('Failed to read')
	}
	return false
}

fn test_as_keyword() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#list items as x>${x}</#list>'
	mut data := map[string]veemarker.Any{}
	data['items'] = veemarker.Any([veemarker.Any('a'), veemarker.Any('b')])
	result := engine.render_string(template, data) or { return false }
	return result.trim_space() == 'ab'
}

fn test_macro_keyword() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#macro toast>
<div @click="test" :class="active" x-data="{}">
	Alpine.js attributes preserved
</div>
</#macro>
<@toast />'
	data := map[string]veemarker.Any{}
	result := engine.render_string(template, data) or { return false }
	return result.contains('@click') && result.contains(':class') && result.contains('x-data')
}

fn test_multiple_comparisons() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#if a > 5 && b > 3>Both greater</#if>'
	mut data := map[string]veemarker.Any{}
	data['a'] = veemarker.Any(10)
	data['b'] = veemarker.Any(4)
	result := engine.render_string(template, data) or { return false }
	return result.trim_space() == 'Both greater'
}

fn test_greater_equal() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#if score >= 90>Excellent</#if>'
	mut data := map[string]veemarker.Any{}
	data['score'] = veemarker.Any(95)
	result := engine.render_string(template, data) or { return false }
	return result.trim_space() == 'Excellent'
}

fn test_nested_directives() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	template := r'<#list nums as n><#if n > 5>${n}</#if></#list>'
	mut data := map[string]veemarker.Any{}
	data['nums'] = veemarker.Any([
		veemarker.Any(3),
		veemarker.Any(7),
		veemarker.Any(9)
	])
	result := engine.render_string(template, data) or { return false }
	return result.trim_space() == '79'
}

fn test_question_builtin() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	// Test that > after ?builtin is treated as directive_end, not comparison
	template := r'<#if itemName?has_content>Has content</#if>'
	mut data := map[string]veemarker.Any{}
	data['itemName'] = veemarker.Any('test')
	result := engine.render_string(template, data) or { return false }
	return result.trim_space() == 'Has content'
}

fn test_question_builtin_with_html() bool {
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	// Test that HTML content after ?builtin directive is treated as text
	template := r'<#if name?has_content>
<p style="color: red;">Hello ${name?html}!</p>
</#if>'
	mut data := map[string]veemarker.Any{}
	data['name'] = veemarker.Any('World')
	result := engine.render_string(template, data) or { return false }
	return result.contains('<p style="color: red;">Hello World!</p>')
}

fn main() {
	println('╔════════════════════════════════════════════════════════════╗')
	println('║  VeeMarker Comprehensive > Operator Test Suite            ║')
	println('╚════════════════════════════════════════════════════════════╝')

	tests := [
		test_comparison_operator,
		test_property_access,
		test_include_keyword,
		test_as_keyword,
		test_macro_keyword,
		test_multiple_comparisons,
		test_greater_equal,
		test_nested_directives,
		test_question_builtin,
		test_question_builtin_with_html
	]

	test_names := [
		'Comparison operator (url?size > 0)',
		'Directive end after property access (item.code>)',
		'Directive end after keyword_include',
		'Directive end after keyword_as (list as item>)',
		'Directive end after keyword_macro (Alpine.js @ support)',
		'Multiple comparisons (a > 5 && b > 3)',
		'Greater-equal comparison (score >= 90)',
		'Nested directives (list + if with comparison)',
		'Directive end after ?builtin (itemName?has_content>)',
		'HTML content after ?builtin directive (<p> tag as text)'
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
