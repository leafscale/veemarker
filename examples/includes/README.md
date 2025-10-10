# VeeMarker Includes Example

This example demonstrates template inclusion and composition in VeeMarker templates.

## Features Covered

- Using `<#include>` directive to include other templates
- Creating reusable template components (header, footer)
- Passing context to included templates
- Building modular template structures
- Template composition patterns

## Running the Example

```bash
cd includes
VMODULES=~/repos v run main.v
```

## Files

- `main.v` - V code that sets up data and renders the main template
- `template.vtpl` - Main template that includes other templates
- `header.vtpl` - Reusable header component
- `footer.vtpl` - Reusable footer component
- `README.md` - This file

## Key Concepts

### Basic Include
```vtpl
<#include "header.vtpl">
```

### Include with Context
Included templates have access to all variables in the current context.

### Template Organization
- Keep reusable components in separate files
- Use includes to compose complex layouts
- Maintain consistent naming conventions

## Example Data

The example uses:
- Page metadata (title, site name)
- Navigation items for header
- Copyright information for footer
- Main content sections

## Use Cases

- **Page Layouts**: Create consistent page structures
- **Component Reuse**: Share headers, footers, sidebars
- **Template Modularity**: Break complex templates into manageable parts
- **Maintainability**: Update shared components in one place