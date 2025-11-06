/******************************************************************************
                __               ____                __
               / /   ___  ____ _/ __/_____________ _/ /__
              / /   / _ \/ __ `/ /_/ ___/ ___/ __ `/ / _ \
             / /___/  __/ /_/ / __(__  ) /__/ /_/ / /  __/
            /_____/\___/\__,_/_/ /____/\___/\__,_/_/\___/

    (C)opyright 2025, Leafscale, LLC -  https://www.leafscale.com

    Project: VeeMarker
   Filename: lexer.v
    Authors: Chris Tusa <chris.tusa@leafscale.com>
    License: <see LICENSE file included with this source code>
Description: Lexical analyzer that tokenizes template source code

******************************************************************************/
module veemarker

// Token types for FreeMarker syntax
enum TokenType {
	// Basic tokens
	text // Plain text content
	eof  // End of file

	// Interpolation tokens
	interpolation_start // ${
	interpolation_end   // }

	// Directive tokens
	directive_start // <#
	directive_end   // >
	directive_close // </#
	comment_start   // <#--
	comment_end     // -->
	macro_call_start // <@
	macro_call_end   // />

	// Expression tokens
	identifier // Variable or property name
	dot        // .
	lbracket   // [
	rbracket   // ]
	lparen     // (
	rparen     // )
	comma      // ,
	question   // ?
	colon      // :

	// Literals
	string_literal  // "string" or 'string'
	number_literal  // 123 or 123.45
	boolean_literal // true or false

	// Operators
	equals        // =
	not_equals    // !=
	less_than     // <
	less_equal    // <=
	greater_than  // >
	greater_equal // >=
	plus          // +
	minus         // -
	multiply      // *
	divide        // /
	modulo        // %
	and_op        // &&
	or_op         // ||
	not_op        // !
	default_op    // ! (in default value context)

	// Keywords
	keyword_if      // if
	keyword_elseif  // elseif
	keyword_else    // else
	keyword_list    // list
	keyword_as      // as
	keyword_assign  // assign
	keyword_include // include
	keyword_noparse // noparse
	keyword_attempt // attempt
	keyword_recover // recover
	keyword_macro   // macro
	keyword_stop    // stop
	keyword_return  // return
	keyword_sep     // sep
	keyword_switch  // switch
	keyword_case    // case
	keyword_default // default
}

// Token represents a lexical token
struct Token {
pub:
	type   TokenType
	value  string
	line   int
	column int
	pos    int  // Position in original input string
}

// Lexer tokenizes template content
struct Lexer {
mut:
	input  string
	pos    int     // Current position in input
	line   int     // Current line number
	column int     // Current column number
	tokens []Token // Generated tokens
}

// Create a new lexer for the given input
pub fn new_lexer(input string) Lexer {
	return Lexer{
		input:  input
		pos:    0
		line:   1
		column: 1
		tokens: []Token{}
	}
}

// Tokenize the entire input
pub fn (mut l Lexer) tokenize() ![]Token {
	for l.pos < l.input.len {
		l.next_token()!
	}

	// Add EOF token
	l.tokens << Token{
		type:   .eof
		value:  ''
		line:   l.line
		column: l.column
	}

	return l.tokens
}

// Get the next token
fn (mut l Lexer) next_token() ! {
	// Check for FreeMarker syntax markers
	if l.pos < l.input.len - 1 {
		two_char := l.input[l.pos..l.pos + 2]

		// Check for interpolation: ${
		if two_char == r'${' {
			l.add_token(.interpolation_start, r'${')
			l.advance_n(2)
			l.tokenize_interpolation_expression()!
			return
		}

		// Check for closing directive first: </#
		if l.pos < l.input.len - 2 {
			three_char := l.input[l.pos..l.pos + 3]
			if three_char == '</#' {
				l.add_token(.directive_close, '</#')
				l.advance_n(3)
				l.tokenize_directive_content()!
				return
			}
		}

		// Check for macro call start: <@
		if two_char == '<@' {
			l.add_token(.macro_call_start, '<@')
			l.advance_n(2)
			l.tokenize_macro_call()!
			return
		}

		// Check for directive or comment start: <#
		if two_char == '<#' {
			// Look ahead for comment: <#--
			if l.pos < l.input.len - 3 && l.input[l.pos..l.pos + 4] == '<#--' {
				l.tokenize_comment()!
			} else if l.pos + 9 < l.input.len && l.input[l.pos..l.pos + 10] == '<#noparse>' {
				// Special handling for noparse directive
				l.tokenize_noparse()!
			} else {
				l.add_token(.directive_start, '<#')
				l.advance_n(2)
				l.tokenize_directive_content()!
			}
			return
		}
	}

	// Otherwise, collect plain text
	l.tokenize_text()
}

