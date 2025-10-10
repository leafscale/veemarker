# VeeMarker Examples

This directory contains comprehensive examples demonstrating how to use VeeMarker, the FreeMarker-compatible template engine for V.

## Example Structure

Each example follows a simple, self-contained pattern:
- `main.v` - V code that sets up data and renders the template
- `template.vtpl` - VeeMarker template demonstrating specific features
- `README.md` - Documentation for the example

## Available Examples

### Core Features

#### 1. Variables (`/variables`)
Learn the basics of variable interpolation:
- Simple variable output
- Nested object access
- Array indexing
- Default values for missing variables
- Comments in templates

#### 2. Conditionals (`/conditionals`)
Master conditional logic:
- Basic if/else statements
- ElseIf chains for multiple conditions
- Boolean expressions and comparisons
- Logical operators (&&, ||)
- Nested conditionals

#### 3. Lists (`/lists`)
Work with collections and iteration:
- Simple list iteration
- Iterating over objects/maps
- Nested list structures
- Empty list handling
- List variables and properties

#### 4. Strings (`/strings`)
String manipulation and formatting:
- Case transformations (upper_case, lower_case, capitalize)
- Trimming and length operations
- String replacement
- Substring operations
- String checking (starts_with, ends_with, contains)

#### 5. Assignments (`/assignments`)
Variable assignments and calculations:
- Basic variable assignment
- String concatenation
- Arithmetic operations
- Running totals in loops
- Conditional assignments
- Creating lists and maps inline

#### 6. Macros (`/macros`)
Create reusable template components:
- Defining macros with parameters
- Calling macros
- Macros with complex content
- Nested macro calls
- Using macros within lists

#### 7. Hello World (`/helloworld`)
A complete introduction to VeeMarker featuring:
- Simple variable interpolation
- Conditionals and list iteration
- Built-in functions
- Nested objects and arrays
- Template file rendering

### Template Examples by Category

#### 01. Basics
- **expressions**: Mathematical expressions, boolean logic, string operations
- **variables**: Variable interpolation, nested objects, array access

#### 02. Control Flow
- **elseif-chains**: Complex conditional logic with multiple elseif blocks
- **if-else**: Basic conditionals, boolean expressions, nested conditions
- **list-basic**: List iteration, loop variables, nested lists

#### 03. Strings
- **basic-functions**: String manipulation methods (upper_case, lower_case, trim, etc.)
- **string-operations**: Advanced string operations (contains, starts_with, replace, etc.)

#### 04. Collections
- **arrays**: Array operations, indexing, nested arrays, array methods
- **maps**: Map/hash operations, nested objects, property access

#### 05. Templates
- **header**: Reusable header component with navigation
- **footer**: Reusable footer component
- **sidebar**: Sidebar component with dynamic content
- **includes**: Template inclusion and composition

#### 06. Text Formats
- **comments**: Template comments and documentation
- **noparse**: Raw text blocks without template processing

#### 07. Operators
- **nullcheck**: Null-safe operations and default values

#### 08. Error Handling
- **attempt_recover**: Error handling with attempt/recover blocks
- **attempt_success**: Successful operations within attempt blocks

## Advanced Feature Examples

### String Methods
Comprehensive examples for string manipulation:
- `capitalize` - Capitalize first letter of each word
- `substring` - Extract substrings with start/end positions
- `upper_case`, `lower_case` - Case conversion
- `trim` - Remove whitespace
- `length` - String length
- `starts_with`, `ends_with` - String prefix/suffix checking
- `contains` - Substring search
- `replace` - String replacement

### Sequence Methods
Advanced collection operations:
- `min`, `max` - Find minimum/maximum values
- `seq_contains` - Check if sequence contains value
- `first`, `last` - Get first/last elements
- `size`, `length` - Get collection size

### List Directives
Enhanced list processing:
- `<#sep>` - Separator blocks between list items
- `<#else>` - Fallback content for empty lists
- Combined separator and else blocks

### Switch/Case Statements
Multi-way conditional branching:
- String and numeric case matching
- Default case handling
- Nested switch statements
- Variable interpolation within cases
- Boolean value switching

## Template File Extension

VeeMarker uses `.vtpl` (V Template) as the standard file extension for template files.

## Running Examples

Each example is self-contained and can be run independently. This assumes the veemarker sources are cloned in a directory called /repos/veemarker in your homedirectory. Change this to match your repo location.

```bash
# Navigate to any example directory
cd examples/variables
VMODULES=~/repos v run main.v

# Or for any other example
cd examples/conditionals
VMODULES=~/repos v run main.v
```

## Test Suite

The `test-suite/` directory contains comprehensive test infrastructure for VeeMarker development and validation. This includes:
- Complex test runner (`test_runner.v`)
- Individual test files for specific features
- Template test cases organized by category (01-08 directories)

To run the test suite:

```bash
cd examples/test-suite
VMODULES=~/repos v run test_runner.v

# Or run individual tests
VMODULES=~/repos v run test_string_methods.v
VMODULES=~/repos v run test_macro.v
# etc...
```

## Test Coverage

All examples are validated through automated testing:
- **19/19 examples passing** (100% success rate)
- Comprehensive sample data for all template variables
- Error handling and edge case coverage
- FreeMarker compatibility validation

## Template Syntax Reference

### Basic Syntax
- **Interpolation**: `${variable}` or `${expression}`
- **Conditionals**: `<#if condition>...<#elseif condition>...<#else>...</#if>`
- **Lists**: `<#list items as item>...${item}...<#sep>separator<#else>empty</#list>`
- **Assignment**: `<#assign var = value>`
- **Comments**: `<#-- comment -->`
- **Includes**: `<#include "template.vtpl">`

### Advanced Features
- **Switch/Case**: `<#switch value><#case "option">...<#default>...</#switch>`
- **Error Handling**: `<#attempt>...<#recover>...</#attempt>`
- **Macros**: `<#macro name params>...</#macro>` and `<@name param="value"/>`
- **Built-in Methods**: String, sequence, and collection operations

### Built-in Functions
- **String**: `?upper_case`, `?lower_case`, `?capitalize`, `?trim`, `?substring(start, end)`
- **Sequence**: `?size`, `?first`, `?last`, `?min`, `?max`, `?seq_contains(value)`
- **Boolean**: `?then(true_val, false_val)`, `?c` (canonical form)
- **Null-safe**: `?has_content`, `??` (exists check)

## Creating New Examples

When creating new examples:
1. Add template files to appropriate numbered directories (01-08)
2. Update the test runner with sample data for new variables
3. Test templates using the comprehensive test runner
4. Ensure FreeMarker compatibility
5. Document any new features or syntax

For complete VeeMarker documentation, see the main project README and visit the FreeMarker documentation for syntax reference.