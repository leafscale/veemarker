module main

import leafscale.veemarker

fn main() {
	println('╔════════════════════════════════════════════════════════════╗')
	println('║  VeeMarker Include Directive Test                         ║')
	println('╚════════════════════════════════════════════════════════════╝')

	mut engine := veemarker.new_engine(veemarker.EngineConfig{})

	// Test: Include directive with string literal
	// We expect it to fail to find the file, but that means the lexer succeeded!
	println('\n=== Test: <#include "shared/header.vtpl"> ===')
	template := '<#include "shared/header.vtpl">'
	mut data := map[string]veemarker.Any{}

	result := engine.render_string(template, data) or {
		// Check if error is about missing file (lexer succeeded) or about tokens (lexer failed)
		error_msg := err.msg()
		if error_msg.contains('Failed to read template') {
			println('Template: ${template}')
			println('Status: ✓ PASS - Lexer succeeded (> recognized as directive_end)')
			println('Note: File not found error expected since template does not exist')
			return
		} else {
			println('ERROR: ${err}')
			println('Status: ✗ FAIL - Lexer error (> not recognized as directive_end)')
			panic(err)
		}
	}

	println('Template: ${template}')
	println('Result: "${result}"')
	println('Status: ✓ PASS')

	println('\n╔════════════════════════════════════════════════════════════╗')
	println('║  Test Complete                                             ║')
	println('╚════════════════════════════════════════════════════════════╝')
}
