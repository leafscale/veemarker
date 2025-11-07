module main

import leafscale.veemarker

fn main() {
	println('Testing < operator issue...\\n')

	template := r'<#if itemName?has_content>
<p style="margin-bottom: 1.5rem; color: #666;">
Delete "${itemName?html}"?
</p>
</#if>'

	println('=== TEMPLATE ===')
	println(template)
	println('\\n=== LEXER OUTPUT ===')

	mut lexer := veemarker.new_lexer(template)
	tokens := lexer.tokenize() or {
		println('LEXER ERROR: ${err}')
		return
	}

	for i, token in tokens {
		println('${i:3}: ${token.type:-25} "${token.value}" (line ${token.line}, col ${token.column})')
	}
}
