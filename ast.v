/******************************************************************************
                __               ____                __
               / /   ___  ____ _/ __/_____________ _/ /__
              / /   / _ \/ __ `/ /_/ ___/ ___/ __ `/ / _ \
             / /___/  __/ /_/ / __(__  ) /__/ /_/ / /  __/
            /_____/\___/\__,_/_/ /____/\___/\__,_/_/\___/

    (C)opyright 2025, Leafscale, LLC -  https://www.leafscale.com

    Project: VeeMarker
   Filename: ast.v
    Authors: Chris Tusa <chris.tusa@leafscale.com>
    License: <see LICENSE file included with this source code>
Description: Abstract Syntax Tree node definitions for template structure

******************************************************************************/

module veemarker

// AST Node types for template structure
type Node = TextNode | InterpolationNode | IfNode | ListNode | AssignNode | CommentNode | IncludeNode | NoParseNode | MacroNode | MacroCallNode | AttemptNode | StopNode | ReturnNode | SwitchNode

// Plain text content
struct TextNode {
pub:
	content string
}

// ${expression} interpolation with optional default value ${expr!"default"}
struct InterpolationNode {
pub:
	expression     Expression
	default_value  ?Expression // Optional default value when expression is undefined or empty
}

// <#if condition>...</#if> directive
struct IfNode {
pub:
	condition     Expression
	then_block    []Node
	elseif_blocks []ElseIfBlock
	else_block    []Node
}

struct ElseIfBlock {
pub:
	condition Expression
	block     []Node
}

// <#list items as item>...</#list> directive
struct ListNode {
pub:
	collection Expression
	item_var   string
	index_var  string // Optional: for item_index
	block      []Node
	else_block []Node  // Optional: executed when collection is empty
	sep_block  []Node  // Optional: executed between items (separator)
}

// <#assign name = value> directive
struct AssignNode {
pub:
	variable string
	value    Expression
}

// <#-- comment --> directive
struct CommentNode {
pub:
	content string
}

// <#include "template.vtpl"> directive
struct IncludeNode {
pub:
	template_path string
}

// <#noparse>...</#noparse> directive
struct NoParseNode {
pub:
	content string
}

// Parameter for a macro definition
struct MacroParameter {
pub:
	name          string
	default_value ?Expression // Optional default value
}

// <#macro name params>...</#macro> directive
struct MacroNode {
pub:
	name       string
	parameters []MacroParameter
	body       []Node
}

// Macro call: <@macroName param1="value1" param2="value2"/>
struct MacroCallNode {
pub:
	name      string
	arguments map[string]Expression
}

// <#attempt>...<#recover>...</#attempt> directive for error handling
struct AttemptNode {
pub:
	attempt_block []Node
	recover_block []Node
}

// <#stop> directive to halt template processing
struct StopNode {
pub:
	message string // Optional message for debugging/logging
}

// <#return> directive to return from macro execution
struct ReturnNode {
pub:
	value   ?Expression // Optional return value
	message string      // Optional message for debugging/logging
}

// Expression types for template evaluation
type Expression = VariableExpr
	| PropertyExpr
	| MethodCallExpr
	| LiteralExpr
	| BinaryOpExpr
	| UnaryOpExpr
	| ArrayAccessExpr
	| DefaultExpr
	| TemplateStringExpr
	| TernaryExpr

// Simple variable reference: ${name}
struct VariableExpr {
pub:
	name string
}

// Property access: ${user.name}
struct PropertyExpr {
pub:
	object   Expression
	property string
}

// Method call: ${name?upper_case} or ${items.size()}
struct MethodCallExpr {
pub:
	object Expression
	method string
	args   []Expression
}

// Array/Map access: ${items[0]} or ${map["key"]}
struct ArrayAccessExpr {
pub:
	object Expression
	index  Expression
}

// Literal values: "string", 123, true
struct LiteralExpr {
pub:
	value Any
}

// Binary operations: ${a + b}, ${x == y}
struct BinaryOpExpr {
pub:
	left     Expression
	operator string
	right    Expression
}

// Unary operations: ${!flag}, ${-value}
struct UnaryOpExpr {
pub:
	operator string
	operand  Expression
}

// Default value expression: ${name!"default"}
struct DefaultExpr {
pub:
	expression Expression
	default_value Expression
}

// Template string that needs processing (from multi-line assign)
struct TemplateStringExpr {
pub:
	content string
}

// Ternary conditional expression: ${condition ? trueValue : falseValue}
struct TernaryExpr {
pub:
	condition Expression
	true_expr Expression
	false_expr Expression
}

// <#switch value>...</#switch> directive
struct SwitchNode {
pub:
	expression     Expression
	case_blocks    []CaseBlock
	default_block  []Node
}

// Individual case block within switch
struct CaseBlock {
pub:
	value Expression
	block []Node
}