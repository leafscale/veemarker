# VeeMarker Hello World Example

This example demonstrates basic VeeMarker template engine usage.

## Files

- `main.v` - The V program that uses VeeMarker
- `hello.vtpl` - The VeeMarker template file

## Template File Extension

We use `.vtpl` (V Template) as the standard extension for VeeMarker template files:
- `.vtpl` - **V T**em**pl**ate - clearly indicates both V language and template nature
- Alternative considered: `.vee` (VeeMarker), `.vmrk` (VeeMarker)

## Running the Example

From this directory:

```bash
v run main.v
```

## Features Demonstrated

1. **Basic Interpolation** - `${variable}`
2. **Conditionals** - `<#if>`, `<#else>`, `</#if>`
3. **List Iteration** - `<#list items as item>`, `</#list>`
4. **Built-in Functions** - `?upper_case`, `?lower_case`, `?length`, `?size`
5. **Variable Assignment** - `<#assign variable = value>`
6. **Expressions** - Arithmetic, comparisons, boolean logic
7. **Nested Objects** - `${user.profile.city}`
8. **Array Access** - `${items[0]}`
9. **Comments** - `<#-- comment -->`

## Template Data Structure

The example uses:
- Simple strings and numbers
- Arrays/lists
- Nested maps/objects
- Boolean values
- Calculated expressions