
exports.config =
	conventions:
		ignored: [
			/([\/\\]|^)_/
			/vendor[\/\\]node[\/\\]/
			/vendor[\/\\]ruby-.*[\/\\]/
			/vendor[\/\\]jruby-.*[\/\\]/
			/app[\/\\]Native[\/\\]/
		]

	files:
		javascripts:
			joinTo: 'lib.js'

		stylesheets:
			joinTo: 'app.css'

		templates:
			joinTo: 'lib.js'

	plugins:
		elmBrunch:
			mainModules: [
				# This results in a file named `servicedemoapp.js`.
				'app/ServiceDemoApp.elm'
			]

			outputFolder: 'public'
