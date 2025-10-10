/******************************************************************************
                __               ____                __
               / /   ___  ____ _/ __/_____________ _/ /__
              / /   / _ \/ __ `/ /_/ ___/ ___/ __ `/ / _ \
             / /___/  __/ /_/ / __(__  ) /__/ /_/ / /  __/
            /_____/\___/\__,_/_/ /____/\___/\__,_/_/\___/

    (C)opyright 2025, Leafscale, LLC -  https://www.leafscale.com

    Project: VeeMarker
   Filename: parser.v
    Authors: Chris Tusa <chris.tusa@leafscale.com>
    License: <see LICENSE file included with this source code>
Description: Parser that converts tokens into Abstract Syntax Tree

******************************************************************************/
module veemarker

// Parser converts tokens into an AST
struct Parser {
mut:
	tokens []Token
	pos    int
	input  string  // Original input for extracting raw content
}

// Create a new parser with tokens
pub fn new_parser(tokens []Token) Parser {
	return Parser{
		tokens: tokens
		pos:    0
		input:  ''  // Will be set separately
	}
}

// Parse tokens into AST nodes
pub fn (mut p Parser) parse() ![]Node {
	mut nodes := []Node{}

	for p.pos < p.tokens.len && p.current().type != .eof {
		// Skip directive close tokens at the top level - they're handled by directive parsing
		if p.current().type == .directive_close {
			// This shouldn't happen at the top level, but skip it if it does
			p.advance()
			// Skip the tag name
			if p.current().type == .identifier || p.current().type == .keyword_if
				|| p.current().type == .keyword_list {
				p.advance()
			}
			// Skip the directive end
			if p.current().type == .directive_end {
				p.advance()
			}
			continue
		}

		node := p.parse_node()!
		nodes << node
	}

	return nodes
}

// Parse a single node
fn (mut p Parser) parse_node() !Node {
	token := p.current()

	match token.type {
		.text {
			p.advance()
			return TextNode{
				content: token.value
			}
		}
		.interpolation_start {
			return p.parse_interpolation()!
		}
		.directive_start {
			return p.parse_directive()!
		}
		.comment_start {
			return p.parse_comment()!
		}
		.macro_call_start {
			return p.parse_macro_call()!
		}
		else {
			return error('Unexpected token: ${token.type} at line ${token.line}')
		}
	}
}

// Parse ${expression} interpolation with optional default value ${expr!"default"}
fn (mut p Parser) parse_interpolation() !InterpolationNode {
	p.expect(.interpolation_start)!
	expr := p.parse_expression()!

	// Check for default value operator !
	mut default_value := ?Expression(none)
	if p.current().type == .not_op {
		p.advance() // consume !
		default_value = p.parse_expression()!
	}

	p.expect(.interpolation_end)!

	return InterpolationNode{
		expression: expr
		default_value: default_value
	}
}

// Parse an expression (including ternary)
fn (mut p Parser) parse_expression() !Expression {
	return p.parse_ternary_expression()!
}

// Parse ternary expression (condition ? true_expr : false_expr)
fn (mut p Parser) parse_ternary_expression() !Expression {
	mut condition := p.parse_or_expression()!

	// Check for ternary operator
	if p.current().type == .question {
		p.advance() // consume ?
		true_expr := p.parse_or_expression()!
		p.expect(.colon)! // expect :
		false_expr := p.parse_or_expression()!

		return TernaryExpr{
			condition: condition
			true_expr: true_expr
			false_expr: false_expr
		}
	}

	return condition
}

// Parse OR expression (||)
fn (mut p Parser) parse_or_expression() !Expression {
	mut left := p.parse_and_expression()!

	for p.current().type == .or_op {
		op := p.current().value
		p.advance()
		right := p.parse_and_expression()!
		left = BinaryOpExpr{
			left:     left
			operator: op
			right:    right
		}
	}

	return left
}

// Parse AND expression (&&)
fn (mut p Parser) parse_and_expression() !Expression {
	mut left := p.parse_equality_expression()!

	for p.current().type == .and_op {
		op := p.current().value
		p.advance()
		right := p.parse_equality_expression()!
		left = BinaryOpExpr{
			left:     left
			operator: op
			right:    right
		}
	}

	return left
}

// Parse equality expression (==, !=)
fn (mut p Parser) parse_equality_expression() !Expression {
	mut left := p.parse_relational_expression()!

	for p.current().type in [.equals, .not_equals] {
		op := p.current().value
		p.advance()
		right := p.parse_relational_expression()!
		left = BinaryOpExpr{
			left:     left
			operator: op
			right:    right
		}
	}

	return left
}

