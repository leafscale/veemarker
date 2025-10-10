# VeeMarker Strings Example

This example demonstrates string manipulation and formatting in VeeMarker templates.

## Features Covered

- Case transformations (upper_case, lower_case, capitalize)
- String trimming and length
- String replacement
- Substring operations
- String checking (starts_with, ends_with, contains)
- Number and boolean formatting
- String concatenation
- Default values for empty strings
- Chaining multiple operations

## Running the Example

```bash
cd strings
VMODULES=~/repos v run main.v
```

## Files

- `main.v` - V code that sets up various string data
- `template.vtpl` - VeeMarker template demonstrating string operations
- `README.md` - This file

## Key String Operations

### Case Transformations
- `?upper_case` - Convert to uppercase
- `?lower_case` - Convert to lowercase
- `?capitalize` - Capitalize first letter of each word

### String Manipulation
- `?trim` - Remove leading/trailing whitespace
- `?length` - Get string length
- `?replace(old, new)` - Replace substring
- `?substring(start)` - Get substring from index
- `?substring(start, end)` - Get substring between indices

### String Checking
- `?starts_with(prefix)` - Check if starts with prefix
- `?ends_with(suffix)` - Check if ends with suffix
- `?contains(substring)` - Check if contains substring

### Formatting
- `?c` - Canonical form for booleans (true/false)
- `!` - Default value operator

## Example Data

The example uses various strings to demonstrate:
- Title and sentence manipulation
- Email and URL processing
- Path operations
- Code formatting
- Empty string handling
- Number and boolean display

## Chaining Operations

Operations can be chained together:
```vtpl
${text?trim?upper_case?replace("_", " ")}
```

This trims whitespace, converts to uppercase, and replaces underscores with spaces.