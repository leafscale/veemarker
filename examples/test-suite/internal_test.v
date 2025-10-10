module veemarker

import os

fn main() {
	println('Testing VeeMarker Template Engine')
	println('==================================')

	// Core functionality tests
	test_interpolation()
	test_conditionals()
	test_lists()
	test_expressions()
	test_builtin_functions()
	test_nested_objects()
	test_assign_directive()
	test_comments()
	test_error_handling()
	test_file_templates()

	println('\n✓ All tests completed successfully!')
}

fn test_interpolation() {
	println('\nTest 1: Simple Interpolation')
	println('-----------------------------')

	template := r'Hello, ${name}! You are ${age} years old.'

	mut data := map[string]Any{}
	data['name'] = 'Alice'
	data['age'] = 30

	mut engine := new_engine(EngineConfig{})
	result := engine.render_string(template, data) or {
		eprintln('Error: ${err}')
		return
	}

	println('Template: ${template}')
	println('Result: ${result}')
}

fn test_conditionals() {
	println('\nTest 2: Conditionals')
	println('--------------------')

	template := '<#if isAdmin>Welcome Admin!<#else>Welcome User!</#if>'

	// Test with admin
	mut admin_data := map[string]Any{}
	admin_data['isAdmin'] = true

	mut engine := new_engine(EngineConfig{})
	admin_result := engine.render_string(template, admin_data) or {
		eprintln('Error: ${err}')
		return
	}

	println('Template: ${template}')
	println('Admin result: ${admin_result}')

	// Test with non-admin
	mut user_data := map[string]Any{}
	user_data['isAdmin'] = false

	user_result := engine.render_string(template, user_data) or {
		eprintln('Error: ${err}')
		return
	}

	println('User result: ${user_result}')
}

fn test_lists() {
	println('\nTest 3: List Iteration')
	println('----------------------')

	// Basic list
	template := '<#list items as item>${item} </#list>'

	mut data := map[string]Any{}
	data['items'] = [Any('apple'), Any('banana'), Any('orange')]

	mut engine := new_engine(EngineConfig{})
	result := engine.render_string(template, data) or {
		eprintln('Error: ${err}')
		return
	}

	println('Template: ${template}')
	println('Result: ${result}')

	// List with index
	template_with_index := '<#list items as item>${item_index}: ${item}\n</#list>'
	result_with_index := engine.render_string(template_with_index, data) or {
		eprintln('Error: ${err}')
		return
	}
	println('\nWith index:')
	println('Result: ${result_with_index}')
}

fn test_expressions() {
	println('\nTest 4: Expression Evaluation')
	println('-----------------------------')

	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['x'] = 10
	data['y'] = 3
	data['name'] = 'test'
	data['active'] = true

	// Arithmetic expressions
	tests := [
		'${x + y}', // 13
		'${x - y}', // 7
		'${x * y}', // 30
		'${x / y}', // 3
		'${x % y}', // 1
		'${x > y}', // true
		'${x == 10}', // true
		'${active && true}', // true
		'${!active}', // false
	]

	for template in tests {
		result := engine.render_string(template, data) or {
			eprintln('Error in "${template}": ${err}')
			continue
		}
		println('${template} = ${result}')
	}
}

fn test_builtin_functions() {
	println('\nTest 5: Built-in Functions')
	println('--------------------------')

	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}
	data['text'] = 'hello world'
	data['items'] = [Any('a'), Any('b'), Any('c')]

	// String functions
	string_tests := [
		r'${text?upper_case}', // HELLO WORLD
		r'${text?lower_case}', // hello world
		r'${text?cap_first}', // Hello world
		r'${text?length}', // 11
		r'${text?trim}', // hello world
		r'${text?replace("world", "V")}', // hello V
	]

	for template in string_tests {
		result := engine.render_string(template, data) or {
			eprintln('Error in "${template}": ${err}')
			continue
		}
		println('${template} = ${result}')
	}

	// Collection functions
	println('\nCollection functions:')
	collection_tests := [
		r'${items?size}', // 3
		r'${items?first}', // a
		r'${items?last}', // c
	]

	for template in collection_tests {
		result := engine.render_string(template, data) or {
			eprintln('Error in "${template}": ${err}')
			continue
		}
		println('${template} = ${result}')
	}
}

