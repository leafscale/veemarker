/******************************************************************************
                __               ____                __
               / /   ___  ____ _/ __/_____________ _/ /__
              / /   / _ \/ __ `/ /_/ ___/ ___/ __ `/ / _ \
             / /___/  __/ /_/ / __(__  ) /__/ /_/ / /  __/
            /_____/\___/\__,_/_/ /____/\___/\__,_/_/\___/

    (C)opyright 2025, Leafscale, LLC -  https://www.leafscale.com

    Project: VeeMarker
   Filename: veemarker.v
    Authors: Chris Tusa <chris.tusa@leafscale.com>
    License: <see LICENSE file included with this source code>
Description: Main template engine with caching and rendering capabilities

******************************************************************************/
module veemarker

import os
import strings

// Public configuration for the template engine
pub struct EngineConfig {
pub mut:
	template_dir  string = './templates'
	cache_enabled bool
	dev_mode      bool   = true
	auto_reload   bool   = true
}

// Main template engine
pub struct Engine {
mut:
	template_dir string
	cache        map[string]Template
	dev_mode     bool
	auto_reload  bool
}

// Internal template representation
struct Template {
mut:
	path          string
	content       string
	ast           []Node
	last_modified i64
}

// Create a new template engine
pub fn new_engine(config EngineConfig) Engine {
	return Engine{
		template_dir: config.template_dir
		dev_mode:     config.dev_mode
		auto_reload:  config.auto_reload
		cache:        map[string]Template{}
	}
}

// Render a template file with the given context
pub fn (mut e Engine) render(template_name string, data map[string]Any) !string {
	template := e.load_template(template_name)!
	mut ctx := new_context(data)
	return e.render_template(template, mut ctx)
}

// Render a template string directly
pub fn (mut e Engine) render_string(template_content string, data map[string]Any) !string {
	template := e.parse_template_string(template_content)!
	mut ctx := new_context(data)
	return e.render_template(template, mut ctx)
}

// Load and parse a template file
fn (mut e Engine) load_template(name string) !Template {
	path := os.join_path(e.template_dir, name)

	// Check cache if enabled
	if !e.dev_mode && path in e.cache {
		cached := e.cache[path]
		// In production, use cached version
		if !e.auto_reload {
			return cached
		}
		// Check if file has been modified
		stat := os.stat(path) or { return error('Template file not found: ${path}') }
		if stat.mtime == cached.last_modified {
			return cached
		}
	}

	// Load and parse template
	content := os.read_file(path) or { return error('Failed to read template: ${path}') }
	template := e.parse_template_string(content)!

	// Update cache
	stat := os.stat(path) or { return error('Template file not found: ${path}') }
	mut cached_template := template
	cached_template.path = path
	cached_template.last_modified = stat.mtime
	e.cache[path] = cached_template

	return cached_template
}

// Parse template content into AST
fn (mut e Engine) parse_template_string(content string) !Template {
	mut lexer := new_lexer(content)
	tokens := lexer.tokenize()!

	mut parser := new_parser(tokens)
	parser.input = content  // Pass original input for multi-line assign
	ast := parser.parse()!

	return Template{
		content: content
		ast:     ast
	}
}

// Render a parsed template with context
fn (mut e Engine) render_template(template Template, mut ctx Context) !string {
	mut result := strings.new_builder(template.content.len * 2)

	for node in template.ast {
		rendered := e.render_node(node, mut ctx) or {
			// Check if this is a stop directive error
			if err.msg().contains('Template processing stopped') {
				// Return current result when stop directive is encountered
				return result.str()
			}
			// Otherwise propagate the error
			return err
		}
		result.write_string(rendered)
	}

	return result.str()
}