// Parse relational expression (<, <=, >, >=)
fn (mut p Parser) parse_relational_expression() !Expression {
	mut left := p.parse_additive_expression()!

	for p.current().type in [.less_than, .less_equal, .greater_than, .greater_equal] {
		op := p.current().value
		p.advance()
		right := p.parse_additive_expression()!
		left = BinaryOpExpr{
			left:     left
			operator: op
			right:    right
		}
	}

	return left
}

// Parse additive expression (+, -)
fn (mut p Parser) parse_additive_expression() !Expression {
	mut left := p.parse_multiplicative_expression()!

	for p.current().type in [.plus, .minus] {
		op := p.current().value
		p.advance()
		right := p.parse_multiplicative_expression()!
		left = BinaryOpExpr{
			left:     left
			operator: op
			right:    right
		}
	}

	return left
}

// Parse multiplicative expression (*, /, %)
fn (mut p Parser) parse_multiplicative_expression() !Expression {
	mut left := p.parse_unary_expression()!

	for p.current().type in [.multiply, .divide, .modulo] {
		op := p.current().value
		p.advance()
		right := p.parse_unary_expression()!
		left = BinaryOpExpr{
			left:     left
			operator: op
			right:    right
		}
	}

	return left
}

// Parse unary expression (!, -)
fn (mut p Parser) parse_unary_expression() !Expression {
	if p.current().type in [.not_op, .minus] {
		op := p.current().value
		p.advance()
		operand := p.parse_unary_expression()!
		return UnaryOpExpr{
			operator: op
			operand:  operand
		}
	}

	return p.parse_postfix_expression()!
}

// Parse postfix expression (property access, method calls, array access)
fn (mut p Parser) parse_postfix_expression() !Expression {
	mut expr := p.parse_primary_expression()!

	for {
		match p.current().type {
			.dot {
				p.advance()
				if p.current().type != .identifier {
					return error('Expected property name after .')
				}
				property := p.current().value
				p.advance()

				// Check for method call
				if p.current().type == .lparen {
					args := p.parse_arguments()!
					expr = MethodCallExpr{
						object: expr
						method: property
						args:   args
					}
				} else {
					expr = PropertyExpr{
						object:   expr
						property: property
					}
				}
			}
			.lbracket {
				p.advance()
				index := p.parse_expression()!
				p.expect(.rbracket)!
				expr = ArrayAccessExpr{
					object: expr
					index:  index
				}
			}
			.question {
				// Check for ?? (null-check operator)
				if p.peek().type == .question {
					p.advance() // consume first ?
					p.advance() // consume second ?
					expr = MethodCallExpr{
						object: expr
						method: 'has_content'
						args:   []
					}
				} else {
					// FreeMarker built-in function syntax: ?function_name or ?function_name(args)
					p.advance()
					if p.current().type != .identifier {
						return error('Expected built-in function name after ?')
					}
					method := p.current().value
					p.advance()

					// Check if there are arguments
					mut args := []Expression{}
					if p.current().type == .lparen {
						args = p.parse_arguments()!
					}

					expr = MethodCallExpr{
						object: expr
						method: method
						args:   args
					}
				}
			}
			else {
				break
			}
		}
	}

	return expr
}

// Parse primary expression
fn (mut p Parser) parse_primary_expression() !Expression {
	token := p.current()

	match token.type {
		.identifier {
			name := token.value
			p.advance()
			return VariableExpr{
				name: name
			}
		}
		.string_literal {
			value := token.value
			p.advance()
			return LiteralExpr{
				value: value
			}
		}
		.number_literal {
			// Try to parse as int first, then float
			value := token.value
			p.advance()
			if value.contains('.') {
				return LiteralExpr{
					value: value.f64()
				}
			} else {
				return LiteralExpr{
					value: value.int()
				}
			}
		}
		.boolean_literal {
			value := token.value == 'true'
			p.advance()
			return LiteralExpr{
				value: value
			}
		}
		.lparen {
			p.advance()
			expr := p.parse_expression()!
			p.expect(.rparen)!
			return expr
		}
		else {
			return error('Unexpected token in expression: ${token.type} at line ${token.line}')
		}
	}
}

