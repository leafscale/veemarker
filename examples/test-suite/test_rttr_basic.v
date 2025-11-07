module main

import leafscale.veemarker

struct Person {
	name string
	age  int
}

fn test_register_and_wrap_struct() {
	println('[TEST] register_and_wrap_struct')

	// Register the type
	veemarker.register_type[Person]()

	// Create a person
	person := Person{
		name: 'Alice'
		age:  30
	}

	// Wrap the person
	wrapped := veemarker.wrap(person)

	// Verify it's a StructValue
	match wrapped {
		veemarker.StructValue {
			assert wrapped.type_name == 'Person', 'Expected type_name to be Person'
			println('  ✓ Wrapped struct has correct type_name: ${wrapped.type_name}')
		}
		else {
			panic('Expected StructValue, got ${typeof(wrapped).name}')
		}
	}

	println('  ✓ Test passed\n')
}

fn test_resolve_struct_property() {
	println('[TEST] resolve_struct_property')

	// Register type
	veemarker.register_type[Person]()

	// Create and wrap person
	person := Person{
		name: 'Bob'
		age:  25
	}
	wrapped := veemarker.wrap(person)

	// Resolve name property
	name := veemarker.resolve_property(wrapped, 'name') or {
		panic('Failed to resolve name: ${err}')
	}

	match name {
		string {
			assert name == 'Bob', 'Expected name to be Bob'
			println('  ✓ Resolved name: ${name}')
		}
		else {
			panic('Expected string, got ${typeof(name).name}')
		}
	}

	// Resolve age property
	age := veemarker.resolve_property(wrapped, 'age') or {
		panic('Failed to resolve age: ${err}')
	}

	match age {
		int {
			assert age == 25, 'Expected age to be 25'
			println('  ✓ Resolved age: ${age}')
		}
		else {
			panic('Expected int, got ${typeof(age).name}')
		}
	}

	// Test invalid property
	veemarker.resolve_property(wrapped, 'invalid_field') or {
		println('  ✓ Invalid field correctly returns error: ${err}')
		println('  ✓ Test passed\n')
		return
	}

	panic('Expected error for invalid field')
}

fn test_struct_in_template() {
	println('[TEST] struct_in_template')

	// Register type
	veemarker.register_type[Person]()

	// Create person
	person := Person{
		name: 'Charlie'
		age:  35
	}

	// Create template data
	data := {
		'person': veemarker.wrap(person)
	}

	// Create template
	template := 'Name: \${person.name}, Age: \${person.age}'

	// Render
	mut engine := veemarker.new_engine(veemarker.EngineConfig{})
	result := engine.render_string(template, data) or {
		panic('Failed to render: ${err}')
	}

	expected := 'Name: Charlie, Age: 35'
	assert result == expected, 'Expected "${expected}", got "${result}"'
	println('  ✓ Rendered: ${result}')
	println('  ✓ Test passed\n')
}

fn test_is_registered() {
	println('[TEST] is_registered')

	struct UnregisteredType {
		value string
	}

	// Register Person
	veemarker.register_type[Person]()

	// Check registered type
	assert veemarker.is_registered[Person]() == true, 'Person should be registered'
	println('  ✓ Person is registered')

	// Check unregistered type
	assert veemarker.is_registered[UnregisteredType]() == false, 'UnregisteredType should not be registered'
	println('  ✓ UnregisteredType is not registered')
	println('  ✓ Test passed\n')
}

fn main() {
	println('='.repeat(60))
	println('Running RTTR Basic Tests')
	println('='.repeat(60) + '\n')

	test_register_and_wrap_struct()
	test_resolve_struct_property()
	test_struct_in_template()
	test_is_registered()

	println('='.repeat(60))
	println('All tests passed!')
	println('='.repeat(60))
}
