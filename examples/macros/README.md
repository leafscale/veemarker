# VeeMarker Macros Example

This example demonstrates how to define and use macros in VeeMarker templates.

## Features Covered

- Defining macros with `<#macro>`
- Simple macros with parameters
- Calling macros with `<@macroName/>`
- Passing parameters to macros
- Macros with complex content
- Nested macro calls
- Using macros within lists

## Running the Example

```bash
cd macros
VMODULES=~/repos v run main.v
```

## Files

- `main.v` - V code that sets up data for macro demonstrations
- `template.vtpl` - VeeMarker template with macro definitions and usage
- `README.md` - This file

## Key Concepts

### Defining a Macro
```vtpl
<#macro greet name>
Hello, ${name}!
</#macro>
```

### Calling a Macro
```vtpl
<@greet name="World"/>
```

### Macros with Objects
```vtpl
<#macro userCard user>
Name: ${user.name}
Role: ${user.role}
</#macro>

<@userCard user=currentUser/>
```

### Nested Macros
Macros can call other macros and be used within list iterations.

## Example Data

The example uses:
- User objects with name, role, and email
- Product objects with name, price, and stock status
- Site metadata like title and current year

## Benefits of Macros

- **Reusability**: Define once, use multiple times
- **Consistency**: Ensure uniform formatting across templates
- **Maintainability**: Update in one place affects all uses
- **Modularity**: Break complex templates into manageable pieces