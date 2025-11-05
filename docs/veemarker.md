# VeeMarker Comprehensive Usage Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Installation & Setup](#installation--setup)
3. [Basic Concepts](#basic-concepts)
4. [Template Syntax](#template-syntax)
5. [Directives](#directives)
6. [Operators](#operators)
7. [Built-in Functions](#built-in-functions)
8. [Data Types & Variables](#data-types--variables)
9. [Configuration](#configuration)
10. [Advanced Usage](#advanced-usage)
11. [Error Handling](#error-handling)
12. [Best Practices](#best-practices)

## Introduction

VeeMarker is a template engine for V that implements the FreeMarker syntax. It allows you to separate presentation logic from application code, making your V applications more maintainable and flexible.

### Why VeeMarker?

- **Familiar syntax**: If you know FreeMarker, you already know VeeMarker
- **Type-safe**: Leverages V's type system for safer template rendering
- **Performance**: Compiles with your V application for optimal performance
- **Flexibility**: Works with any text format (HTML, XML, JSON, config files, etc.)
- **Standard**: VeeMarker relies only on the V stdlib, no external dependencies

## Installation & Setup

### Method 1: Install from VPM
```
v install leafscale.veemarker
```

### Method 2: Local Directory

Place the veemarker directory in your project:
```
myproject/
├── veemarker/
│   ├── v.mod
│   ├── veemarker.v
│   ├── ast.v
│   ├── context.v
│   ├── evaluator.v
│   ├── lexer.v
│   └── parser.v
├── templates/
│   └── index.vtpl
└── main.v
```

or symlink it within your project directory.

### Method 3: Module Path

Add veemarker to your module path or specify it in your `v.mod`:
```v
Module {
    name: 'myapp'
    description: 'My application'
    version: '1.0.0'
    dependencies: ['leafscale.veemarker']
}
```

### Importing VeeMarker

In your V code:
```v
import leafscale.veemarker

fn main() {
    // Your code here
}
```

## Basic Concepts

### The Any Type

VeeMarker uses a sum type `Any` to handle dynamic template data:
```v
type Any = string | int | f64 | bool | []Any | map[string]Any
```

### Creating Data Maps

Template data is passed as `map[string]Any`:
```v
mut data := map[string]Any{}
data['title'] = 'My Page'
data['year'] = 2024
data['is_active'] = true

// Nested objects
mut user := map[string]Any{}
user['name'] = 'Alice'
user['email'] = 'alice@example.com'
data['user'] = user

// Arrays
data['items'] = [
    veemarker.Any('apple'),
    veemarker.Any('banana'),
    veemarker.Any('orange')
]
```

### Engine Configuration

```v
mut engine := veemarker.new_engine(veemarker.EngineConfig{
    template_dir: './templates'    // Where to look for template files
    cache_enabled: true            // Enable template caching
    dev_mode: false               // Production mode
    auto_reload: true             // Check for template changes
})
```

## Template Syntax

### Interpolations (Output)

Interpolations output the value of an expression:

```freemarker
${variable}                    <!-- Simple variable -->
${user.name}                   <!-- Property access -->
${items[0]}                    <!-- Array access -->
${user["email"]}               <!-- Map access with string key -->
${name!"default"}              <!-- Default value if null -->
${price * quantity}            <!-- Expression -->
${name?upper_case}             <!-- Built-in function -->
${items?size}                  <!-- Collection size -->
```

### Comments

Comments are not included in the output:
```freemarker
<#-- This is a comment -->
<#--
    Multi-line
    comment
-->
```

## Directives

### If/ElseIf/Else

Conditional rendering based on expressions:

```freemarker
<#if user.age >= 18>
    <p>Welcome, adult user!</p>
<#elseif user.age >= 65>
    <p>Welcome, senior citizen!</p>
<#else>
    <p>You must be at least 18 to accept the legal agreement for this service.</p>
</#if>

<#-- Testing boolean values -->
<#if user.isAdmin>
    <div class="admin-panel">...</div>
</#if>

<#-- Testing for existence -->
<#if user.nickname?has_content>
    <p>Nickname: ${user.nickname}</p>
</#if>
```

### List (Iteration)

Iterate over collections:

```freemarker
<#-- Array iteration -->
<ul>
<#list items as item>
    <li>${item}</li>
</#list>
</ul>

<#-- With index -->
<#list items as item>
    <li>${item_index}: ${item}</li>
</#list>

<#-- Loop variables -->
<#list users as user>
    <div class="user">
        <span>User #${user_index + 1}</span>
        <span>${user.name}</span>
        <#if user_has_next>, </#if>
    </div>
</#list>

<#-- Map iteration -->
<#list userMap as entry>
    <p>${entry.key}: ${entry.value}</p>
</#list>
```

Available loop variables:
- `item_index` - Zero-based index
- `item_has_next` - Boolean indicating if there are more items

### Assign

Create or update variables in the template:

```freemarker
<#assign name = "John Doe">
<#assign price = 19.99>
<#assign total = price * quantity>

<#-- Complex assignments -->
<#assign fullName = user.firstName + " " + user.lastName>
<#assign isExpensive = price > 100>

<#-- Multi-line template assignment -->
<#assign complexHtml>
    <div class="user-card">
        <h3>${user.name}</h3>
        <p>Email: ${user.email}</p>
        <#if user.isActive>
            <span class="status active">Active</span>
        <#else>
            <span class="status inactive">Inactive</span>
        </#if>
    </div>
</#assign>

<p>Total: ${total}</p>
${complexHtml}
```

#### Multi-line Assign

The `<#assign>` directive supports multi-line template content assignment, which processes the content as a template and stores the rendered result:

```freemarker
<#assign emailTemplate>
Subject: Welcome ${user.name}!

Dear ${user.name},

Thank you for joining our service. Your account details:
- Username: ${user.username}
- Email: ${user.email}
- Member since: ${user.joinDate}

<#if user.isPremium>
As a premium member, you have access to exclusive features!
</#if>

Best regards,
The Team
</#assign>

${emailTemplate}
```

This is particularly useful for generating complex HTML structures, emails, or configuration files within templates.

### NoParse

The `<#noparse>` directive prevents VeeMarker from processing template syntax within its content. Everything between `<#noparse>` and `</#noparse>` is treated as literal text and output exactly as written.

This is especially useful when:
- Embedding JavaScript code that uses template literals with `${...}` syntax
- Including FreeMarker/VeeMarker template examples in documentation
- Preserving any text that might be mistaken for template syntax

```freemarker
<#noparse>
<script>
// JavaScript template literals are preserved
const message = `Hello, ${userName}!`;
const html = `<div class="${isActive ? 'active' : 'inactive'}">
    ${content}
</div>`;

// This would normally be processed as VeeMarker syntax, but is preserved
<#if someCondition>
    This is literal text, not a VeeMarker directive
</#if>
</script>
</#noparse>

<#-- Regular VeeMarker processing resumes here -->
<p>User: ${currentUser.name}</p>
```

**Note**: The noparse directive is particularly important when including JavaScript with ES6 template literals in your templates, as both JavaScript and VeeMarker use the `${...}` syntax for interpolation.

## Operators

### Arithmetic Operators

```freemarker
${a + b}    <!-- Addition -->
${a - b}    <!-- Subtraction -->
${a * b}    <!-- Multiplication -->
${a / b}    <!-- Division -->
${a % b}    <!-- Modulo -->
${-a}       <!-- Negation -->
```

### Comparison Operators

```freemarker
${a == b}   <!-- Equal to -->
${a != b}   <!-- Not equal to -->
${a < b}    <!-- Less than -->
${a <= b}   <!-- Less than or equal -->
${a > b}    <!-- Greater than -->
${a >= b}   <!-- Greater than or equal -->
```

### Logical Operators

```freemarker
${a && b}   <!-- Logical AND -->
${a || b}   <!-- Logical OR -->
${!a}       <!-- Logical NOT -->
```

### String Concatenation

```freemarker
${firstName + " " + lastName}
${"/path/" + filename + ".vtpl"}
```

## Built-in Functions

Built-in functions are called using the `?` operator:

### String Functions

```freemarker
${name?upper_case}           <!-- JOHN DOE -->
${name?lower_case}           <!-- john doe -->
${name?cap_first}            <!-- John doe -->
${text?trim}                 <!-- Remove leading/trailing whitespace -->
${text?length}               <!-- String length -->
${text?has_content}          <!-- True if non-empty -->
${text?starts_with("Hello")} <!-- Check prefix -->
${text?ends_with(".txt")}    <!-- Check suffix -->
${text?contains("search")}   <!-- Check if contains substring -->
${text?replace("old", "new")} <!-- Replace all occurrences -->
${text?split(",")}           <!-- Split into array -->
```

### Collection Functions

```freemarker
${items?size}                <!-- Collection size -->
${items?reverse}             <!-- Reverse array -->
${items?join(", ")}          <!-- Join array elements -->
${items?contains("apple")}   <!-- Check if contains item -->
```

### JavaScript Integration Functions

These functions enable safe server-to-client data passing for JavaScript frameworks like Alpine.js:

```freemarker
${text?html}                 <!-- Escape HTML special characters -->
${text?js_string}            <!-- Escape for JavaScript strings -->
${data?alpine_json}          <!-- Convert to JSON for Alpine.js -->
```

#### HTML Escaping (`?html`)

Safely display user-generated content in HTML by escaping special characters. Prevents XSS attacks.

**Escapes:**
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`
- `"` → `&quot;`
- `'` → `&#39;`

**Usage:**
```freemarker
<div class="comment">
    ${user_comment?html}
</div>

<!-- Prevent XSS attacks -->
<p>Search results for: ${search_query?html}</p>
```

#### JavaScript String Escaping (`?js_string`)

Embed strings safely in JavaScript code by escaping quotes, backslashes, and control characters. Prevents JavaScript injection attacks.

**Escapes:**
- `\` → `\\`
- `'` → `\'`
- `"` → `\"`
- `\n` → `\\n`
- `\r` → `\\r`
- `\t` → `\\t`
- `\0` → `\\0`
- Unicode line separators (U+2028, U+2029)

**Usage:**
```freemarker
<script>
const message = "${alert_message?js_string}";
const userName = "${user.name?js_string}";

// Safe from injection
alert("Welcome, ${user.name?js_string}!");
</script>
```

#### Alpine.js JSON Conversion (`?alpine_json`)

Convert V data structures to JSON format for Alpine.js `x-data` attributes. Handles all VeeMarker `Any` type variants.

**Supported Types:**
- `string` → JSON string (`"value"`)
- `int`, `f64` → Number (`42`, `3.14`)
- `bool` → Boolean (`true`, `false`)
- `map[string]Any` → JSON object (`{"key": "value"}`)
- `[]Any` → JSON array (`[1, 2, 3]`)

**Usage:**
```freemarker
<!-- Pass single object to Alpine.js -->
<div x-data='${product?alpine_json}'>
    <h1 x-text="name"></h1>
    <p>Price: $<span x-text="price"></span></p>
    <button x-show="in_stock">Add to Cart</button>
</div>

<!-- Pass array of objects -->
<div x-data='{ items: ${products?alpine_json} }'>
    <template x-for="item in items" :key="item.id">
        <div x-text="item.name"></div>
    </template>
</div>

<!-- Complex data structure -->
<div x-data='{
    user: ${user?alpine_json},
    items: ${cart_items?alpine_json},
    total: ${cart_total}
}'>
    <p x-text="user.name"></p>
    <p>Items: <span x-text="items.length"></span></p>
</div>
```

**Security Note:** All three functions (`?html`, `?js_string`, `?alpine_json`) are designed to prevent injection attacks. Always use the appropriate escaping function for your context:
- Use `?html` when outputting to HTML content
- Use `?js_string` when embedding in JavaScript string literals
- Use `?alpine_json` when passing data to Alpine.js or other JavaScript frameworks

### Examples

```freemarker
<!-- Chaining functions -->
${name?trim?upper_case}

<!-- In conditionals -->
<#if email?lower_case?ends_with("@admin.com")>
    <span>Admin Email</span>
</#if>

<!-- With default values -->
${username?cap_first!"Anonymous"}
```

## Data Types & Variables

### Passing Data from V

```v
// Simple types
mut data := map[string]veemarker.Any{}
data['name'] = 'John'
data['age'] = 30
data['price'] = 19.99
data['active'] = true

// Arrays
mut items := []veemarker.Any{}
items << veemarker.Any('item1')
items << veemarker.Any('item2')
data['items'] = items

// Nested objects
mut address := map[string]veemarker.Any{}
address['street'] = '123 Main St'
address['city'] = 'Springfield'

mut user := map[string]veemarker.Any{}
user['name'] = 'Alice'
user['address'] = address

data['user'] = user
```

### Accessing in Templates

```freemarker
<!-- Simple variables -->
Name: ${name}
Age: ${age}

<!-- Arrays -->
First item: ${items[0]}
<#list items as item>
    ${item}
</#list>

<!-- Nested objects -->
User: ${user.name}
City: ${user.address.city}

<!-- With defaults -->
${nickname!"No nickname"}
```

## Working with Structs

VeeMarker's `Any` type system works with maps and primitives, not arbitrary V structs. To use structs in templates, convert them using the provided helper functions.

### Why Convert Structs?

VeeMarker's `Any` type only supports:
```v
type Any = string | int | f64 | bool | []Any | map[string]Any
```

This design follows standard template engine patterns (Jinja2, Liquid, Handlebars) where templates work with **data** (maps/dictionaries), not **objects** (class instances).

### Helper Functions

#### `to_map[T](obj T) Any`

Converts a single struct to `map[string]Any` using compile-time reflection.

**Example:**
```v
struct Customer {
    id    int
    name  string
    email string
}

customer := Customer{id: 1, name: 'Alice', email: 'alice@example.com'}

// Convert struct to map
data := {
    'customer': veemarker.to_map(customer)
}

template := 'Customer: ${customer.name} (${customer.email})'
mut engine := veemarker.new_engine(veemarker.EngineConfig{})
result := engine.render_string(template, data)!
```

**Supported Field Types:**
- Primitives: `string`, `int`, `f64`, `bool`
- Arrays: `[]string`, `[]int`, `[]f64`, `[]bool` (converted to `[]Any`)

**Unsupported Types:**
Fields with unsupported types (nested structs, maps, custom types) are converted to empty strings. For complex hierarchies, convert nested structures manually.

#### `to_map_array[T](objects []T) Any`

Converts an array of structs to `[]Any` where each element is a `map[string]Any`.

**Example:**
```v
customers := [
    Customer{id: 1, name: 'Alice', email: 'alice@example.com'},
    Customer{id: 2, name: 'Bob', email: 'bob@example.com'},
    Customer{id: 3, name: 'Charlie', email: 'charlie@example.com'},
]

data := {
    'customers': veemarker.to_map_array(customers)
}

template := '<#list customers as c>
- ${c.name}: ${c.email}
</#list>'

result := engine.render_string(template, data)!
```

### Common Patterns

#### Pattern 1: Detail Page (Single Object)

```v
struct Product {
    id          int
    name        string
    price       f64
    description string
    tags        []string
}

product := get_product_by_id(123)

data := {
    'product': veemarker.to_map(product)
}

engine.render('product/detail.vtpl', data)!
```

Template (`product/detail.vtpl`):
```html
<div class="product">
    <h1>${product.name}</h1>
    <p>Price: $${product.price}</p>
    <p>${product.description}</p>
    <div class="tags">
        <#list product.tags as tag>
            <span class="tag">${tag}</span>
        </#list>
    </div>
</div>
```

#### Pattern 2: List/Table (Multiple Objects)

```v
struct Order {
    id     int
    date   string
    total  f64
    status string
}

orders := get_user_orders(user_id)

data := {
    'orders': veemarker.to_map_array(orders)
}

engine.render('orders/list.vtpl', data)!
```

Template (`orders/list.vtpl`):
```html
<table>
    <thead>
        <tr>
            <th>Order ID</th>
            <th>Date</th>
            <th>Total</th>
            <th>Status</th>
        </tr>
    </thead>
    <tbody>
    <#list orders as order>
        <tr>
            <td>${order.id}</td>
            <td>${order.date}</td>
            <td>$${order.total}</td>
            <td>${order.status}</td>
        </tr>
    </#list>
    </tbody>
</table>
```

#### Pattern 3: Mixed Data Types

Combining structs with other data types:

```v
struct User {
    name  string
    email string
    role  string
}

user := get_current_user()

data := {
    'user':         veemarker.to_map(user)
    'page_title':   veemarker.Any('Dashboard')
    'is_admin':     veemarker.Any(user.role == 'admin')
    'notification_count': veemarker.Any(get_notification_count())
}

engine.render('dashboard.vtpl', data)!
```

#### Pattern 4: Nested Structures

When structs contain other structs, convert them manually:

```v
struct Address {
    street  string
    city    string
    zipcode string
}

struct Customer {
    name    string
    email   string
    address Address
}

customer := get_customer()

// Manual conversion for nested struct
data := {
    'customer': map[string]veemarker.Any{
        'name':  veemarker.Any(customer.name)
        'email': veemarker.Any(customer.email)
        'address': map[string]veemarker.Any{
            'street':  veemarker.Any(customer.address.street)
            'city':    veemarker.Any(customer.address.city)
            'zipcode': veemarker.Any(customer.address.zipcode)
        }
    }
}
```

Template:
```html
<div class="customer">
    <h2>${customer.name}</h2>
    <p>Email: ${customer.email}</p>
    <address>
        ${customer.address.street}<br>
        ${customer.address.city}, ${customer.address.zipcode}
    </address>
</div>
```

### Web Framework Integration

#### Example with Varel Framework

```v
pub fn (mut c CustomerController) index(mut ctx varel.Context) varel.Response {
    // Get customers from database
    customers := models.all_customers(mut c.db) or {
        return ctx.internal_error('Failed to load customers')
    }

    // Convert structs to template-compatible format
    return ctx.render_data('customer/index', {
        'customers': veemarker.to_map_array(customers)
        'title':     veemarker.Any('Customer List')
    })
}
```

Template (`customer/index.vtpl`):
```html
<!DOCTYPE html>
<html>
<head>
    <title>${title}</title>
</head>
<body>
    <h1>${title}</h1>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
            </tr>
        </thead>
        <tbody>
        <#list customers as customer>
            <tr>
                <td>${customer.id}</td>
                <td>${customer.name}</td>
                <td>${customer.email}</td>
            </tr>
        </#list>
        </tbody>
    </table>
</body>
</html>
```

### Performance Considerations

**Conversion Cost:**
- Uses compile-time reflection (`$for field in T.fields`)
- V generates specialized code for each struct type
- **No runtime reflection overhead**
- Conversion happens once before rendering

**Best Practice:**
```v
// Good: Convert once, use multiple times
customers := get_customers()
customers_any := veemarker.to_map_array(customers)

data := {'customers': customers_any}
engine.render(template1, data)!
engine.render(template2, data)!

// Avoid: Converting in loops
for customer in customers {
    // Don't convert repeatedly
    data := {'customer': veemarker.to_map(customer)}
    engine.render(template, data)!  // Wasteful
}
```

### Troubleshooting

**Error: Segmentation Fault**

**Cause:** Passing raw struct directly to template

```v
// ❌ WRONG - Causes segfault
struct Customer { name string }
customer := Customer{name: 'Alice'}
data := {'customer': veemarker.Any(customer)}  // Invalid!

// ✓ CORRECT - Use conversion helper
data := {'customer': veemarker.to_map(customer)}
```

**Error: Variable Not Found**

**Cause:** Forgot to convert struct

```v
// ❌ WRONG
data := {'customer': customer}  // Raw struct

// ✓ CORRECT
data := {'customer': veemarker.to_map(customer)}
```

**Error: Empty Field Values**

**Cause:** Field type not supported by `to_map()`

**Solution:** Check supported types or convert manually:

```v
struct ComplexData {
    id      int
    details map[string]string  // Not auto-converted
}

obj := ComplexData{...}

// Manual conversion for complex fields
mut data_map := veemarker.to_map(obj)
if mut dm := data_map {
    if mut m := dm as map[string]veemarker.Any {
        mut details_any := map[string]veemarker.Any{}
        for key, val in obj.details {
            details_any[key] = veemarker.Any(val)
        }
        m['details'] = veemarker.Any(details_any)
    }
}
```

### Examples

See `examples/structs/` for a complete working example and `test_struct_helpers.v` for test cases.

Run the test:
```bash
v run .
```

For more details, see `STRUCT_USAGE.md` in the project root.

## Configuration

### Template Directory Structure (example)

You can render templates anywhere, this is an example layout of how a website might organize templates.

```
project/
├── templates/
│   ├── layouts/
│   │   └── main.vtpl
│   ├── partials/
│   │   ├── header.vtpl
│   │   └── footer.vtpl
│   └── pages/
│       ├── index.vtpl
│       └── about.vtpl
└── main.v
```

### Loading Templates

```v
// From template directory
result := engine.render('pages/index.vtpl', data)!

// From string
template_str := 'Hello ${name}!'
result := engine.render_string(template_str, data)!
```

### Development vs Production

```v
// Development configuration
mut dev_engine := veemarker.new_engine(veemarker.EngineConfig{
    template_dir: './templates'
    cache_enabled: false      // Disable caching
    dev_mode: true           // Enable dev mode
    auto_reload: true        // Auto-reload templates
})

// Production configuration
mut prod_engine := veemarker.new_engine(veemarker.EngineConfig{
    template_dir: './templates'
    cache_enabled: true      // Enable caching
    dev_mode: false         // Disable dev mode
    auto_reload: false      // No auto-reload
})
```

## Advanced Usage

### Complex Data Structures

```v
// Building a product catalog
mut products := []veemarker.Any{}

for product in db_products {
    mut p := map[string]veemarker.Any{}
    p['id'] = product.id
    p['name'] = product.name
    p['price'] = product.price

    // Add categories
    mut categories := []veemarker.Any{}
    for cat in product.categories {
        categories << veemarker.Any(cat.name)
    }
    p['categories'] = categories

    products << p
}

data['products'] = products
```

Template:
```freemarker
<#list products as product>
    <div class="product">
        <h3>${product.name}</h3>
        <p>Price: $${product.price}</p>
        <p>Categories: ${product.categories?join(", ")}</p>
    </div>
</#list>
```

### Conditional Rendering with Complex Logic

```freemarker
<#assign discount = 0>
<#if user.membership == "gold">
    <#assign discount = 20>
<#elseif user.membership == "silver">
    <#assign discount = 10>
</#if>

<#if discount > 0>
    <p>You get ${discount}% off!</p>
    <#assign finalPrice = price * (100 - discount) / 100>
    <p>Final price: $${finalPrice}</p>
</#if>
```

### Working with Dates and Times

```v
// In V code
import time

mut data := map[string]veemarker.Any{}
data['current_year'] = time.now().year
data['timestamp'] = time.now().format_ss()
```

Template:
```freemarker
<footer>
    © ${current_year} My Company
    <br>
    Last updated: ${timestamp}
</footer>
```

## Error Handling

### In V Code

```v
// Handle template errors
result := engine.render('template.vtpl', data) or {
    eprintln('Template error: ${err}')

    // Return a fallback response
    return 'An error occurred while rendering the page'
}

// Check if template exists
if !os.exists(os.join_path(engine.template_dir, 'template.vtpl')) {
    eprintln('Template not found')
    return
}
```

### Common Errors

1. **Variable not found**: When accessing undefined variables
   ```freemarker
   ${unknown_var!"default"}  <!-- Use default to avoid error -->
   ```

2. **Type mismatch**: When operations expect different types
   ```freemarker
   <#if items?has_content && items?size > 0>
       <!-- Safe to iterate -->
   </#if>
   ```

3. **Invalid syntax**: Malformed directives or expressions
   - Always close directives: `<#if>...</#if>`
   - Match quote types in strings
   - Balance parentheses in expressions

## Best Practices

### 1. Use Meaningful Variable Names

```v
// Good
data['user_profile'] = user_data
data['navigation_items'] = nav_items

// Avoid
data['u'] = user_data
data['nav'] = nav_items
```

### 2. Provide Defaults

```freemarker
<!-- Always provide defaults for optional values -->
Welcome, ${user.nickname!"Guest"}!

<!-- Check existence before accessing -->
<#if user.preferences?has_content>
    Theme: ${user.preferences.theme}
</#if>
```

### 3. Keep Templates Simple

```freemarker
<!-- Good: Logic in V, presentation in template -->
<#if show_admin_panel>
    <#include "admin_panel.vtpl">
</#if>

<!-- Avoid: Complex logic in templates -->
<#if user.role == "admin" && user.active && user.last_login > some_date>
    <!-- Too complex -->
</#if>
```

### 4. Organize Templates

```
templates/
├── layouts/          <!-- Page layouts -->
├── components/       <!-- Reusable components -->
├── pages/           <!-- Full pages -->
└── emails/          <!-- Email templates -->
```

### 5. Handle Errors Gracefully

```v
// Always handle template errors
html := engine.render(template_name, data) or {
    // Log the error
    log_error('Template error: ${err}')

    // Show user-friendly message
    return render_error_page(500, 'Internal Server Error')
}
```

### 6. Cache in Production

```v
// Use caching for better performance
if is_production {
    engine.cache_enabled = true
    engine.auto_reload = false
}
```

### 7. Validate Input Data

```v
// Validate and sanitize before passing to templates
fn prepare_user_data(user User) map[string]veemarker.Any {
    mut data := map[string]veemarker.Any{}

    // Sanitize HTML
    data['name'] = html.escape(user.name)
    data['bio'] = html.escape(user.bio)

    // Validate data
    if user.age >= 0 && user.age <= 150 {
        data['age'] = user.age
    }

    return data
}
```

## Complete Example

Here's a complete example showing VeeMarker in a veb application:

```v
// main.v
import leafscale.veemarker as veemarker
import veb

struct App {
    veb.Context
mut:
    template_engine veemarker.Engine
}

fn main() {
    mut app := &App{
        template_engine: veemarker.new_engine(veemarker.EngineConfig{
            template_dir: './templates'
            dev_mode: true
        })
    }
    veb.run(app, 8080)
}

['/']
pub fn (mut app App) index() veb.Result {
    // Prepare data
    mut data := map[string]veemarker.Any{}
    data['title'] = 'Welcome to VeeMarker'

    // User data
    mut user := map[string]veemarker.Any{}
    user['name'] = 'John Doe'
    user['is_admin'] = false
    data['user'] = user

    // Navigation items
    mut nav_items := []veemarker.Any{}
    nav_items << create_nav_item('Home', '/', true)
    nav_items << create_nav_item('About', '/about', false)
    nav_items << create_nav_item('Contact', '/contact', false)
    data['nav_items'] = nav_items

    // Products
    data['products'] = get_products()

    // Render template
    html := app.template_engine.render('index.vtpl', data) or {
        return app.server_error(500)
    }

    return app.vtpl(html)
}

fn create_nav_item(label string, href string, active bool) veemarker.Any {
    mut item := map[string]veemarker.Any{}
    item['label'] = label
    item['href'] = href
    item['active'] = active
    return item
}

fn get_products() []veemarker.Any {
    mut products := []veemarker.Any{}

    // Sample products
    products << create_product('Laptop', 999.99, true)
    products << create_product('Mouse', 29.99, true)
    products << create_product('Keyboard', 79.99, false)

    return products
}

fn create_product(name string, price f64, in_stock bool) veemarker.Any {
    mut product := map[string]veemarker.Any{}
    product['name'] = name
    product['price'] = price
    product['in_stock'] = in_stock
    return product
}
```

Template file (`templates/index.vtpl`):
```html
<!DOCTYPE html>
<html>
<head>
    <title>${title}</title>
    <style>
        .active { font-weight: bold; }
        .out-of-stock { opacity: 0.5; }
    </style>
</head>
<body>
    <nav>
        <ul>
        <#list nav_items as item>
            <li>
                <a href="${item.href}"
                   <#if item.active>class="active"</#if>>
                    ${item.label}
                </a>
            </li>
        </#list>
        </ul>
    </nav>

    <header>
        <h1>${title}</h1>
        <#if user.is_admin>
            <a href="/admin">Admin Panel</a>
        </#if>
        <p>Welcome, ${user.name!"Guest"}!</p>
    </header>

    <main>
        <h2>Products</h2>
        <div class="products">
        <#list products as product>
            <div class="product <#if !product.in_stock>out-of-stock</#if>">
                <h3>${product.name}</h3>
                <p>$${product.price}</p>
                <#if product.in_stock>
                    <button>Add to Cart</button>
                <#else>
                    <p>Out of Stock</p>
                </#if>
            </div>
        </#list>
        </div>

        <#-- Calculate and show total -->
        <#assign total = 0>
        <#list products as product>
            <#if product.in_stock>
                <#assign total = total + product.price>
            </#if>
        </#list>
        <p>Total value of in-stock items: $${total}</p>
    </main>

    <footer>
        <p>&copy; 2024 VeeMarker Demo</p>
    </footer>
</body>
</html>
```

This comprehensive guide covers all aspects of using VeeMarker in your V projects. The template engine provides a powerful, flexible way to separate your presentation logic from your application code while maintaining type safety and performance.