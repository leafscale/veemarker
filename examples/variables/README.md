# VeeMarker Variables Example

This example demonstrates how to work with variables in VeeMarker templates.

## Features Covered

- Simple variable interpolation (`${variable}`)
- Nested object access (`${object.property}`)
- Array indexing (`${array[0]}`)
- Default values (`${variable!"default"}`)
- Missing variable handling with `??` operator

## Running the Example

```bash
cd variables
v run main.v
```

## Files

- `main.v` - V code that sets up the data and renders the template
- `template.vtpl` - VeeMarker template demonstrating variable usage
- `README.md` - This file

## Key Concepts

### Variable Types
VeeMarker supports all basic V data types:
- Strings
- Numbers (int, float)
- Booleans
- Arrays
- Maps (objects)

### Default Values
Use `!` operator to provide default values:
```
${nickname!"No nickname"}  <#-- Shows "No nickname" if variable doesn't exist -->
```

### Safe Navigation
Use `??` to check if a variable exists:
```
<#if email??>
  Email: ${email}
</#if>
```