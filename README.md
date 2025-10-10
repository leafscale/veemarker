# VeeMarker

A FreeMarker-inspired template engine for the V programming language.

## Overview

VeeMarker brings powerful templating capabilities to V applications, enabling separation of presentation logic from business logic. It's designed for rendering HTML, configuration files, emails, or any text-based format with dynamic content.

## Features

- **FreeMarker-compatible syntax** - Familiar syntax for Java/FreeMarker developers
- **Expression evaluation** - Full support for arithmetic, comparison, and logical operators
- **Built-in functions** - String manipulation, collection operations, and more
- **Control structures** - Conditionals (`<#if>`), loops (`<#list>`), and variable assignment (`<#assign>`)
- **NoParse directive** - `<#noparse>` for preserving literal content (JavaScript, examples, etc.)
- **Hierarchical contexts** - Proper variable scoping in nested blocks
- **Template caching** - Automatic caching with hot-reload support in development
- **Error handling** - Clear error messages with line numbers

## Quick Start

### Installation

1. Clone the repository to your project:
```bash
git clone https://github.com/yourusername/veemarker.git
```

2. Or add to your `v.mod`:
```v
Module {
    dependencies: ['veemarker']
}
```

### Basic Usage

```v
import veemarker

fn main() {
    // Create template engine
    mut engine := veemarker.new_engine(veemarker.EngineConfig{
        template_dir: './templates'
        dev_mode: true  // Enable hot-reload
    })

    // Prepare data
    mut data := map[string]veemarker.Any{}
    data['name'] = 'Alice'
    data['items'] = [veemarker.Any('apple'), veemarker.Any('banana')]

    // Render template string
    template := 'Hello, ${name}! You have ${items?size} items.'
    result := engine.render_string(template, data) or {
        eprintln('Template error: ${err}')
        return
    }

    println(result) // Output: Hello, Alice! You have 2 items.
}
```

### Template Example

Create a file `templates/welcome.html`:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome ${user.name}</title>
</head>
<body>
    <h1>Hello, ${user.name}!</h1>

    <#if user.isAdmin>
        <p>Welcome, administrator!</p>
    <#else>
        <p>Welcome, user!</p>
    </#if>

    <h2>Your Items:</h2>
    <ul>
        <#list items as item>
            <li>${item_index + 1}. ${item?cap_first}</li>
        </#list>
    </ul>
</body>
</html>
```

Render the template file:
```v
result := engine.render('welcome.html', data) or {
    eprintln('Error: ${err}')
    return
}
```

## Template Syntax

### Interpolations
- `${variable}` - Output variable value
- `${user.name}` - Access object properties
- `${items[0]}` - Array/map access
- `${name?upper_case}` - Built-in functions

### Directives
- `<#if condition>...</#if>` - Conditional rendering
- `<#list items as item>...</#list>` - Iteration
- `<#assign name = value>` - Variable assignment
- `<#assign name>...content...</#assign>` - Multi-line template assignment
- `<#noparse>...</#noparse>` - Preserve literal content without processing
- `<#-- comment -->` - Comments (no output)

### Operators
- Arithmetic: `+`, `-`, `*`, `/`, `%`
- Comparison: `==`, `!=`, `<`, `<=`, `>`, `>=`
- Logical: `&&`, `||`, `!`

## Documentation

For comprehensive documentation including all features, configuration options, and advanced usage, see [docs/veemarker.md](docs/veemarker.md).

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## Credits

VeeMarker is inspired by [Apache FreeMarker](https://freemarker.apache.org/) and adapted for the V programming language.