module veemarker

// Test suite for Alpine.js built-in functions
// Tests ?html, ?js_string, and ?alpine_json methods
// Uses integration testing via template rendering

// ============================================================================
// HTML Escaping Tests
// ============================================================================

fn test_html_escaping_basic() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = '<script>alert("xss")</script>'

	result := engine.render_string(r'${text?html}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == '&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;'
}

fn test_html_escaping_ampersand() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'A & B'

	result := engine.render_string(r'${text?html}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == 'A &amp; B'
}

fn test_html_escaping_quotes() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'He said "Hello" and she said \'Hi\''

	result := engine.render_string(r'${text?html}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == 'He said &quot;Hello&quot; and she said &#39;Hi&#39;'
}

fn test_html_escaping_empty_string() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = ''

	result := engine.render_string(r'${text?html}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == ''
}

fn test_html_escaping_all_special_chars() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = '&<>"\''

	result := engine.render_string(r'${text?html}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == '&amp;&lt;&gt;&quot;&#39;'
}

fn test_html_xss_prevention() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = '<img src=x onerror=alert(1)>'

	result := engine.render_string(r'${text?html}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == '&lt;img src=x onerror=alert(1)&gt;'
	assert !result.contains('<')
	assert !result.contains('>')
}

// ============================================================================
// JavaScript String Escaping Tests
// ============================================================================

fn test_js_string_escaping_basic() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = "it's"

	result := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == "it\\'s"
}

fn test_js_string_escaping_double_quotes() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'He said "Hello"'

	result := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == 'He said \\"Hello\\"'
}

fn test_js_string_escaping_backslash() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'C:\\path\\to\\file'

	result := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == 'C:\\\\path\\\\to\\\\file'
}

fn test_js_string_escaping_newlines() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'line1\nline2'

	result := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == 'line1\\nline2'
}

fn test_js_string_escaping_control_chars() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'tab\there\r\n'

	result := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == 'tab\\there\\r\\n'
}

fn test_js_string_escaping_empty_string() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = ''

	result := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == ''
}

fn test_js_string_injection_prevention() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = '"; alert(1); //'

	result := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == '\\"; alert(1); //'
}

fn test_js_string_escaping_null_byte() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'test\0null'

	result := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == 'test\\0null'
}

fn test_js_string_escaping_unicode_line_separators() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}

	// Test Unicode line separator (U+2028)
	data['text'] = 'line\u2028separator'
	result := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == 'line\\u2028separator'

	// Test Unicode paragraph separator (U+2029)
	data['text'] = 'para\u2029separator'
	result2 := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result2 == 'para\\u2029separator'
}

// ============================================================================
// Alpine JSON Tests
// ============================================================================

fn test_alpine_json_string() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'test'

	result := engine.render_string(r'${text?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == '"test"'
}

fn test_alpine_json_string_with_quotes() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'test "quoted"'

	result := engine.render_string(r'${text?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	// json.encode will properly escape quotes
	assert result.contains('\\"')
}

fn test_alpine_json_integer() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['num'] = 42

	result := engine.render_string(r'${num?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == '42'
}

fn test_alpine_json_float() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['num'] = 3.14

	result := engine.render_string(r'${num?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == '3.14'
}

fn test_alpine_json_bool_true() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['flag'] = true

	result := engine.render_string(r'${flag?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == 'true'
}

fn test_alpine_json_bool_false() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['flag'] = false

	result := engine.render_string(r'${flag?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result == 'false'
}

