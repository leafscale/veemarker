/******************************************************************************
                __               ____                __
               / /   ___  ____ _/ __/_____________ _/ /__
              / /   / _ \/ __ `/ /_/ ___/ ___/ __ `/ / _ \
             / /___/  __/ /_/ / __(__  ) /__/ /_/ / /  __/
            /_____/\___/\__,_/_/ /____/\___/\__,_/_/\___/

    (C)opyright 2025, Leafscale, LLC -  https://www.leafscale.com

    Project: VeeMarker
   Filename: evaluator.v
    Authors: Chris Tusa <chris.tusa@leafscale.com>
    License: <see LICENSE file included with this source code>
Description: Expression evaluation engine for template execution

******************************************************************************/
module veemarker

// Evaluate an expression with optional default value
pub fn evaluate_expression_or_default(expr Expression, default_expr ?Expression, ctx Context) Any {
	// Try to evaluate the main expression
	result := evaluate_expression(expr, ctx) or {
		// If main expression fails and we have a default, use it
		if default_val := default_expr {
			return evaluate_expression(default_val, ctx) or { '' }
		}
		return ''
	}

	// Check if result is empty/null
	match result {
		string {
			if result.len == 0 {
				if default_val := default_expr {
					return evaluate_expression(default_val, ctx) or { '' }
				}
			}
		}
		else {}
	}

	return result
}

// Evaluate an expression in the given context
pub fn evaluate_expression(expr Expression, ctx Context) !Any {
	match expr {
		VariableExpr {
			return ctx.get(expr.name) or { return error('Variable "${expr.name}" not found') }
		}
		LiteralExpr {
			return expr.value
		}
		PropertyExpr {
			obj := evaluate_expression(expr.object, ctx)!
			return resolve_property(obj, expr.property)!
		}
		ArrayAccessExpr {
			obj := evaluate_expression(expr.object, ctx)!
			index := evaluate_expression(expr.index, ctx)!
			return resolve_index(obj, index)!
		}
		MethodCallExpr {
			obj := evaluate_expression(expr.object, ctx)!
			return evaluate_method_call(obj, expr.method, expr.args, ctx)!
		}
		BinaryOpExpr {
			left := evaluate_expression(expr.left, ctx)!
			right := evaluate_expression(expr.right, ctx)!
			return evaluate_binary_op(left, expr.operator, right)!
		}
		UnaryOpExpr {
			operand := evaluate_expression(expr.operand, ctx)!
			return evaluate_unary_op(expr.operator, operand)!
		}
		DefaultExpr {
			// Try to evaluate the main expression, if it fails or is empty, use default
			result := evaluate_expression(expr.expression, ctx) or {
				return evaluate_expression(expr.default_value, ctx)!
			}
			// Check if result is empty/null and use default
			match result {
				string {
					if result.len == 0 {
						return evaluate_expression(expr.default_value, ctx)!
					}
				}
				else {}
			}
			return result
		}
		TemplateStringExpr {
			// This should be handled by the engine during AssignNode processing
			// If we get here, return the raw content
			return expr.content
		}
		TernaryExpr {
			condition_value := evaluate_expression(expr.condition, ctx)!
			if is_truthy(condition_value) {
				return evaluate_expression(expr.true_expr, ctx)!
			} else {
				return evaluate_expression(expr.false_expr, ctx)!
			}
		}
	}
}

