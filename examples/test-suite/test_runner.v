module main

import veemarker
import os

fn main() {
	println('VeeMarker Test Runner')
	println('====================\n')

	// Change to examples directory to ensure correct paths
	examples_dir := os.dir(os.executable())
	os.chdir(examples_dir) or {
		eprintln('Failed to change to examples directory: ${err}')
		exit(1)
	}

	// Initialize VeeMarker engine with examples as template directory
	mut engine := veemarker.new_engine(veemarker.EngineConfig{
		template_dir: '.'
	})

	// Discover and test all examples
	mut total_tests := 0
	mut passed_tests := 0

	// Test existing numbered directories
	for i in 1..10 {
		dir_name := '${i:02d}-*'
		dirs := os.glob(dir_name) or { continue }

		for dir in dirs {
			if !os.is_dir(dir) { continue }

			// Find all .vtpl files in this directory
			templates := os.glob('${dir}/*.vtpl') or { continue }

			for template_path in templates {
				template_name := os.file_name(template_path).replace('.vtpl', '')

				total_tests++
				println('Testing ${dir}/${template_name}...')

				if test_example(mut engine, dir, template_name) {
					passed_tests++
					println('  ✓ PASSED')
				} else {
					println('  ✗ FAILED')
				}
				println('')
			}
		}
	}

	// Test special directories like helloworld
	special_dirs := ['helloworld']
	for dir in special_dirs {
		if !os.is_dir(dir) { continue }

		// Check if it has its own main.v
		if os.exists('${dir}/main.v') {
			total_tests++
			println('Testing standalone example: ${dir}...')

			if test_standalone_example(dir) {
				passed_tests++
				println('  ✓ PASSED')
			} else {
				println('  ✗ FAILED')
			}
			println('')
		}
	}

	// Summary
	println('====================')
	println('Test Results: ${passed_tests}/${total_tests} passed')
	if passed_tests == total_tests {
		println('All tests passed! ✓')
	} else {
		println('Some tests failed! ✗')
		exit(1)
	}
}

fn test_example(mut engine veemarker.Engine, folder string, name string) bool {
	// Read template
	template_path := '${folder}/${name}.vtpl'
	template_content := os.read_file(template_path) or {
		eprintln('  Error: Failed to read template: ${template_path}')
		return false
	}

	// Try to read data file - check multiple possible names
	data_paths := [
		'${folder}/data_${name}.json',
		'${folder}/${name}-data.json',
		'${folder}/${name}.json'
	]

	mut context := map[string]veemarker.Any{}
	mut found_data := false

	for data_path in data_paths {
		if os.exists(data_path) {
			data_content := os.read_file(data_path) or {
				eprintln('  Error: Failed to read data file: ${data_path}')
				continue
			}

			// Parse JSON data (simple parsing for common cases)
			context = parse_simple_json(data_content) or {
				eprintln('  Warning: Could not parse JSON data from ${data_path}, using sample data')
				context = get_sample_data(name)
				break
			}
			found_data = true
			break
		}
	}

	if !found_data {
		// Use sample data based on example name
		context = get_sample_data(name)
	}

	// Render template
	result := engine.render_string(template_content, context) or {
		eprintln('  Error: Failed to render template: ${err}')
		return false
	}

	// Show output preview
	println('  Output preview (first 200 chars):')
	preview := if result.len > 200 { result[..200] + '...' } else { result }
	println('  ${preview}')

	// Check if expected output exists
	expected_paths := [
		'${folder}/${name}-expected.txt',
		'${folder}/expected_${name}.txt'
	]

	for expected_path in expected_paths {
		if os.exists(expected_path) {
			expected := os.read_file(expected_path) or {
				eprintln('  Warning: Failed to read expected output: ${expected_path}')
				continue
			}

			if result.trim_space() == expected.trim_space() {
				println('  ✓ Output matches expected result')
				return true
			} else {
				println('  ✗ Output does not match expected result')
				println('  Expected length: ${expected.len}, Got length: ${result.len}')
				return false
			}
		}
	}

	// If no expected output file, consider it passed if it rendered without error
	println('  ✓ Template rendered successfully (no expected output to compare)')
	return true
}

