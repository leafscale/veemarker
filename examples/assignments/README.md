# VeeMarker Assignments Example

This example demonstrates variable assignments and manipulation in VeeMarker templates.

## Features Covered

- Basic variable assignment with `<#assign>`
- String concatenation in assignments
- Arithmetic calculations
- Creating lists and maps
- Running totals in loops
- Conditional assignments
- Multiple variable assignments

## Running the Example

```bash
cd assignments
VMODULES=~/repos v run main.v
```

## Files

- `main.v` - V code that sets up initial data
- `template.vtpl` - VeeMarker template demonstrating assignments
- `README.md` - This file

## Key Concepts

### Basic Assignment
```vtpl
<#assign variable = value>
```

### Arithmetic Operations
```vtpl
<#assign total = price * quantity>
<#assign discount = price * 0.1>
```

### String Operations
```vtpl
<#assign full_name = first_name + " " + last_name>
```

### Creating Collections
```vtpl
<#assign fruits = ["apple", "banana", "orange"]>
<#assign user = {"name": "John", "age": 30}>
```

### Running Totals
```vtpl
<#assign total = 0>
<#list items as item>
  <#assign total = total + item.price>
</#list>
```

## Example Data

The example uses:
- Pricing data for calculations
- User information for concatenation
- Product lists for totaling
- Numbers for arithmetic operations

## Use Cases

- **Dynamic Calculations**: Compute values on the fly
- **String Building**: Construct messages dynamically
- **Data Transformation**: Modify data before display
- **State Management**: Track values across template sections