// Render a single AST node
fn (mut e Engine) render_node(node Node, mut ctx Context) !string {
	match node {
		TextNode {
			return node.content
		}
		InterpolationNode {
			// Try to evaluate the expression
			value := evaluate_expression_or_default(node.expression, node.default_value, ctx)
			return value_to_string(value)
		}
		IfNode {
			condition_value := evaluate_expression(node.condition, ctx)!
			if is_truthy(condition_value) {
				return e.render_nodes(node.then_block, mut ctx)!
			}

			// Check elseif blocks
			for elseif in node.elseif_blocks {
				elseif_condition := evaluate_expression(elseif.condition, ctx)!
				if is_truthy(elseif_condition) {
					return e.render_nodes(elseif.block, mut ctx)!
				}
			}

			// Render else block if present
			if node.else_block.len > 0 {
				return e.render_nodes(node.else_block, mut ctx)!
			}

			return ''
		}
		ListNode {
			collection_value := evaluate_expression(node.collection, ctx)!
			mut result := strings.new_builder(100)

			match collection_value {
				[]Any {
					// Check if collection is empty - render else block if present
					if collection_value.len == 0 {
						if node.else_block.len > 0 {
							return e.render_nodes(node.else_block, mut ctx)!
						}
						return ''
					}

					// Render main loop with separators
					for i, item in collection_value {
						// Create child context for loop iteration
						mut loop_ctx := ctx.new_child()
						loop_ctx.set(node.item_var, item)
						if node.index_var.len > 0 {
							loop_ctx.set(node.index_var, i)
						}
						// Add FreeMarker loop variables
						loop_ctx.set('${node.item_var}_index', i)
						loop_ctx.set('${node.item_var}_has_next', i < collection_value.len - 1)

						// Render separator before item (except for first item)
						if i > 0 && node.sep_block.len > 0 {
							sep_rendered := e.render_nodes(node.sep_block, mut loop_ctx)!
							result.write_string(sep_rendered)
						}

						// Render main item block
						rendered := e.render_nodes(node.block, mut loop_ctx)!
						result.write_string(rendered)
					}
				}
				map[string]Any {
					// Check if collection is empty - render else block if present
					if collection_value.len == 0 {
						if node.else_block.len > 0 {
							return e.render_nodes(node.else_block, mut ctx)!
						}
						return ''
					}

					// Render main loop with separators
					mut i := 0
					for key, value in collection_value {
						// Create child context for loop iteration
						mut loop_ctx := ctx.new_child()
						mut item_map := map[string]Any{}
						item_map['key'] = key
						item_map['value'] = value
						loop_ctx.set(node.item_var, item_map)
						if node.index_var.len > 0 {
							loop_ctx.set(node.index_var, i)
						}
						// Add FreeMarker loop variables
						loop_ctx.set('${node.item_var}_index', i)
						loop_ctx.set('${node.item_var}_has_next', i < collection_value.len - 1)

						// Render separator before item (except for first item)
						if i > 0 && node.sep_block.len > 0 {
							sep_rendered := e.render_nodes(node.sep_block, mut loop_ctx)!
							result.write_string(sep_rendered)
						}

						// Render main item block
						rendered := e.render_nodes(node.block, mut loop_ctx)!
						result.write_string(rendered)
						i++
					}
				}
				else {
					return error('Cannot iterate over ${typeof(collection_value).name}')
				}
			}

			return result.str()
		}
		AssignNode {
			// Check if this is a multi-line assign with template content
			match node.value {
				TemplateStringExpr {
					// Parse and render the template content
					template := e.parse_template_string(node.value.content)!
					rendered := e.render_template(template, mut ctx)!
					ctx.set(node.variable, rendered)
				}
				else {
					// Regular assign expression
					value := evaluate_expression(node.value, ctx)!
					ctx.set(node.variable, value)
				}
			}
			return ''
		}
		CommentNode {
			// Comments produce no output
			return ''
		}
		IncludeNode {
			// Load and render the included template
			included_template := e.load_template(node.template_path)!
			return e.render_template(included_template, mut ctx)!
		}
		AttemptNode {
			// Try to render the attempt block, fall back to recover block on error
			attempt_result := e.render_nodes(node.attempt_block, mut ctx) or {
				// If attempt block fails, render recover block if present
				if node.recover_block.len > 0 {
					return e.render_nodes(node.recover_block, mut ctx)!
				}
				return ''
			}
			return attempt_result
		}
		NoParseNode {
			// Return content as-is without any template processing
			return node.content
		}
		MacroNode {
			// Store macro definition in context for later calls
			ctx.set_macro(node.name, node)
			return '' // Macro definitions produce no output
		}
		MacroCallNode {
			// Execute macro call
			macro := ctx.get_macro(node.name) or {
				return error('Macro "${node.name}" not found')
			}

			// Create child context for macro execution
			mut macro_ctx := ctx.new_child()

			// Bind arguments to parameters
			for param in macro.parameters {
				if param.name in node.arguments {
					// Evaluate the argument expression
					arg_value := evaluate_expression(node.arguments[param.name] or { LiteralExpr{''} }, ctx)!
					macro_ctx.set(param.name, arg_value)
				} else if default_expr := param.default_value {
					// Use the default value from macro definition
					default_val := evaluate_expression(default_expr, ctx)!
					macro_ctx.set(param.name, default_val)
				} else {
					// No argument provided and no default - set to empty string
					macro_ctx.set(param.name, '')
				}
			}

			// Render macro body with the macro context
			rendered := e.render_nodes(macro.body, mut macro_ctx) or {
				// Check if this is a macro return signal
				if err.msg().starts_with('Macro return: ') {
					// Extract the return value from the error message
					return_value := err.msg().replace('Macro return: ', '')
					return return_value
				}
				// Otherwise propagate the error
				return err
			}
			return rendered
		}
		StopNode {
			// Stop directive halts template processing
			// We use an error to signal stopping, which gets caught by render_nodes
			return error('Template processing stopped: ${node.message}')
		}
		ReturnNode {
			// Return directive returns from macro execution
			// We use an error to signal return, similar to stop but for macros
			if expr := node.value {
				value := evaluate_expression(expr, ctx)!
				return error('Macro return: ${value_to_string(value)}')
			}
			return error('Macro return: ${node.message}')
		}
		SwitchNode {
			switch_value := evaluate_expression(node.expression, ctx)!

			// Try each case block
			for case_block in node.case_blocks {
				case_value := evaluate_expression(case_block.value, ctx)!
				if compare_values(switch_value, case_value) == 0 {
					return e.render_nodes(case_block.block, mut ctx)!
				}
			}

			// If no case matched, render default block if present
			if node.default_block.len > 0 {
				return e.render_nodes(node.default_block, mut ctx)!
			}

			// No matching case and no default block
			return ''
		}
	}
}

// Render multiple nodes
fn (mut e Engine) render_nodes(nodes []Node, mut ctx Context) !string {
	mut result := strings.new_builder(100)
	for node in nodes {
		rendered := e.render_node(node, mut ctx) or {
			// Check if this is a stop directive error
			if err.msg().contains('Template processing stopped') {
				// Return current result when stop directive is encountered
				return result.str()
			}
			// Otherwise propagate the error
			return err
		}
		result.write_string(rendered)
	}
	return result.str()
}

// Convert any value to string for output
fn value_to_string(value Any) string {
	match value {
		string {
			return value
		}
		int {
			return value.str()
		}
		f64 {
			// Format whole numbers without decimal points
			if value == f64(int(value)) {
				return int(value).str()
			}
			return value.str()
		}
		bool {
			return value.str()
		}
		[]Any {
			mut parts := []string{}
			for item in value {
				parts << value_to_string(item)
			}
			return parts.join(', ')
		}
		map[string]Any {
			mut parts := []string{}
			for key, val in value {
				parts << '${key}: ${value_to_string(val)}'
			}
			return '{' + parts.join(', ') + '}'
		}
	}
}
