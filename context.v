/******************************************************************************
                __               ____                __
               / /   ___  ____ _/ __/_____________ _/ /__
              / /   / _ \/ __ `/ /_/ ___/ ___/ __ `/ / _ \
             / /___/  __/ /_/ / __(__  ) /__/ /_/ / /  __/
            /_____/\___/\__,_/_/ /____/\___/\__,_/_/\___/

    (C)opyright 2025, Leafscale, LLC -  https://www.leafscale.com

    Project: VeeMarker
   Filename: context.v
    Authors: Chris Tusa <chris.tusa@leafscale.com>
    License: <see LICENSE file included with this source code>
Description: Variable context management and scoping for template execution

******************************************************************************/

module veemarker

// Context holds template variables and provides scoping
@[heap]
pub struct Context {
mut:
	variables map[string]Any
	macros    map[string]MacroNode
	parent    &Context = unsafe { nil }
}

// Create a new context with initial data
pub fn new_context(data map[string]Any) Context {
	return Context{
		variables: data
	}
}

// Create a child context (for scoped blocks like loops)
pub fn (c &Context) new_child() Context {
	return Context{
		variables: map[string]Any{}
		parent:    c
	}
}

// Set a variable in the current scope
pub fn (mut c Context) set(name string, value Any) {
	c.variables[name] = value
}

// Get a variable from the context (checks parent scopes)
pub fn (c &Context) get(name string) ?Any {
	if name in c.variables {
		return c.variables[name] or { return none }
	}

	// Check parent context if available
	if c.parent != unsafe { nil } {
		return c.parent.get(name)
	}

	return none
}

// Check if a variable exists in any scope
pub fn (c &Context) has(name string) bool {
	if name in c.variables {
		return true
	}

	if c.parent != unsafe { nil } {
		return c.parent.has(name)
	}

	return false
}

// Resolve a property access on an object
pub fn resolve_property(obj Any, property string) !Any {
	match obj {
		map[string]Any {
			if property in obj {
				return obj[property] or { return error('Property "${property}" not found') }
			}
			return error('Property "${property}" not found in map')
		}
		[]Any {
			// Handle special array properties
			if property == 'size' || property == 'length' {
				return obj.len
			}
			return error('Property "${property}" not found in array')
		}
		string {
			// Handle string properties
			if property == 'length' {
				return obj.len
			}
			return error('Property "${property}" not found in string')
		}
		else {
			return error('Cannot access property "${property}" on type ${typeof(obj).name}')
		}
	}
}

// Resolve array/map indexing
pub fn resolve_index(obj Any, index Any) !Any {
	match obj {
		[]Any {
			idx := match index {
				int { index }
				else { return error('Array index must be an integer') }
			}
			if idx < 0 || idx >= obj.len {
				return error('Array index ${idx} out of bounds')
			}
			return obj[idx]
		}
		map[string]Any {
			key := match index {
				string { index }
				else { return error('Map key must be a string') }
			}
			if key in obj {
				return obj[key] or { return error('Key "${key}" not found') }
			}
			return error('Key "${key}" not found in map')
		}
		string {
			idx := match index {
				int { index }
				else { return error('String index must be an integer') }
			}
			if idx < 0 || idx >= obj.len {
				return error('String index ${idx} out of bounds')
			}
			return obj[idx].ascii_str()
		}
		else {
			return error('Cannot index type ${typeof(obj).name}')
		}
	}
}

// Check if a value is truthy (for conditionals)
pub fn is_truthy(value Any) bool {
	match value {
		bool { return value }
		int { return value != 0 }
		f64 { return value != 0.0 }
		string { return value.len > 0 }
		[]Any { return value.len > 0 }
		map[string]Any { return value.len > 0 }
	}
}

// Register a macro in the current context
pub fn (mut c Context) set_macro(name string, macro MacroNode) {
	c.macros[name] = macro
}

// Get a macro from the context (checks parent scopes)
pub fn (c &Context) get_macro(name string) ?MacroNode {
	if name in c.macros {
		return c.macros[name]
	}

	// Check parent context if available
	if c.parent != unsafe { nil } {
		return c.parent.get_macro(name)
	}

	return none
}