fn test_nested_objects() {
	println('\nTest 6: Nested Objects & Properties')
	println('-----------------------------------')

	mut engine := new_engine(EngineConfig{})
	mut data := map[string]Any{}

	// Create nested user object
	mut user := map[string]Any{}
	user['name'] = 'Alice'
	user['email'] = 'alice@example.com'

	mut profile := map[string]Any{}
	profile['age'] = 30
	profile['city'] = 'New York'
	user['profile'] = profile

	data['user'] = user
	data['scores'] = [Any(85), Any(92), Any(78)]

	templates := [
		'User: ${user.name}',
		'Email: ${user.email}',
		'Age: ${user.profile.age}',
		'City: ${user.profile.city}',
		'First score: ${scores[0]}',
	]

	for template in templates {
		result := engine.render_string(template, data) or {
			eprintln('Error in "${template}": ${err}')
			continue
		}
		println(result)
	}
}

fn test_assign_directive() {
	println('\nTest 7: Assign Directive')
	println('------------------------')

	template := '
<#assign greeting = "Hello">
<#assign name = "VeeMarker">
${greeting}, ${name}!
<#assign result = x + y>
Calculation: ${x} + ${y} = ${result}'

	mut data := map[string]Any{}
	data['x'] = 15
	data['y'] = 25

	mut engine := new_engine(EngineConfig{})
	result := engine.render_string(template, data) or {
		eprintln('Error: ${err}')
		return
	}

	println('Result: ${result}')
}

fn test_comments() {
	println('\nTest 8: Comments')
	println('----------------')

	template := "Before comment
<#-- This is a comment and won't appear -->
After comment"

	mut engine := new_engine(EngineConfig{})
	data := map[string]Any{}

	result := engine.render_string(template, data) or {
		eprintln('Error: ${err}')
		return
	}

	println('Template: ${template}')
	println('Result: ${result}')
}

fn test_error_handling() {
	println('\nTest 9: Error Handling')
	println('----------------------')

	mut engine := new_engine(EngineConfig{})
	data := map[string]Any{}

	// Test undefined variable
	template1 := '${undefined_var}'
	result1 := engine.render_string(template1, data) or {
		println('Expected error for undefined variable: ${err}')
		'error caught'
	}

	// Test invalid property access
	data['text'] = 'string value'
	template2 := '${text.invalid_property}'
	result2 := engine.render_string(template2, data) or {
		println('Expected error for invalid property: ${err}')
		'error caught'
	}

	// Test unclosed directive
	template3 := '<#if true>Missing close tag'
	result3 := engine.render_string(template3, data) or {
		println('Expected error for unclosed directive: ${err}')
		'error caught'
	}
}

fn test_file_templates() {
	println('\nTest 10: File Templates')
	println('-----------------------')

	// Create test template directory
	os.mkdir('test_templates') or {}

	// Create a test template file
	test_template := 'Welcome to VeeMarker!
===================
User: ${user.name}
Role: ${user.role}

<#if user.isAdmin>
Admin Dashboard
---------------
<#list adminFeatures as feature>
- ${feature}
</#list>
</#if>'

	os.write_file('test_templates/welcome.ftl', test_template) or {
		eprintln('Failed to create test template: ${err}')
		return
	}

	// Create engine with template directory
	mut engine := new_engine(EngineConfig{
		template_dir: './test_templates'
		dev_mode:     true
	})

	// Prepare data
	mut data := map[string]Any{}
	mut user := map[string]Any{}
	user['name'] = 'Bob'
	user['role'] = 'Administrator'
	user['isAdmin'] = true
	data['user'] = user
	data['adminFeatures'] = [
		Any('User Management'),
		Any('Content Editor'),
		Any('System Settings'),
	]

	// Render the file template
	result := engine.render('welcome.ftl', data) or {
		eprintln('Error rendering file template: ${err}')
		return
	}

	println('File template result:')
	println(result)

	// Clean up
	os.rm('test_templates/welcome.ftl') or {}
	os.rmdir('test_templates') or {}
}
