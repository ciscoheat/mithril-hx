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

typedef MithrilNodeRenderer = VirtualElement -> String;

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
		require('./html-element.js');
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
		window.document.body = doc.createElement('body');

		HTTP.createServer(function(req, resp) {
			// TODO: Clone window object?
			window.location = URL.Parse(req.url);

			// Replace the window object in Mithril
			// must be done after window.location is set.
			M.deps(window);

			// Set the same routes as on clientside
			// must be done after M.deps()
			app.setRoutes(window.document.body);

			//////////

			var uri = window.location.pathname;
			var path = require('path');
			var filename = path.join(process.cwd(), uri.split('/').pop());

			trace('GET ${req.url}');

			File.exists(filename, function(exists) {
				if(!exists) {
					dynamicRoute(req.url, filename, resp);
					return;
				}
			});

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
		}).listen(6789);

		console.log("Server available at http://localhost:6789");
	}

	static function dynamicRoute(url : String, filename : String, resp : ServerResponse) {
		var render : MithrilNodeRenderer = require("mithril-node-render");
		var path = require('path');

		var indexPage = path.join(process.cwd(), "index.html");
		File.readFile(indexPage, function(err, html) {
			switch(url) {
				case "/dashboard" | "/dashboard/todo" | "/dashboard/chain":					
					var output = html.toString().replace("<!-- SERVERCONTENT -->", render(app.view(app)));
					resp.writeHead(200, {"Content-Type": "text/html"});  
					resp.write(output);
				case _:
					resp.writeHead(404, {"Content-Type": "text/plain"});
					resp.write("Not Found:" + filename + "\n");
					resp.write("Url:" + url + "\n");
			}

			resp.end();
		});
	}
}