// Parse function arguments
fn (mut p Parser) parse_arguments() ![]Expression {
	mut args := []Expression{}

	p.expect(.lparen)!

	// Empty arguments
	if p.current().type == .rparen {
		p.advance()
		return args
	}

	// Parse arguments
	for {
		arg := p.parse_expression()!
		args << arg

		if p.current().type == .comma {
			p.advance()
		} else {
			break
		}
	}

	p.expect(.rparen)!
	return args
}

// Parse directives (simplified for now)
fn (mut p Parser) parse_directive() !Node {
	p.expect(.directive_start)!

	// Check directive type
	if p.current().type == .keyword_if {
		return p.parse_if_directive()!
	} else if p.current().type == .keyword_list {
		return p.parse_list_directive()!
	} else if p.current().type == .keyword_assign {
		return p.parse_assign_directive()!
	} else if p.current().type == .keyword_include {
		return p.parse_include_directive()!
	} else if p.current().type == .keyword_attempt {
		return p.parse_attempt_directive()!
	} else if p.current().type == .keyword_noparse {
		return p.parse_noparse_directive()!
	} else if p.current().type == .keyword_macro {
		return p.parse_macro_directive()!
	} else if p.current().type == .keyword_stop {
		return p.parse_stop_directive()!
	} else if p.current().type == .keyword_return {
		return p.parse_return_directive()!
	} else if p.current().type == .keyword_switch {
		return p.parse_switch_directive()!
	}

	// For now, skip unknown directives
	for p.current().type != .directive_end && p.current().type != .eof {
		p.advance()
	}
	p.expect(.directive_end)!

	return TextNode{
		content: ''
	}
}

// Parse <#if> directive (simplified)
fn (mut p Parser) parse_if_directive() !IfNode {
	p.expect(.keyword_if)!

	condition := p.parse_expression()!
	p.expect(.directive_end)!

	// Parse then block
	mut then_block := []Node{}
	for p.pos < p.tokens.len {
		// Check for else/elseif/endif
		if p.current().type == .directive_start {
			if p.peek().type in [.keyword_else, .keyword_elseif] {
				break
			}
		}
		if p.current().type == .directive_close {
			// This is </#if>
			break
		}

		node := p.parse_node()!
		then_block << node
	}

	// Parse elseif and else blocks if present
	mut elseif_blocks := []ElseIfBlock{}
	mut else_block := []Node{}

	for p.current().type == .directive_start {
		p.advance()

		if p.current().type == .keyword_elseif {
			// Parse elseif condition
			p.advance()
			elseif_condition := p.parse_expression()!
			p.expect(.directive_end)!

			// Parse elseif block
			mut elseif_block := []Node{}
			for p.pos < p.tokens.len {
				// Check for else/elseif/endif
				if p.current().type == .directive_start {
					if p.peek().type in [.keyword_else, .keyword_elseif] {
						break
					}
				}
				if p.current().type == .directive_close {
					// This is </#if>
					break
				}

				node := p.parse_node()!
				elseif_block << node
			}

			elseif_blocks << ElseIfBlock{
				condition: elseif_condition
				block: elseif_block
			}
		} else if p.current().type == .keyword_else {
			p.advance()
			p.expect(.directive_end)!

			// Parse else block
			for p.pos < p.tokens.len {
				// Check for </#if>
				if p.current().type == .directive_close {
					break
				}

				node := p.parse_node()!
				else_block << node
			}
			break // else is always last
		} else {
			// Not an else/elseif, back up
			p.pos--
			break
		}
	}

	// Skip the closing tag </#if>
	if p.current().type == .directive_close {
		p.advance()
		if p.current().type == .identifier || p.current().type == .keyword_if {
			p.advance()
		}
		if p.current().type == .directive_end {
			p.advance()
		}
	}

	return IfNode{
		condition:     condition
		then_block:    then_block
		elseif_blocks: elseif_blocks
		else_block:    else_block
	}
}