// Tokenize plain text until we hit a FreeMarker marker
fn (mut l Lexer) tokenize_text() {
	start_pos := l.pos
	start_line := l.line
	start_column := l.column

	for l.pos < l.input.len {
		// Check for FreeMarker markers
		if l.pos < l.input.len - 1 {
			two_char := l.input[l.pos..l.pos + 2]
			if two_char == r'${' || two_char == '<#' || two_char == '<@' {
				break
			}
			// Also check for closing directives </#
			if l.pos < l.input.len - 2 {
				three_char := l.input[l.pos..l.pos + 3]
				if three_char == '</#' {
					break
				}
			}
		}

		// Advance character
		if l.input[l.pos] == `\n` {
			l.line++
			l.column = 1
		} else {
			l.column++
		}
		l.pos++
	}

	// Add text token if we collected any text
	if l.pos > start_pos {
		text_value := l.input[start_pos..l.pos]
		l.tokens << Token{
			type:   .text
			value:  text_value
			line:   start_line
			column: start_column
		}
	}
}

// Tokenize interpolation expression content (inside ${})
fn (mut l Lexer) tokenize_interpolation_expression() ! {
	for l.pos < l.input.len {
		l.skip_whitespace()

		if l.pos >= l.input.len {
			break
		}

		ch := l.input[l.pos]

		// Check for end of interpolation
		if ch == `}` {
			l.add_token(.interpolation_end, '}')
			l.advance()
			return
		}

		// In interpolation, > is a comparison operator, not directive end

		// Single character tokens
		match ch {
			`.` {
				l.add_single_char_token(.dot)
			}
			`[` {
				l.add_single_char_token(.lbracket)
			}
			`]` {
				l.add_single_char_token(.rbracket)
			}
			`(` {
				l.add_single_char_token(.lparen)
			}
			`)` {
				l.add_single_char_token(.rparen)
			}
			`,` {
				l.add_single_char_token(.comma)
			}
			`?` {
				l.add_single_char_token(.question)
			}
			`:` {
				l.add_single_char_token(.colon)
			}
			`+` {
				l.add_single_char_token(.plus)
			}
			`-` {
				l.add_single_char_token(.minus)
			}
			`*` {
				l.add_single_char_token(.multiply)
			}
			`/` {
				l.add_single_char_token(.divide)
			}
			`%` {
				l.add_single_char_token(.modulo)
			}
			else {
				// Multi-character tokens
				if ch == `=` {
					if l.peek() == `=` {
						l.add_token(.equals, '==')
						l.advance_n(2)
					} else {
						l.add_single_char_token(.equals)
					}
				} else if ch == `!` {
					if l.peek() == `=` {
						l.add_token(.not_equals, '!=')
						l.advance_n(2)
					} else {
						l.add_single_char_token(.not_op)
					}
				} else if ch == `<` {
					if l.peek() == `=` {
						l.add_token(.less_equal, '<=')
						l.advance_n(2)
					} else {
						l.add_single_char_token(.less_than)
					}
				} else if ch == `>` {
					if l.peek() == `=` {
						l.add_token(.greater_equal, '>=')
						l.advance_n(2)
					} else {
						l.add_single_char_token(.greater_than)
					}
				} else if ch == `&` {
					if l.peek() == `&` {
						l.add_token(.and_op, '&&')
						l.advance_n(2)
					} else {
						return error('Unexpected character: ${ch.ascii_str()}')
					}
				} else if ch == `|` {
					if l.peek() == `|` {
						l.add_token(.or_op, '||')
						l.advance_n(2)
					} else {
						return error('Unexpected character: ${ch.ascii_str()}')
					}
				} else if ch == `"` || ch == `'` {
					l.tokenize_string(ch)!
				} else if ch.is_digit() {
					l.tokenize_number()
				} else if ch.is_letter() || ch == `_` {
					l.tokenize_identifier()
				} else {
					return error('Unexpected character: ${ch.ascii_str()} at line ${l.line}, column ${l.column}')
				}
			}
		}
	}
}

