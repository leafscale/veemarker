import veemarker

fn main() {
	// Test noparse directive
	template := '<#noparse>test</#noparse>'

	mut lexer := veemarker.new_lexer(template)
	tokens := lexer.tokenize() or {
		eprintln('Lexer error: ${err}')
		return
	}

	println('Tokens:')
	for i, token in tokens {
		println('  ${i}: ${token.type} = "${token.value}" (pos: ${token.pos})')
	}
}