// Parse <#list> directive with optional else and sep blocks
fn (mut p Parser) parse_list_directive() !ListNode {
	p.expect(.keyword_list)!

	collection := p.parse_expression()!
	p.expect(.keyword_as)!

	if p.current().type != .identifier {
		return error('Expected variable name after "as"')
	}
	item_var := p.current().value
	p.advance()

	p.expect(.directive_end)!

	// Parse main list block
	mut block := []Node{}
	mut else_block := []Node{}
	mut sep_block := []Node{}

	for p.pos < p.tokens.len {
		// Check for </#list>
		if p.current().type == .directive_close {
			break
		}

		// Check for <#else> directive within list
		if p.current().type == .directive_start && p.peek().type == .keyword_else {
			p.advance() // consume <#
			p.advance() // consume else
			p.expect(.directive_end)! // consume >

			// Parse else block content
			for p.pos < p.tokens.len {
				if p.current().type == .directive_close {
					break
				}
				if p.current().type == .directive_start &&
				   p.peek().type in [.keyword_sep] {
					break
				}

				node := p.parse_node()!
				else_block << node
			}
			continue
		}

		// Check for <#sep> directive within list
		if p.current().type == .directive_start && p.peek().type == .keyword_sep {
			p.advance() // consume <#
			p.advance() // consume sep
			p.expect(.directive_end)! // consume >

			// Parse sep block content
			for p.pos < p.tokens.len {
				if p.current().type == .directive_close {
					break
				}
				if p.current().type == .directive_start &&
				   p.peek().type in [.keyword_else] {
					break
				}

				node := p.parse_node()!
				sep_block << node
			}
			continue
		}

		node := p.parse_node()!
		block << node
	}

	// Skip the closing tag </#list>
	if p.current().type == .directive_close {
		p.advance()
		if p.current().type == .identifier || p.current().type == .keyword_list {
			p.advance()
		}
		if p.current().type == .directive_end {
			p.advance()
		}
	}

	return ListNode{
		collection: collection
		item_var:   item_var
		index_var:  ''
		block:      block
		else_block: else_block
		sep_block:  sep_block
	}
}

// Parse <#assign> directive
fn (mut p Parser) parse_assign_directive() !AssignNode {
	p.expect(.keyword_assign)!

	if p.current().type != .identifier {
		return error('Expected variable name in assign directive')
	}
	variable := p.current().value
	p.advance()

	// Check if it's a multi-line capture (no equals sign, just >)
	if p.current().type == .directive_end {
		// For multi-line assign, we need to find the raw content in the input string
		// We can't rely on tokens because the content might contain directives
		// that should be treated as plain text

		// Get the current position in the original input
		current_token := p.current()
		start_pos_in_input := current_token.pos + 1  // Position after the closing >

		p.advance() // Skip the directive_end token

		// Find </#assign> in the original input string
		end_marker := '</#assign>'
		end_pos := p.input.index_after(end_marker, start_pos_in_input) or { -1 }

		if end_pos < 0 {
			return error('Unclosed multi-line assign for variable "${variable}"')
		}

		// Extract the content between <#assign var> and </#assign>
		content := p.input[start_pos_in_input..end_pos].trim_space()

		// Now we need to skip tokens until we find the closing </#assign> tokens
		// This is needed to keep the parser position in sync
		for p.pos < p.tokens.len {
			if p.current().type == .directive_close {
				next_pos := p.pos + 1
				if next_pos < p.tokens.len {
					next_token := p.tokens[next_pos]
					if next_token.type == .keyword_assign || (next_token.type == .identifier && next_token.value == 'assign') {
						// Found the closing </#assign>
						p.advance() // Skip </#
						p.advance() // Skip assign
						if p.current().type == .directive_end {
							p.advance()
						}
						break
					}
				}
			}
			p.advance()
		}

		// Create a TemplateStringExpr to indicate this needs template processing
		// We'll handle this specially in the engine
		return AssignNode{
			variable: variable
			value: TemplateStringExpr{
				content: content
			}
		}
	}

	// Regular single-line assign with equals
	p.expect(.equals)!
	value := p.parse_expression()!
	p.expect(.directive_end)!

	return AssignNode{
		variable: variable
		value:    value
	}
}

// Parse comment
fn (mut p Parser) parse_comment() !CommentNode {
	p.expect(.comment_start)!

	mut content := ''
	if p.current().type == .text {
		content = p.current().value
		p.advance()
	}

	p.expect(.comment_end)!

	return CommentNode{
		content: content
	}
}

// Helper functions

fn (p Parser) current() Token {
	if p.pos >= p.tokens.len {
		return Token{
			type:   .eof
			value:  ''
			line:   0
			column: 0
		}
	}
	return p.tokens[p.pos]
}

fn (p Parser) peek() Token {
	if p.pos + 1 >= p.tokens.len {
		return Token{
			type:   .eof
			value:  ''
			line:   0
			column: 0
		}
	}
	return p.tokens[p.pos + 1]
}

fn (mut p Parser) advance() {
	if p.pos < p.tokens.len {
		p.pos++
	}
}