// Tokenize directive content (between <# and >)
fn (mut l Lexer) tokenize_directive_content() ! {
	l.skip_whitespace()

	// Read the directive keyword
	if l.pos < l.input.len && (l.input[l.pos].is_letter() || l.input[l.pos] == `/`) {
		start := l.pos

		// Handle closing directive
		if l.input[l.pos] == `/` {
			l.advance()
		}

		// Read identifier
		for l.pos < l.input.len && (l.input[l.pos].is_letter() || l.input[l.pos].is_digit()
			|| l.input[l.pos] == `_`) {
			l.advance()
		}

		keyword := l.input[start..l.pos]

		// Check for keywords
		token_type := match keyword {
			'if' { TokenType.keyword_if }
			'elseif' { TokenType.keyword_elseif }
			'else' { TokenType.keyword_else }
			'list' { TokenType.keyword_list }
			'as' { TokenType.keyword_as }
			'assign' { TokenType.keyword_assign }
			'include' { TokenType.keyword_include }
			'noparse' { TokenType.keyword_noparse }
			'attempt' { TokenType.keyword_attempt }
			'recover' { TokenType.keyword_recover }
			'macro' { TokenType.keyword_macro }
			'stop' { TokenType.keyword_stop }
			'return' { TokenType.keyword_return }
			'sep' { TokenType.keyword_sep }
			'switch' { TokenType.keyword_switch }
			'case' { TokenType.keyword_case }
			'default' { TokenType.keyword_default }
			else { TokenType.identifier }
		}

		l.tokens << Token{
			type:   token_type
			value:  keyword
			line:   l.line
			column: l.column - keyword.len
			pos:    start  // Store the position for noparse
		}

		// Special handling for noparse directive
		if token_type == .keyword_noparse {
			// Skip whitespace and expect >
			l.skip_whitespace()
			if l.pos < l.input.len && l.input[l.pos] == `>` {
				l.add_token(.directive_end, '>')
				l.advance()
			} else {
				return error('Expected > after noparse')
			}
			return
		}
	}

	// Continue tokenizing directive expression content
	l.tokenize_directive_expression()!
}

// Tokenize a comment
fn (mut l Lexer) tokenize_comment() ! {
	l.add_token(.comment_start, '<#--')
	l.advance_n(4)

	start := l.pos

	// Find end of comment
	for l.pos < l.input.len - 2 {
		if l.input[l.pos..l.pos + 3] == '-->' {
			comment_text := l.input[start..l.pos]
			l.tokens << Token{
				type:   .text
				value:  comment_text
				line:   l.line
				column: l.column
			}
			l.add_token(.comment_end, '-->')
			l.advance_n(3)
			return
		}

		if l.input[l.pos] == `\n` {
			l.line++
			l.column = 1
		} else {
			l.column++
		}
		l.pos++
	}

	return error('Unclosed comment at line ${l.line}')
}

// Tokenize a string literal
fn (mut l Lexer) tokenize_string(quote u8) ! {
	start_line := l.line
	start_column := l.column
	l.advance() // Skip opening quote

	mut value := ''

	for l.pos < l.input.len {
		ch := l.input[l.pos]

		if ch == quote {
			l.advance() // Skip closing quote
			l.tokens << Token{
				type:   .string_literal
				value:  value
				line:   start_line
				column: start_column
			}
			return
		}

		if ch == `\\` && l.pos + 1 < l.input.len {
			// Handle escape sequences
			l.advance()
			next_ch := l.input[l.pos]
			value += match next_ch {
				`n` { '\n' }
				`t` { '\t' }
				`r` { '\r' }
				`\\` { '\\' }
				quote { quote.ascii_str() }
				else { next_ch.ascii_str() }
			}
		} else {
			value += ch.ascii_str()
		}

		l.advance()
	}

	return error('Unclosed string at line ${start_line}, column ${start_column}')
}

// Tokenize a number literal
fn (mut l Lexer) tokenize_number() {
	start_line := l.line
	start_column := l.column
	start := l.pos

	// Read integer part
	for l.pos < l.input.len && l.input[l.pos].is_digit() {
		l.advance()
	}

	// Check for decimal part
	if l.pos < l.input.len && l.input[l.pos] == `.` && l.pos + 1 < l.input.len
		&& l.input[l.pos + 1].is_digit() {
		l.advance() // Skip '.'
		for l.pos < l.input.len && l.input[l.pos].is_digit() {
			l.advance()
		}
	}

	value := l.input[start..l.pos]
	l.tokens << Token{
		type:   .number_literal
		value:  value
		line:   start_line
		column: start_column
	}
}