fn test_alpine_json_map() {
	mut engine := new_engine(EngineConfig{})

	mut obj := map[string]Any{}
	obj['name'] = 'Product'
	obj['price'] = 99

	mut data := map[string]Any{}
	data['obj'] = obj

	result := engine.render_string(r'${obj?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	// Verify it's valid JSON
	assert result.contains('"name"')
	assert result.contains('"price"')
	assert result.starts_with('{')
	assert result.ends_with('}')
}

fn test_alpine_json_array() {
	mut engine := new_engine(EngineConfig{})

	arr := [Any('item1'), Any('item2'), Any('item3')]

	mut data := map[string]Any{}
	data['arr'] = arr

	result := engine.render_string(r'${arr?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	// Verify it's valid JSON array
	assert result.starts_with('[')
	assert result.ends_with(']')
	assert result.contains('"item1"')
	assert result.contains('"item2"')
	assert result.contains('"item3"')
}

fn test_alpine_json_nested_structure() {
	mut engine := new_engine(EngineConfig{})

	mut inner := map[string]Any{}
	inner['city'] = 'NYC'

	mut outer := map[string]Any{}
	outer['name'] = 'Alice'
	outer['address'] = Any(inner)

	mut data := map[string]Any{}
	data['obj'] = outer

	result := engine.render_string(r'${obj?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	// Verify nested structure
	assert result.contains('"name"')
	assert result.contains('"address"')
	assert result.contains('"city"')
	assert result.contains('"NYC"')
}

fn test_alpine_json_empty_map() {
	mut engine := new_engine(EngineConfig{})

	obj := map[string]Any{}

	mut data := map[string]Any{}
	data['obj'] = obj

	result := engine.render_string(r'${obj?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	assert result == '{}'
}

fn test_alpine_json_empty_array() {
	mut engine := new_engine(EngineConfig{})

	arr := []Any{}

	mut data := map[string]Any{}
	data['arr'] = arr

	result := engine.render_string(r'${arr?alpine_json}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	assert result == '[]'
}

// ============================================================================
// Integration Tests (Full Templates)
// ============================================================================

fn test_html_in_full_template() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['comment'] = '<script>alert("xss")</script>'

	template := r'<div>${comment?html}</div>'
	result := engine.render_string(template, data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	assert result == '<div>&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;</div>'
}

fn test_js_string_in_full_template() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['message'] = 'He said "Hello"'

	template := r'<script>const msg = "${message?js_string}";</script>'
	result := engine.render_string(template, data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	assert result.contains('\\"Hello\\"')
}

fn test_alpine_json_in_full_template() {
	mut engine := new_engine(EngineConfig{})

	mut product := map[string]Any{}
	product['name'] = 'Test Product'
	product['price'] = 49.99
	product['in_stock'] = true

	mut data := map[string]Any{}
	data['product'] = product

	template := r'<div x-data="${product?alpine_json}"></div>'
	result := engine.render_string(template, data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	assert result.contains('x-data=')
	assert result.contains('"name"')
	assert result.contains('"price"')
	assert result.contains('"in_stock"')
}

fn test_chaining_with_other_builtins() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = '<hello world>'

	// Test chaining: upper_case then html
	template := r'${text?upper_case?html}'
	result := engine.render_string(template, data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	assert result == '&lt;HELLO WORLD&gt;'
}

fn test_alpine_json_with_array_of_objects() {
	mut engine := new_engine(EngineConfig{})

	mut item1 := map[string]Any{}
	item1['id'] = 1
	item1['name'] = 'Item 1'

	mut item2 := map[string]Any{}
	item2['id'] = 2
	item2['name'] = 'Item 2'

	items := [Any(item1), Any(item2)]

	mut data := map[string]Any{}
	data['items'] = items

	template := r'<div x-data="{ items: ${items?alpine_json} }"></div>'
	result := engine.render_string(template, data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	assert result.contains('x-data=')
	assert result.contains('"id"')
	assert result.contains('"name"')
}

// ============================================================================
// Edge Cases
// ============================================================================

fn test_special_unicode_characters() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'Hello 👋 World'

	result := engine.render_string(r'${text?html}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}
	assert result.contains('👋')
}

fn test_very_long_string() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}

	// Test performance with long string
	mut long_str := ''
	for _ in 0 .. 1000 {
		long_str += 'test '
	}
	data['text'] = long_str

	result := engine.render_string(r'${text?html}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	assert result.len > 0
}

fn test_mixed_escaping_requirements() {
	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = '&<>"\'\\n\\r\\t'

	result := engine.render_string(r'${text?js_string}', data) or {
		assert false, 'Should not error: ${err}'
		return
	}

	assert result.contains('\\\\')
	assert result.contains("\\'")
	assert result.contains('\\"')
}