fn (mut p Parser) expect(expected TokenType) ! {
	if p.current().type != expected {
		return error('Expected ${expected}, got ${p.current().type} at line ${p.current().line}')
	}
	p.advance()
}

// Parse <#include "template.vtpl"> directive
fn (mut p Parser) parse_include_directive() !IncludeNode {
	p.expect(.keyword_include)!

	// Expect a string literal for the template path
	if p.current().type != .string_literal {
		return error('Include directive requires a string literal template path')
	}

	mut template_path := p.current().value
	// Remove quotes from the string literal
	if template_path.len >= 2 && (template_path[0] == `"` || template_path[0] == `'`) {
		template_path = template_path[1..template_path.len - 1]
	}

	p.advance()
	p.expect(.directive_end)!

	return IncludeNode{
		template_path: template_path
	}
}

// Parse <#noparse>...</#noparse> directive
fn (mut p Parser) parse_noparse_directive() !NoParseNode {
	p.expect(.keyword_noparse)!
	p.expect(.directive_end)!

	// Find the closing </#noparse> in the input string
	// We need to use raw input to avoid parsing the content
	current_token := p.current()
	start_pos := current_token.pos

	// Find </#noparse> in the original input string
	end_marker := '</#noparse>'
	end_pos := p.input.index_after(end_marker, start_pos) or {
		return error('Unclosed noparse directive at line ${current_token.line}')
	}

	// Extract the content between <#noparse> and </#noparse>
	content := p.input[start_pos..end_pos]

	// Skip tokens until we find the closing </#noparse> tokens
	// This keeps the parser position in sync
	for p.pos < p.tokens.len {
		if p.current().type == .directive_close {
			next_pos := p.pos + 1
			if next_pos < p.tokens.len {
				next_token := p.tokens[next_pos]
				if next_token.type == .keyword_noparse || (next_token.type == .identifier && next_token.value == 'noparse') {
					// Found the closing </#noparse>
					p.advance() // Skip </#
					p.advance() // Skip noparse
					if p.current().type == .directive_end {
						p.advance()
					}
					break
				}
			}
		}
		p.advance()
	}

	return NoParseNode{
		content: content
	}
}

// Parse <#attempt> directive
fn (mut p Parser) parse_attempt_directive() !AttemptNode {
	p.expect(.keyword_attempt)!
	p.expect(.directive_end)!

	// Parse attempt block
	mut attempt_block := []Node{}
	for p.pos < p.tokens.len {
		// Check for recover or end attempt
		if p.current().type == .directive_start {
			if p.peek().type == .keyword_recover {
				break
			}
		}
		if p.current().type == .directive_close {
			break
		}

		node := p.parse_node()!
		attempt_block << node
	}

	// Parse recover block (optional)
	mut recover_block := []Node{}
	if p.current().type == .directive_start && p.peek().type == .keyword_recover {
		p.expect(.directive_start)!
		p.expect(.keyword_recover)!
		p.expect(.directive_end)!

		for p.pos < p.tokens.len {
			// Check for end attempt
			if p.current().type == .directive_close {
				break
			}

			node := p.parse_node()!
			recover_block << node
		}
	}

	// Skip the closing tag </#attempt>
	if p.current().type == .directive_close {
		p.advance()
		if p.current().type == .identifier || p.current().type == .keyword_attempt {
			p.advance()
		}
		if p.current().type == .directive_end {
			p.advance()
		}
	}

	return AttemptNode{
		attempt_block: attempt_block
		recover_block: recover_block
	}
}

// Parse <#macro> directive
fn (mut p Parser) parse_macro_directive() !MacroNode {
	p.expect(.keyword_macro)!

	// Get macro name
	if p.current().type != .identifier {
		return error('Expected macro name at line ${p.current().line}')
	}
	macro_name := p.current().value
	p.advance()

	// Parse parameters
	mut parameters := []string{}
	for p.current().type != .directive_end && p.current().type != .eof {
		if p.current().type == .identifier {
			parameters << p.current().value
			p.advance()
		} else {
			p.advance() // Skip other tokens like commas
		}
	}
	p.expect(.directive_end)!

	// Parse macro body
	mut body := []Node{}
	for p.pos < p.tokens.len {
		// Check for closing </#macro>
		if p.current().type == .directive_close {
			// Look ahead for 'macro'
			next_pos := p.pos + 1
			if next_pos < p.tokens.len {
				next_token := p.tokens[next_pos]
				if next_token.type == .keyword_macro || (next_token.type == .identifier && next_token.value == 'macro') {
					// Found closing tag
					p.advance() // Skip </#
					p.advance() // Skip macro
					if p.current().type == .directive_end {
						p.advance()
					}
					break
				}
			}
		}

		node := p.parse_node()!
		body << node
	}

	return MacroNode{
		name: macro_name
		parameters: parameters
		body: body
	}
}