// Tokenize an identifier
fn (mut l Lexer) tokenize_identifier() {
	start_line := l.line
	start_column := l.column
	start := l.pos

	for l.pos < l.input.len && (l.input[l.pos].is_letter() || l.input[l.pos].is_digit()
		|| l.input[l.pos] == `_`) {
		l.advance()
	}

	value := l.input[start..l.pos]

	// Check for boolean literals and keywords
	token_type := match value {
		'true', 'false' { TokenType.boolean_literal }
		'if' { TokenType.keyword_if }
		'elseif' { TokenType.keyword_elseif }
		'else' { TokenType.keyword_else }
		'list' { TokenType.keyword_list }
		'as' { TokenType.keyword_as }
		'assign' { TokenType.keyword_assign }
		'include' { TokenType.keyword_include }
		'sep' { TokenType.keyword_sep }
		'switch' { TokenType.keyword_switch }
		'case' { TokenType.keyword_case }
		'default' { TokenType.keyword_default }
		else { TokenType.identifier }
	}

	l.tokens << Token{
		type:   token_type
		value:  value
		line:   start_line
		column: start_column
	}
}

// Helper functions

fn (mut l Lexer) skip_whitespace() {
	for l.pos < l.input.len && l.input[l.pos].is_space() {
		if l.input[l.pos] == `\n` {
			l.line++
			l.column = 1
		} else {
			l.column++
		}
		l.pos++
	}
}

fn (mut l Lexer) advance() {
	if l.pos < l.input.len {
		if l.input[l.pos] == `\n` {
			l.line++
			l.column = 1
		} else {
			l.column++
		}
		l.pos++
	}
}

fn (mut l Lexer) advance_n(n int) {
	for i := 0; i < n; i++ {
		l.advance()
	}
}

fn (l Lexer) peek() u8 {
	if l.pos + 1 < l.input.len {
		return l.input[l.pos + 1]
	}
	return 0
}

fn (mut l Lexer) add_token(token_type TokenType, value string) {
	l.tokens << Token{
		type:   token_type
		value:  value
		line:   l.line
		column: l.column - value.len
		pos:    l.pos - value.len  // Track position in original input
	}
}

fn (mut l Lexer) add_single_char_token(token_type TokenType) {
	ch := l.input[l.pos]
	l.add_token(token_type, ch.ascii_str())
	l.advance()
}

// Tokenize directive expression content (inside <# >)
fn (mut l Lexer) tokenize_directive_expression() ! {
	for l.pos < l.input.len {
		l.skip_whitespace()

		if l.pos >= l.input.len {
			break
		}

		ch := l.input[l.pos]

		// Check for greater than or directive end
		if ch == `>` {
			// Check if it's >= operator
			if l.peek() == `=` {
				l.add_token(.greater_equal, '>=')
				l.advance_n(2)
				continue
			}

			// Determine if this is a comparison operator or directive end
			// Strategy: > is a comparison operator only if we're EXPECTING an operator
			// (i.e., after a complete left operand that hasn't been used yet)
			// > is directive_end if we just completed a comparison (last token was an operand after an operator)
			mut is_comparison := false
			if l.tokens.len >= 2 {
				last_token := l.tokens[l.tokens.len - 1]
				second_last_token := l.tokens[l.tokens.len - 2]

				// > is a comparison operator if:
				// - Last token is a potential left operand (identifier, number, string, rparen, rbracket)
				// - AND second-to-last is NOT a binary/comparison operator
				// This prevents treating the second > in "a > b >" as a comparison
				is_operand := last_token.type in [
					.identifier,
					.number_literal,
					.string_literal,
					.rparen,
					.rbracket,
				]

				second_last_is_operator := second_last_token.type in [
					.equals,
					.not_equals,
					.less_than,
					.less_equal,
					.greater_than,
					.greater_equal,
					.plus,
					.minus,
					.multiply,
					.divide,
					.modulo,
				]

				is_comparison = is_operand && !second_last_is_operator
			} else if l.tokens.len == 1 {
				// Only one token so far - treat > as directive end
				is_comparison = false
			}

			if is_comparison {
				// This is a greater-than comparison operator
				l.add_single_char_token(.greater_than)
			} else {
				// This is the end of directive
				l.add_token(.directive_end, '>')
				l.advance()
				return
			}
			continue
		}

		// Single character tokens
		match ch {
			`.` {
				l.add_single_char_token(.dot)
			}
			`[` {
				l.add_single_char_token(.lbracket)
			}
			`]` {
				l.add_single_char_token(.rbracket)
			}
			`(` {
				l.add_single_char_token(.lparen)
			}
			`)` {
				l.add_single_char_token(.rparen)
			}
			`,` {
				l.add_single_char_token(.comma)
			}
			`?` {
				l.add_single_char_token(.question)
			}
			`:` {
				l.add_single_char_token(.colon)
			}
			`+` {
				l.add_single_char_token(.plus)
			}
			`-` {
				l.add_single_char_token(.minus)
			}
			`*` {
				l.add_single_char_token(.multiply)
			}
			`/` {
				l.add_single_char_token(.divide)
			}
			`%` {
				l.add_single_char_token(.modulo)
			}
			else {
				// Multi-character tokens
				if ch == `=` {
					if l.peek() == `=` {
						l.add_token(.equals, '==')
						l.advance_n(2)
					} else {
						l.add_single_char_token(.equals)
					}
				} else if ch == `!` {
					if l.peek() == `=` {
						l.add_token(.not_equals, '!=')
						l.advance_n(2)
					} else {
						l.add_single_char_token(.not_op)
					}
				} else if ch == `<` {
					if l.peek() == `=` {
						l.add_token(.less_equal, '<=')
						l.advance_n(2)
					} else {
						l.add_single_char_token(.less_than)
					}
				} else if ch == `&` {
					if l.peek() == `&` {
						l.add_token(.and_op, '&&')
						l.advance_n(2)
					} else {
						return error('Unexpected character: ${ch.ascii_str()}')
					}
				} else if ch == `|` {
					if l.peek() == `|` {
						l.add_token(.or_op, '||')
						l.advance_n(2)
					} else {
						return error('Unexpected character: ${ch.ascii_str()}')
					}
				} else if ch == `"` || ch == `'` {
					l.tokenize_string(ch)!
				} else if ch.is_digit() {
					l.tokenize_number()
				} else if ch.is_letter() || ch == `_` {
					l.tokenize_identifier()
				} else {
					return error('Unexpected character: ${ch.ascii_str()} at line ${l.line}, column ${l.column}')
				}
			}
		}
	}
}

