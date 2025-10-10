# VeeMarker Conditionals Example

This example demonstrates conditional logic and control flow in VeeMarker templates.

## Features Covered

- Basic `if/else` conditionals
- Boolean expressions and comparisons
- `elseif` chains for multiple conditions
- Complex conditions with stock levels
- Logical operators (`&&`, `||`)
- Nested conditionals

## Running the Example

```bash
cd conditionals
VMODULES=~/repos v run main.v
```

## Files

- `main.v` - V code that sets up various data scenarios for conditionals
- `template.vtpl` - VeeMarker template demonstrating conditional syntax
- `README.md` - This file

## Key Concepts

### Basic If/Else
```vtpl
<#if condition>
  True branch
<#else>
  False branch
</#if>
```

### ElseIf Chains
```vtpl
<#if score >= 90>
  Grade A
<#elseif score >= 80>
  Grade B
<#elseif score >= 70>
  Grade C
<#else>
  Grade F
</#if>
```

### Boolean Operators
- `&&` - Logical AND
- `||` - Logical OR
- `!` - Logical NOT
- Comparison operators: `>`, `<`, `>=`, `<=`, `==`, `!=`

### Null Checking
```vtpl
<#if variable??>
  Variable exists
</#if>
```

## Example Data

The example uses various data scenarios:
- User object with name, age, premium status, and level
- Stock count for inventory scenarios
- Temperature and weekend flags for complex conditions
- Score value for grade evaluation

## Output

The template renders different content based on the conditions, demonstrating:
- Premium vs standard user messages
- Age-based content
- Grade evaluation
- Stock availability messages
- Weather and weekend activity suggestions
- Nested user status display