// Evaluate a method call (including FreeMarker built-in functions)
fn evaluate_method_call(obj Any, method string, args []Expression, ctx Context) !Any {
	// Handle FreeMarker built-in functions
	match method {
		'upper_case' {
			str := any_to_string(obj)
			return str.to_upper()
		}
		'lower_case' {
			str := any_to_string(obj)
			return str.to_lower()
		}
		'cap_first', 'capitalize' {
			str := any_to_string(obj)
			if str.len > 0 {
				return str[0].ascii_str().to_upper() + str[1..]
			}
			return str
		}
		'trim' {
			str := any_to_string(obj)
			return str.trim_space()
		}
		'length', 'size' {
			match obj {
				string { return obj.len }
				[]Any { return obj.len }
				map[string]Any { return obj.len }
				else { return error('Cannot get length of ${typeof(obj).name}') }
			}
		}
		'has_content' {
			match obj {
				string { return obj.len > 0 }
				[]Any { return obj.len > 0 }
				map[string]Any { return obj.len > 0 }
				else { return false }
			}
		}
		'reverse' {
			match obj {
				string {
					return obj.reverse()
				}
				[]Any {
					mut reversed := []Any{}
					for i := obj.len - 1; i >= 0; i-- {
						reversed << obj[i]
					}
					return reversed
				}
				else {
					return error('Cannot reverse ${typeof(obj).name}')
				}
			}
		}
		'contains' {
			if args.len != 1 {
				return error('contains() requires exactly 1 argument')
			}
			search := evaluate_expression(args[0], ctx)!
			match obj {
				string {
					search_str := any_to_string(search)
					return obj.contains(search_str)
				}
				[]Any {
					for item in obj {
						if compare_values(item, search) == 0 {
							return true
						}
					}
					return false
				}
				else {
					return error('Cannot check contains on ${typeof(obj).name}')
				}
			}
		}
		'starts_with' {
			if args.len != 1 {
				return error('starts_with() requires exactly 1 argument')
			}
			prefix := any_to_string(evaluate_expression(args[0], ctx)!)
			str := any_to_string(obj)
			return str.starts_with(prefix)
		}
		'ends_with' {
			if args.len != 1 {
				return error('ends_with() requires exactly 1 argument')
			}
			suffix := any_to_string(evaluate_expression(args[0], ctx)!)
			str := any_to_string(obj)
			return str.ends_with(suffix)
		}
		'replace' {
			if args.len != 2 {
				return error('replace() requires exactly 2 arguments')
			}
			str := any_to_string(obj)
			find := any_to_string(evaluate_expression(args[0], ctx)!)
			replace := any_to_string(evaluate_expression(args[1], ctx)!)
			return str.replace(find, replace)
		}
		'substring' {
			if args.len < 1 || args.len > 2 {
				return error('substring() requires 1 or 2 arguments (start [, end])')
			}
			str := any_to_string(obj)
			start := any_to_int(evaluate_expression(args[0], ctx)!)!

			// Validate start index
			if start < 0 || start > str.len {
				return error('substring start index ${start} out of bounds for string of length ${str.len}')
			}

			if args.len == 1 {
				// substring(start) - from start to end of string
				result := str[start..]
				return result
			} else {
				// substring(start, end) - from start to end (exclusive)
				end := any_to_int(evaluate_expression(args[1], ctx)!)!
				if end < start || end > str.len {
					return error('substring end index ${end} out of bounds or less than start ${start}')
				}
				result := str[start..end]
				return result
			}
		}
		'split' {
			if args.len != 1 {
				return error('split() requires exactly 1 argument')
			}
			str := any_to_string(obj)
			delimiter := any_to_string(evaluate_expression(args[0], ctx)!)
			parts := str.split(delimiter)
			mut result := []Any{}
			for part in parts {
				result << part
			}
			return result
		}
		'join' {
			if args.len != 1 {
				return error('join() requires exactly 1 argument')
			}
			separator := any_to_string(evaluate_expression(args[0], ctx)!)
			match obj {
				[]Any {
					mut parts := []string{}
					for item in obj {
						parts << any_to_string(item)
					}
					return parts.join(separator)
				}
				else {
					return error('Cannot join ${typeof(obj).name}')
				}
			}
		}
		'first' {
			match obj {
				[]Any {
					if obj.len > 0 {
						return obj[0]
					}
					return error('Cannot get first element of empty array')
				}
				else {
					return error('Cannot get first element of ${typeof(obj).name}')
				}
			}
		}
		'last' {
			match obj {
				[]Any {
					if obj.len > 0 {
						return obj[obj.len - 1]
					}
					return error('Cannot get last element of empty array')
				}
				else {
					return error('Cannot get last element of ${typeof(obj).name}')
				}
			}
		}
		'min' {
			match obj {
				[]Any {
					if obj.len == 0 {
						return error('Cannot get minimum of empty array')
					}
					mut min_val := obj[0]
					for item in obj[1..] {
						if compare_values(item, min_val) < 0 {
							min_val = item
						}
					}
					return min_val
				}
				else {
					return error('Cannot get minimum of ${typeof(obj).name}')
				}
			}
		}
		'max' {
			match obj {
				[]Any {
					if obj.len == 0 {
						return error('Cannot get maximum of empty array')
					}
					mut max_val := obj[0]
					for item in obj[1..] {
						if compare_values(item, max_val) > 0 {
							max_val = item
						}
					}
					return max_val
				}
				else {
					return error('Cannot get maximum of ${typeof(obj).name}')
				}
			}
		}
		'seq_contains' {
			if args.len != 1 {
				return error('seq_contains() requires exactly 1 argument')
			}
			search_value := evaluate_expression(args[0], ctx)!
			match obj {
				[]Any {
					for item in obj {
						if compare_values(item, search_value) == 0 {
							return true
						}
					}
					return false
				}
				else {
					return error('seq_contains can only be used on sequences/arrays')
				}
			}
		}
		'then' {
			// FreeMarker's conditional built-in: condition?then(trueValue, falseValue)
			if args.len != 2 {
				return error('then() requires exactly 2 arguments (true value, false value)')
			}
			condition := is_truthy(obj)
			if condition {
				return evaluate_expression(args[0], ctx)!
			} else {
				return evaluate_expression(args[1], ctx)!
			}
		}
		'string' {
			// Convert boolean to string representation
			match obj {
				bool {
					if obj {
						return 'true'
					} else {
						return 'false'
					}
				}
				else {
					return any_to_string(obj)
				}
			}
		}
		'c' {
			// FreeMarker's computer-language format for booleans
			match obj {
				bool {
					if obj {
						return 'true'
					} else {
						return 'false'
					}
				}
				else {
					return any_to_string(obj)
				}
			}
		}
		else {
			// Try to call as a regular method
			return resolve_property(obj, method)!
		}
	}
}