// Tokenize noparse directive - everything between <#noparse> and </#noparse> is literal text
fn (mut l Lexer) tokenize_noparse() ! {
	// Add opening tokens
	l.add_token(.directive_start, '<#')
	l.advance_n(2)
	l.add_token(.keyword_noparse, 'noparse')
	l.advance_n(7)
	l.add_token(.directive_end, '>')
	l.advance()

	// Find the end marker
	start := l.pos
	end_marker := '</#noparse>'
	end_pos := l.input.index_after(end_marker, start) or {
		return error('Unclosed noparse directive at line ${l.line}')
	}

	// Add the content as a single text token
	content := l.input[start..end_pos]
	l.tokens << Token{
		type:   .text
		value:  content
		line:   l.line
		column: l.column
		pos:    start
	}

	// Update position and line/column tracking
	for i := start; i < end_pos; i++ {
		if l.input[i] == `\n` {
			l.line++
			l.column = 1
		} else {
			l.column++
		}
	}
	l.pos = end_pos

	// Add closing tokens
	l.add_token(.directive_close, '</#')
	l.advance_n(3)
	l.add_token(.keyword_noparse, 'noparse')
	l.advance_n(7)
	l.add_token(.directive_end, '>')
	l.advance()
}

// Tokenize macro call content: <@macroName param="value" ... />
fn (mut l Lexer) tokenize_macro_call() ! {
	for l.pos < l.input.len {
		ch := l.input[l.pos]

		// Check for macro call end: />
		if l.pos < l.input.len - 1 && l.input[l.pos..l.pos + 2] == '/>' {
			l.add_token(.macro_call_end, '/>')
			l.advance_n(2)
			return
		}

		// Skip whitespace
		if ch.is_space() {
			l.advance()
			continue
		}

		// Tokenize identifier (macro name or parameter names)
		if ch.is_letter() || ch == `_` {
			l.tokenize_identifier()
			continue
		}

		// Handle string literals for parameter values
		if ch == `"` || ch == `'` {
			l.tokenize_string(ch)!
			continue
		}

		// Handle numeric literals
		if ch.is_digit() {
			l.tokenize_number()
			continue
		}

		// Handle operators and special characters
		match ch {
			`=` {
				l.add_token(.equals, '=')
				l.advance()
			}
			`,` {
				l.add_token(.comma, ',')
				l.advance()
			}
			else {
				return error('Unexpected character in macro call: ${ch.ascii_str()} at line ${l.line}, column ${l.column}')
			}
		}
	}

	return error('Unclosed macro call at line ${l.line}')
}