// Parse <@macroName param="value"/> macro call
fn (mut p Parser) parse_macro_call() !MacroCallNode {
	p.expect(.macro_call_start)!

	// Get macro name
	if p.current().type != .identifier {
		return error('Expected macro name at line ${p.current().line}')
	}
	macro_name := p.current().value
	p.advance()

	// Parse arguments
	mut arguments := map[string]Expression{}
	for p.current().type != .macro_call_end && p.current().type != .eof {
		// Skip whitespace-like tokens by advancing to next meaningful token
		if p.current().type == .identifier {
			param_name := p.current().value
			p.advance()

			if p.current().type == .equals {
				p.advance()
				value := p.parse_expression()!
				arguments[param_name] = value
			}
		} else {
			p.advance() // Skip commas and other tokens
		}
	}

	p.expect(.macro_call_end)!

	return MacroCallNode{
		name: macro_name
		arguments: arguments
	}
}

// Parse <#stop> directive
fn (mut p Parser) parse_stop_directive() !StopNode {
	p.expect(.keyword_stop)!

	// Optional message parameter
	mut message := ''
	if p.current().type == .string_literal {
		message = p.current().value
		p.advance()
	}

	p.expect(.directive_end)!

	return StopNode{
		message: message
	}
}

// Parse <#return> directive
fn (mut p Parser) parse_return_directive() !ReturnNode {
	p.expect(.keyword_return)!

	// Optional return value expression
	mut value := ?Expression(none)
	mut message := ''

	// Check if there's an expression or string literal
	if p.current().type != .directive_end {
		if p.current().type == .string_literal {
			message = p.current().value
			p.advance()
		} else {
			// Parse expression as return value
			value = p.parse_expression()!
		}
	}

	p.expect(.directive_end)!

	return ReturnNode{
		value: value
		message: message
	}
}

// Parse <#switch> directive with case and default blocks
fn (mut p Parser) parse_switch_directive() !SwitchNode {
	p.expect(.keyword_switch)!

	expression := p.parse_expression()!
	p.expect(.directive_end)!

	mut case_blocks := []CaseBlock{}
	mut default_block := []Node{}

	for p.pos < p.tokens.len {
		// Check for </#switch>
		if p.current().type == .directive_close {
			break
		}

		// Check for <#case> directive
		if p.current().type == .directive_start && p.peek().type == .keyword_case {
			p.advance() // consume <#
			p.advance() // consume case

			case_value := p.parse_expression()!
			p.expect(.directive_end)! // consume >

			// Parse case block content
			mut case_content := []Node{}
			for p.pos < p.tokens.len {
				if p.current().type == .directive_close {
					break
				}
				if p.current().type == .directive_start &&
				   p.peek().type in [.keyword_case, .keyword_default] {
					break
				}

				node := p.parse_node()!
				case_content << node
			}

			case_blocks << CaseBlock{
				value: case_value
				block: case_content
			}
			continue
		}

		// Check for <#default> directive
		if p.current().type == .directive_start && p.peek().type == .keyword_default {
			p.advance() // consume <#
			p.advance() // consume default
			p.expect(.directive_end)! // consume >

			// Parse default block content
			for p.pos < p.tokens.len {
				if p.current().type == .directive_close {
					break
				}
				if p.current().type == .directive_start &&
				   p.peek().type in [.keyword_case] {
					break
				}

				node := p.parse_node()!
				default_block << node
			}
			continue
		}

		// Regular content outside case/default blocks is not allowed
		// Skip to next directive or handle as error
		node := p.parse_node()!
		// For now, ignore content outside of case/default blocks
		_ = node
	}

	// Skip the closing tag </#switch>
	if p.current().type == .directive_close {
		p.advance()
		if p.current().type == .identifier || p.current().type == .keyword_switch {
			p.advance()
		}
		if p.current().type == .directive_end {
			p.advance()
		}
	}

	return SwitchNode{
		expression: expression
		case_blocks: case_blocks
		default_block: default_block
	}
}