// Evaluate a binary operation
fn evaluate_binary_op(left Any, op string, right Any) !Any {
	match op {
		'==' {
			return compare_values(left, right) == 0
		}
		'!=' {
			return compare_values(left, right) != 0
		}
		'<' {
			return compare_values(left, right) < 0
		}
		'<=' {
			return compare_values(left, right) <= 0
		}
		'>' {
			return compare_values(left, right) > 0
		}
		'>=' {
			return compare_values(left, right) >= 0
		}
		'&&' {
			return is_truthy(left) && is_truthy(right)
		}
		'||' {
			return is_truthy(left) || is_truthy(right)
		}
		'+' {
			// Handle string concatenation
			left_str := match left {
				string { true }
				else { false }
			}
			right_str := match right {
				string { true }
				else { false }
			}

			if left_str || right_str {
				return any_to_string(left) + any_to_string(right)
			}

			// Numeric addition
			left_num := any_to_number(left)!
			right_num := any_to_number(right)!
			return left_num + right_num
		}
		'-' {
			left_num := any_to_number(left)!
			right_num := any_to_number(right)!
			return left_num - right_num
		}
		'*' {
			left_num := any_to_number(left)!
			right_num := any_to_number(right)!
			return left_num * right_num
		}
		'/' {
			left_num := any_to_number(left)!
			right_num := any_to_number(right)!
			if right_num == 0 {
				return error('Division by zero')
			}
			return left_num / right_num
		}
		'%' {
			left_int := any_to_int(left)!
			right_int := any_to_int(right)!
			if right_int == 0 {
				return error('Modulo by zero')
			}
			return left_int % right_int
		}
		else {
			return error('Unknown operator: ${op}')
		}
	}
}

// Evaluate a unary operation
fn evaluate_unary_op(op string, operand Any) !Any {
	match op {
		'!' {
			return !is_truthy(operand)
		}
		'-' {
			num := any_to_number(operand)!
			neg := 0.0 - num
			return neg
		}
		else {
			return error('Unknown unary operator: ${op}')
		}
	}
}

// Compare two values
fn compare_values(left Any, right Any) int {
	// Try numeric comparison
	left_num := any_to_number(left) or { f64(0) }
	right_num := any_to_number(right) or { f64(0) }

	// Check if both values can be converted to numbers
	left_is_num := match left {
		int, f64 { true }
		string { left.f64() != 0 || left == '0' || left == '0.0' }
		else { false }
	}
	right_is_num := match right {
		int, f64 { true }
		string { right.f64() != 0 || right == '0' || right == '0.0' }
		else { false }
	}

	// If both can be converted to numbers, compare numerically
	if left_is_num && right_is_num {
		if left_num < right_num {
			return -1
		}
		if left_num > right_num {
			return 1
		}
		return 0
	}

	// String comparison
	left_str := any_to_string(left)
	right_str := any_to_string(right)

	if left_str < right_str {
		return -1
	}
	if left_str > right_str {
		return 1
	}
	return 0
}

// Convert any value to a number (f64)
fn any_to_number(value Any) !f64 {
	match value {
		int {
			return f64(value)
		}
		f64 {
			return value
		}
		string {
			num := value.f64()
			if num == 0.0 && value != '0' && value != '0.0' && value != '0.' && !value.starts_with('0.') {
				return error('Cannot convert "${value}" to number')
			}
			return num
		}
		bool {
			if value {
				return 1.0
			} else {
				return 0.0
			}
		}
		else {
			return error('Cannot convert ${typeof(value).name} to number')
		}
	}
}

// Convert any value to an integer
fn any_to_int(value Any) !int {
	match value {
		int {
			return value
		}
		f64 {
			return int(value)
		}
		string {
			num := value.int()
			if num == 0 && value != '0' {
				return error('Cannot convert "${value}" to integer')
			}
			return num
		}
		bool {
			if value {
				return 1
			} else {
				return 0
			}
		}
		else {
			return error('Cannot convert ${typeof(value).name} to integer')
		}
	}
}

// Convert any value to string
fn any_to_string(value Any) string {
	return value_to_string(value)
}
