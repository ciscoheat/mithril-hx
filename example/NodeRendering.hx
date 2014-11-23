package ;

import js.html.Element;
import mithril.M;
import nodejs.Process;
import nodejs.Console;
import nodejs.http.HTTP;
import nodejs.http.URL;
import nodejs.http.ServerResponse;
import nodejs.http.URLData;
import nodejs.fs.File;
import js.Browser;
import js.html.Document;
using StringTools;

typedef MithrilNodeRenderer = Children -> String;

class NodeRendering
{
	static function require<T>(s : String) : T return untyped __js__('require(s)');
	static var console(default,null) = Console;
	static var process(default,null) : Process = untyped __js__('process');

	static var app : DashboardModule;
	static var window : Dynamic;

	static function main() {
		var args : Array<String> = process.argv;
		if(args.length >= 3 && args[2] == "server")
			startServer();
		else
			displayTodo();
	}	

	static function displayTodo() {
		var todoList = new TodoModule();

		todoList.todo.add("First one");
		todoList.todo.add("Second one");

		todoList.todo.list[0].done = true;

		var render : MithrilNodeRenderer = require("mithril-node-render");

		console.log(render(todoList.view(todoList)));
	}

	static function startServer() {
		app = new DashboardModule();

		// Mithril requires window and document to work properly.
		// emulate them with html-element and some custom stuff.
		require('html-element');
		var doc : Document = untyped document;
		var window = {
			document: doc,
			location: null, // will be replaced in createServer
			history: {},
			scrollTo : function(_, _) {},
			requestAnimationFrame: function(_) {},
			cancelAnimationFrame: function(_) {},
			XMLHttpRequest: {}
		};

		// Need some extra functions on the element for everything to work.
		untyped Element.prototype.addEventListener = Element.prototype.removeEventListener = 
				Element.prototype.insertAdjacentHTML = function() {};

		window.document.body = doc.createElement('body');

		HTTP.createServer(function(req, resp) {
			window.location = URL.Parse(req.url);

			// Replace the window object in Mithril
			// must be done after window.location is set.
			M.deps(window);

			// Set the same routes as on clientside
			// must be done after M.deps()
			app.setRoutes(window.document.body);			

			//////////

			trace('GET ${req.url}');

			dynamicRoute(req.url, resp, function(isDynamic) {
				if(isDynamic) return;

				var uri = window.location.pathname;
				var path = require('path');
				var filename = path.join(process.cwd(), req.url.split('/').pop());

				//trace('GET ${req.url} ($filename $uri)');

				File.exists(filename, function(exists) {
					if(!exists) {
						resp.writeHead(404, {"Content-Type": "text/plain"});
						resp.write("Not Found: " + filename + "\n");
						resp.write("Url:" + req.url + "\n");
						resp.end();
						return;
					}

					// Static file
					try {
						if(File.statSync(filename).isDirectory()) filename += "/index.html";
					} catch(e : Dynamic) {
						return;
					}

					File.readFile(filename, function(err, file) {
						if(err != null) {
							resp.writeHead(500, {"Content-Type": "text/plain"});
							resp.write(err + "\n");
							resp.end();
							return;
						}

						resp.writeHead(200);
						resp.write(file, "binary");
						resp.end();
					});
				});
			});				
		}).listen(6789);

		console.log("Server started on http://localhost:6789");
	}

	static function dynamicRoute(url : String, resp : ServerResponse, then : Bool -> Void) {
		var render : MithrilNodeRenderer = require("mithril-node-render");
		var path = require('path');
		var test = url.split('/').filter(function(s) return s.length > 0).join('/');

		switch(test) {
			case "dashboard", "dashboard/todo", "dashboard/chain":
				var template = path.join(process.cwd(), "index.html");
				File.readFile(template, function(err, html) {
					var rendered = render(app.view(app));
					var output : String = html.toString().replace("<!-- SERVERCONTENT -->", rendered);
					resp.writeHead(200, {
						"Content-Length": output.length,
						"Content-Type": "text/html"
					});  
					resp.write(output);
					resp.end();
					//console.log(output);
					then(true);
				});
			case _:
				then(false);
		}
	}
}