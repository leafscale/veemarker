# VeeMarker Struct Conversion Example

This example demonstrates the **correct way** to use V structs with VeeMarker templates.

## The Problem

VeeMarker's `Any` type only supports specific types:
- Primitives: `string`, `int`, `f64`, `bool`
- Collections: `[]Any`, `map[string]Any`

It does **NOT** support arbitrary V structs directly. Attempting to pass a struct will cause errors or crashes.

## The Solution

Use `veemarker.to_map()` and `veemarker.to_map_array()` helper functions to convert structs to `map[string]Any`:

```v
struct Customer {
    id    int
    name  string
    email string
}

// Convert single struct
customer := Customer{id: 1, name: 'Alice', email: 'alice@example.com'}
data := {
    'customer': veemarker.to_map(customer)  // ✓ Correct
}

// Convert array of structs
customers := [Customer{...}, Customer{...}]
data := {
    'customers': veemarker.to_map_array(customers)  // ✓ Correct
}
```

## Running This Example

From the project root:
```bash
v run test_struct_helpers.v
```

This demonstrates the solution to the bug reported in `veemarker_bug_report.md`.

## See Also

- `struct_helpers.v` - Implementation of conversion helpers
- `STRUCT_USAGE.md` - Detailed documentation on working with structs
