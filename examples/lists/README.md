# VeeMarker Lists Example

This example demonstrates list iteration and array processing in VeeMarker templates.

## Features Covered

- Basic list iteration with `<#list>`
- Accessing list item index and counter
- List separators with `<#sep>`
- Iterating over objects/maps
- Nested list structures
- Loop control variables (index, counter, is_first, is_last, has_next)
- Empty list handling with `<#else>`
- Breaking out of loops with `<#break>`

## Running the Example

```bash
cd lists
VMODULES=~/repos v run main.v
```

## Files

- `main.v` - V code that sets up various list data structures
- `template.vtpl` - VeeMarker template demonstrating list operations
- `README.md` - This file

## Key Concepts

### Basic List Iteration
```vtpl
<#list items as item>
  ${item}
</#list>
```

### List with Index
```vtpl
<#list items as item>
  ${item?index}: ${item}
</#list>
```

### List Separators
```vtpl
<#list items as item>
  ${item}<#sep>, </#sep>
</#list>
```

### Empty List Handling
```vtpl
<#list items as item>
  ${item}
<#else>
  No items found
</#list>
```

### Loop Variables
- `item?index` - Zero-based index
- `item?counter` - One-based counter
- `item?is_first` - Boolean, true for first item
- `item?is_last` - Boolean, true for last item
- `item?has_next` - Boolean, true if not last item
- `items?size` - Total number of items in list

### Breaking Loops
```vtpl
<#list items as item>
  ${item}
  <#if item?index == 2><#break></#if>
</#list>
```

## Example Data

The example uses various data structures:
- Simple string array (products)
- Array of objects (users with properties)
- Nested arrays (categories with items)
- Numeric arrays
- Empty arrays for demonstration

## Output

The template demonstrates all list features including:
- Simple iteration
- Indexed output
- Comma-separated lists
- Table-like formatting
- Filtered lists
- Nested list structures
- Loop control information
- Empty list fallback content
- Limited iteration with break