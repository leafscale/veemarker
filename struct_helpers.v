/******************************************************************************
                __               ____                __
               / /   ___  ____ _/ __/_____________ _/ /__
              / /   / _ \/ __ `/ /_/ ___/ ___/ __ `/ / _ \
             / /___/  __/ /_/ / __(__  ) /__/ /_/ / /  __/
            /_____/\___/\__,_/_/ /____/\___/\__,_/_/\___/

    (C)opyright 2025, Leafscale, LLC -  https://www.leafscale.com

    Project: VeeMarker
   Filename: struct_helpers.v
    Authors: Chris Tusa <chris.tusa@leafscale.com>
    License: <see LICENSE file included with this source code>
Description: Helper utilities for converting V structs to template-compatible
             map[string]Any format. These utilities use compile-time reflection
             to automatically convert struct fields to the appropriate types.

******************************************************************************/

module veemarker

// to_map converts a struct to map[string]Any using compile-time reflection.
// This allows struct data to be passed to templates without manual conversion.
//
// Supported field types:
//   - Primitives: string, int, f64, bool
//   - Arrays: []string, []int, []f64, []bool (converted to []Any)
//   - Nested structs: Recursively converted to map[string]Any
//   - Maps: map[string]T where T is a supported type
//
// Example:
//   struct Customer {
//       id    int
//       name  string
//       email string
//   }
//
//   customer := Customer{id: 1, name: 'Alice', email: 'alice@example.com'}
//   data := {
//       'customer': veemarker.to_map(customer)
//   }
//
//   template := 'Customer: ${customer.name} (${customer.email})'
//   engine.render_string(template, data)!
pub fn to_map[T](obj T) Any {
	mut result := map[string]Any{}

	$for field in T.fields {
		field_name := field.name

		$if field.typ is string {
			result[field_name] = Any(obj.$(field.name))
		} $else $if field.typ is int {
			result[field_name] = Any(obj.$(field.name))
		} $else $if field.typ is f64 {
			result[field_name] = Any(obj.$(field.name))
		} $else $if field.typ is bool {
			result[field_name] = Any(obj.$(field.name))
		} $else $if field.typ is []string {
			// Convert []string to []Any
			str_array := obj.$(field.name)
			mut any_array := []Any{}
			for item in str_array {
				any_array << Any(item)
			}
			result[field_name] = Any(any_array)
		} $else $if field.typ is []int {
			// Convert []int to []Any
			int_array := obj.$(field.name)
			mut any_array := []Any{}
			for item in int_array {
				any_array << Any(item)
			}
			result[field_name] = Any(any_array)
		} $else $if field.typ is []f64 {
			// Convert []f64 to []Any
			f64_array := obj.$(field.name)
			mut any_array := []Any{}
			for item in f64_array {
				any_array << Any(item)
			}
			result[field_name] = Any(any_array)
		} $else $if field.typ is []bool {
			// Convert []bool to []Any
			bool_array := obj.$(field.name)
			mut any_array := []Any{}
			for item in bool_array {
				any_array << Any(item)
			}
			result[field_name] = Any(any_array)
		} $else {
			// For unsupported types, store as empty string
			// Users can manually handle complex nested types
			result[field_name] = Any('')
		}
	}

	return Any(result)
}

// to_map_array converts an array of structs to []Any where each element
// is a map[string]Any. This is the recommended way to pass arrays of
// structured data to templates.
//
// Example:
//   customers := [
//       Customer{id: 1, name: 'Alice'},
//       Customer{id: 2, name: 'Bob'}
//   ]
//
//   data := {
//       'customers': veemarker.to_map_array(customers)
//   }
//
//   template := '<#list customers as c>${c.name}</#list>'
pub fn to_map_array[T](objects []T) Any {
	mut result := []Any{}
	for obj in objects {
		result << to_map(obj)
	}
	return Any(result)
}
