package ;

#if (haxe_ver >= 3.2)
import js.html.DOMElement in Element;
#else
import js.html.Element;
#end
import mithril.M;
import mithril.MithrilNodeRender;
import js.Node;
import js.node.Process;
import js.node.Http;
import js.node.Url;
import js.node.http.ServerResponse;
import js.node.Url.UrlData;
import js.node.Fs;
import js.Browser;
import js.html.Document;

using StringTools;

class NodeRendering
{
	static function require<T>(s : String) : T return untyped __js__('require(s)');
	static var console(default,null) = Node.console;
	static var process(default,null) = Node.process;

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
		todoList.todo.add("Second <one>");

		todoList.todo.list[0].done = true;

		console.log(new MithrilNodeRender().render(todoList.view()));
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
		Reflect.setField(window.document, 'body', doc.createElement('body'));

		// Need some extra functions on the element for everything to work.
		untyped Element.prototype.addEventListener = Element.prototype.removeEventListener = 
				Element.prototype.insertAdjacentHTML = function() {};

		Http.createServer(function(req, resp : ServerResponse) {
			window.location = Url.parse(req.url);

			// Replace the window object in Mithril
			// must be done after window.location is set.
			M.deps(window);

			// Set the same routes as on clientside
			// must be done after M.deps()
			app.setRoutes(untyped window.document.body);			

			//////////

			trace('GET ${req.url}');

			dynamicRoute(req.url, resp, function(isDynamic) {
				if(isDynamic) return;

				var uri = window.location.pathname;
				var path = require('path');
				var filename = path.join(process.cwd(), req.url.split('/').pop());

				//trace('GET ${req.url} ($filename $uri)');

				Fs.stat(filename, function(err, stats) {
					if(err != null) {
						resp.writeHead(404, {"Content-Type": "text/plain"});
						resp.write("Not Found: " + filename + "\n");
						resp.write("Url:" + req.url + "\n");
						resp.end();
						return;
					}

					// Static file
					if(stats.isDirectory()) filename += "/index.html";

					Fs.readFile(filename, function(err, file) {
						if(err != null) {
							resp.writeHead(500, {"Content-Type": "text/plain"});
							resp.write(err + "\n");
							resp.end();
							return;
						}

						resp.writeHead(200);
						resp.write(file);
						resp.end();
					});
				});
			});				
		}).listen(2000);

		console.log("Server started on http://localhost:2000");
	}

	static function dynamicRoute(url : String, resp : ServerResponse, then : Bool -> Void) {
		var render = new MithrilNodeRender();
		var path = require('path');
		var test = url.split('/').filter(function(s) return s.length > 0).join('/');

		switch(test) {
			case "dashboard", "dashboard/todo", "dashboard/chain":
				var template = path.join(process.cwd(), "index.html");
				Fs.readFile(template, function(err, html) {
					var rendered = render.render(app.view());
					var output : String = html.toString().replace("<!-- SERVERCONTENT -->", rendered);
					resp.writeHead(200, {
						"Content-Length": Std.string(output.length),
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