fn test_standalone_example(dir string) bool {
	// Change to example directory and run its main.v
	original_dir := os.getwd()
	os.chdir(dir) or {
		eprintln('  Error: Failed to change to directory: ${dir}')
		return false
	}

	defer {
		os.chdir(original_dir) or {}
	}

	// Run the example
	result := os.execute('VMODULES=~/repos v run main.v')

	if result.exit_code == 0 {
		println('  Output:')
		println('  ${result.output}')
		return true
	} else {
		eprintln('  Error: Example failed with exit code ${result.exit_code}')
		eprintln('  Output: ${result.output}')
		return false
	}
}

fn get_sample_data(name string) map[string]veemarker.Any {
	mut context := map[string]veemarker.Any{}

	match name {
		'variables' {
			context['name'] = veemarker.Any('Alice')
			context['greeting'] = veemarker.Any('Welcome')
			context['price'] = veemarker.Any(19.99)
			context['quantity'] = veemarker.Any(3)

			mut user := map[string]veemarker.Any{}
			user['name'] = veemarker.Any('Alice Johnson')
			user['email'] = veemarker.Any('alice@example.com')
			user['age'] = veemarker.Any(25)
			user['status'] = veemarker.Any('active')

			mut address := map[string]veemarker.Any{}
			address['street'] = veemarker.Any('123 Main Street')
			address['city'] = veemarker.Any('San Francisco')
			address['state'] = veemarker.Any('CA')
			address['zip'] = veemarker.Any('94102')
			user['address'] = veemarker.Any(address)

			context['user'] = veemarker.Any(user)

			hobbies := [veemarker.Any('reading'), veemarker.Any('hiking'), veemarker.Any('photography')]
			context['hobbies'] = veemarker.Any(hobbies)
			context['optional'] = veemarker.Any('This field exists')
			context['empty'] = veemarker.Any('')
		}
		'expressions' {
			context['price'] = veemarker.Any(29.99)
			context['quantity'] = veemarker.Any(7)

			mut user := map[string]veemarker.Any{}
			user['isPremium'] = veemarker.Any(true)
			user['hasSubscription'] = veemarker.Any(true)
			context['user'] = veemarker.Any(user)

			context['firstName'] = veemarker.Any('John')
			context['lastName'] = veemarker.Any('Doe')
		}
		'elseif-chains' {
			context['score'] = veemarker.Any(85)
			context['age'] = veemarker.Any(25)
			context['hour'] = veemarker.Any(14)
			context['priority'] = veemarker.Any('high')
			context['statusCode'] = veemarker.Any(200)

			mut user := map[string]veemarker.Any{}
			user['active'] = veemarker.Any(true)
			user['verified'] = veemarker.Any(true)
			user['subscription'] = veemarker.Any('active')
			user['credits'] = veemarker.Any(100)
			user['name'] = veemarker.Any('John Doe')
			context['user'] = veemarker.Any(user)
		}
		'if-else' {
			// User object
			mut user := map[string]veemarker.Any{}
			user['active'] = veemarker.Any(true)
			user['name'] = veemarker.Any('John Doe')
			context['user'] = veemarker.Any(user)

			// Basic variables
			context['score'] = veemarker.Any(85)
			context['age'] = veemarker.Any(25)
			context['hasLicense'] = veemarker.Any(true)
			context['isLoggedIn'] = veemarker.Any(true)
			context['hasPermission'] = veemarker.Any(true)
			context['count'] = veemarker.Any(5)
			context['status'] = veemarker.Any('active')
			context['error'] = veemarker.Any('')
			context['temperature'] = veemarker.Any(75)
			context['humidity'] = veemarker.Any(60)
			context['isOnline'] = veemarker.Any(true)
			context['isPremium'] = veemarker.Any(true)
			context['debugMode'] = veemarker.Any(true)
			context['verbose'] = veemarker.Any(false)
		}
		'list-basic' {
			// Items for simple list
			items := [veemarker.Any('Laptop'), veemarker.Any('Mouse'), veemarker.Any('Keyboard')]
			context['items'] = veemarker.Any(items)

			// Movies list
			movies := [veemarker.Any('The Matrix'), veemarker.Any('Inception'), veemarker.Any('Interstellar')]
			context['movies'] = veemarker.Any(movies)

			// Users list with objects
			mut users := []veemarker.Any{}
			mut user1 := map[string]veemarker.Any{}
			user1['name'] = veemarker.Any('John Doe')
			user1['email'] = veemarker.Any('john@example.com')
			user1['role'] = veemarker.Any('Admin')
			users << veemarker.Any(user1)

			mut user2 := map[string]veemarker.Any{}
			user2['name'] = veemarker.Any('Jane Smith')
			user2['email'] = veemarker.Any('jane@example.com')
			user2['role'] = veemarker.Any('Editor')
			users << veemarker.Any(user2)

			context['users'] = veemarker.Any(users)

			// Products list
			mut products := []veemarker.Any{}
			mut product1 := map[string]veemarker.Any{}
			product1['name'] = veemarker.Any('Laptop')
			product1['price'] = veemarker.Any(999.99)
			product1['description'] = veemarker.Any('High-performance laptop')
			product1['inStock'] = veemarker.Any(true)
			products << veemarker.Any(product1)

			mut product2 := map[string]veemarker.Any{}
			product2['name'] = veemarker.Any('Mouse')
			product2['price'] = veemarker.Any(29.99)
			product2['description'] = veemarker.Any('Wireless mouse')
			product2['inStock'] = veemarker.Any(false)
			products << veemarker.Any(product2)

			context['products'] = veemarker.Any(products)

			// Tasks list
			mut tasks := []veemarker.Any{}
			mut task1 := map[string]veemarker.Any{}
			task1['title'] = veemarker.Any('Complete project')
			task1['completed'] = veemarker.Any(true)
			tasks << veemarker.Any(task1)

			mut task2 := map[string]veemarker.Any{}
			task2['title'] = veemarker.Any('Review code')
			task2['completed'] = veemarker.Any(false)
			tasks << veemarker.Any(task2)

			context['tasks'] = veemarker.Any(tasks)

			// Order items
			mut order_items := []veemarker.Any{}
			mut item1 := map[string]veemarker.Any{}
			item1['name'] = veemarker.Any('Widget A')
			item1['quantity'] = veemarker.Any(2)
			item1['price'] = veemarker.Any(15.99)
			order_items << veemarker.Any(item1)

			mut item2 := map[string]veemarker.Any{}
			item2['name'] = veemarker.Any('Widget B')
			item2['quantity'] = veemarker.Any(1)
			item2['price'] = veemarker.Any(29.99)
			order_items << veemarker.Any(item2)

			context['orderItems'] = veemarker.Any(order_items)

			// Colors
			colors := [veemarker.Any('Red'), veemarker.Any('Green'), veemarker.Any('Blue')]
			context['colors'] = veemarker.Any(colors)
		}
		'string-operations' {
			context['sentence'] = veemarker.Any('The quick brown fox jumps over the lazy dog')
			context['url'] = veemarker.Any('https://example.com')
			context['text'] = veemarker.Any('Replace old text with new')
			context['csvData'] = veemarker.Any('apple,banana,cherry,date')
			context['filePath'] = veemarker.Any('/home/user/documents/file.txt')
			context['email'] = veemarker.Any('user@example.com')
			context['paragraph'] = veemarker.Any('First line\nSecond line\nThird line')
			context['queryString'] = veemarker.Any('name=John&age=30&city=NYC')
			context['productCode'] = veemarker.Any(' ABC-123-XYZ ')
		}
		'basic-functions' {
			context['text'] = veemarker.Any('Hello World')
			context['name'] = veemarker.Any('john doe')
			context['sentence'] = veemarker.Any('The quick brown fox jumps')
		}
		'arrays' {
			numbers := [veemarker.Any(1), veemarker.Any(2), veemarker.Any(3), veemarker.Any(4), veemarker.Any(5)]
			context['numbers'] = veemarker.Any(numbers)

			mut fruits := []veemarker.Any{}
			fruits << veemarker.Any('apple')
			fruits << veemarker.Any('banana')
			fruits << veemarker.Any('cherry')
			context['fruits'] = veemarker.Any(fruits)

			// Matrix for nested arrays
			mut matrix := []veemarker.Any{}
			mut row1 := []veemarker.Any{}
			row1 << 1
			row1 << 2
			row1 << 3
			matrix << veemarker.Any(row1)

			mut row2 := []veemarker.Any{}
			row2 << 4
			row2 << 5
			row2 << 6
			matrix << veemarker.Any(row2)

			mut row3 := []veemarker.Any{}
			row3 << 7
			row3 << 8
			row3 << 9
			matrix << veemarker.Any(row3)
			context['matrix'] = veemarker.Any(matrix)

			// Students array with objects
			mut students := []veemarker.Any{}
			mut student1 := map[string]veemarker.Any{}
			student1['name'] = veemarker.Any('Alice')
			student1['grade'] = veemarker.Any(95)
			mut subjects1 := []veemarker.Any{}
			subjects1 << 'Math'
			subjects1 << 'Science'
			student1['subjects'] = veemarker.Any(subjects1)
			students << veemarker.Any(student1)

			mut student2 := map[string]veemarker.Any{}
			student2['name'] = veemarker.Any('Bob')
			student2['grade'] = veemarker.Any(87)
			mut subjects2 := []veemarker.Any{}
			subjects2 << 'History'
			subjects2 << 'English'
			student2['subjects'] = veemarker.Any(subjects2)
			students << veemarker.Any(student2)
			context['students'] = veemarker.Any(students)

			// Scores for filtering
			mut scores := []veemarker.Any{}
			scores << 95
			scores << 76
			scores << 88
			scores << 92
			scores << 68
			context['scores'] = veemarker.Any(scores)

			// Colors for reverse test
			mut colors := []veemarker.Any{}
			colors << 'red'
			colors << 'green'
			colors << 'blue'
			context['colors'] = veemarker.Any(colors)

			words := [veemarker.Any('apple'), veemarker.Any('banana'), veemarker.Any('cherry')]
			context['words'] = veemarker.Any(words)
		}
		'maps' {
			// Profile map
			mut profile := map[string]veemarker.Any{}
			profile['name'] = veemarker.Any('John Doe')
			profile['age'] = veemarker.Any(30)
			profile['email'] = veemarker.Any('john@example.com')
			profile['active'] = veemarker.Any(true)
			context['profile'] = veemarker.Any(profile)

			// Config map
			mut config := map[string]veemarker.Any{}
			config['host'] = veemarker.Any('localhost')
			config['port'] = veemarker.Any(8080)
			config['debug'] = veemarker.Any(true)
			context['config'] = veemarker.Any(config)

			// Company with CEO and departments
			mut ceo := map[string]veemarker.Any{}
			ceo['name'] = veemarker.Any('Jane Smith')
			ceo['email'] = veemarker.Any('jane@company.com')

			mut departments := []veemarker.Any{}
			mut dept1 := map[string]veemarker.Any{}
			dept1['name'] = veemarker.Any('Engineering')
			dept1['employeeCount'] = veemarker.Any(25)
			departments << veemarker.Any(dept1)

			mut dept2 := map[string]veemarker.Any{}
			dept2['name'] = veemarker.Any('Marketing')
			dept2['employeeCount'] = veemarker.Any(10)
			departments << veemarker.Any(dept2)

			mut company := map[string]veemarker.Any{}
			company['name'] = veemarker.Any('TechCorp')
			company['ceo'] = veemarker.Any(ceo)
			company['departments'] = veemarker.Any(departments)
			context['company'] = veemarker.Any(company)

			// Settings map
			mut settings := map[string]veemarker.Any{}
			settings['theme'] = veemarker.Any('dark')
			settings['language'] = veemarker.Any('en')
			settings['timezone'] = veemarker.Any('UTC')
			settings['notifications'] = veemarker.Any(true)
			context['settings'] = veemarker.Any(settings)

			// API Response
			mut permissions := []veemarker.Any{}
			permissions << 'read'
			permissions << 'write'
			permissions << 'admin'

			mut api_data := map[string]veemarker.Any{}
			api_data['userId'] = veemarker.Any(12345)
			api_data['username'] = veemarker.Any('johndoe')
			api_data['permissions'] = veemarker.Any(permissions)

			mut api_meta := map[string]veemarker.Any{}
			api_meta['requestId'] = veemarker.Any('req-789')
			api_meta['timestamp'] = veemarker.Any('2025-01-15T10:30:00Z')

			mut api_response := map[string]veemarker.Any{}
			api_response['status'] = veemarker.Any('success')
			api_response['code'] = veemarker.Any(200)
			api_response['data'] = veemarker.Any(api_data)
			api_response['meta'] = veemarker.Any(api_meta)
			context['apiResponse'] = veemarker.Any(api_response)
		}
		'includes' {
			context['page_title'] = veemarker.Any('Include Example Page')
			context['content_title'] = veemarker.Any('Welcome to Includes Example')
			context['content_body'] = veemarker.Any('This demonstrates template includes with header, sidebar, and footer components.')
			context['include_sidebar'] = veemarker.Any(true)
			context['site_title'] = veemarker.Any('My Website')
			context['show_social_links'] = veemarker.Any(true)

			mut nav_items := []veemarker.Any{}
			mut nav1 := map[string]veemarker.Any{}
			nav1['name'] = veemarker.Any('Home')
			nav1['url'] = veemarker.Any('/')
			nav_items << veemarker.Any(nav1)

			mut nav2 := map[string]veemarker.Any{}
			nav2['name'] = veemarker.Any('About')
			nav2['url'] = veemarker.Any('/about')
			nav_items << veemarker.Any(nav2)

			context['nav_items'] = veemarker.Any(nav_items)
		}
		'header' {
			context['site_title'] = veemarker.Any('My Website')
			context['show_social_links'] = veemarker.Any(true)

			mut nav_items := []veemarker.Any{}
			mut nav1 := map[string]veemarker.Any{}
			nav1['name'] = veemarker.Any('Home')
			nav1['url'] = veemarker.Any('/')
			nav_items << veemarker.Any(nav1)

			mut nav2 := map[string]veemarker.Any{}
			nav2['name'] = veemarker.Any('About')
			nav2['url'] = veemarker.Any('/about')
			nav_items << veemarker.Any(nav2)

			context['nav_items'] = veemarker.Any(nav_items)
		}
		'sidebar' {
			mut sidebar_items := []veemarker.Any{}
			mut sidebar1 := map[string]veemarker.Any{}
			sidebar1['title'] = veemarker.Any('Recent Posts')
			sidebar1['type'] = veemarker.Any('posts')
			sidebar_items << veemarker.Any(sidebar1)

			mut sidebar2 := map[string]veemarker.Any{}
			sidebar2['title'] = veemarker.Any('Categories')
			sidebar2['type'] = veemarker.Any('categories')
			sidebar_items << veemarker.Any(sidebar2)

			context['sidebar_items'] = veemarker.Any(sidebar_items)
		}
		'footer' {
			context['site_title'] = veemarker.Any('My Website')
			context['show_social_links'] = veemarker.Any(true)
		}
		'nullcheck' {
			context['existing_var'] = veemarker.Any('I exist')
			context['null_var'] = veemarker.Any('')
		}
		'attempt_success', 'attempt_recover' {
			context['valid_var'] = veemarker.Any('Success')
		}
		else {
			// Default sample data
			context['message'] = veemarker.Any('Hello from VeeMarker!')
			context['number'] = veemarker.Any(42)
			context['flag'] = veemarker.Any(true)
		}
	}

	return context
}

fn parse_simple_json(content string) !map[string]veemarker.Any {
	// Basic JSON parsing - this is a simplified version
	// In a real implementation, you'd use a proper JSON parser

	// For now, return empty context and let sample data be used
	// TODO: Implement proper JSON parsing or use V's json module
	return error('JSON parsing not implemented yet')
}