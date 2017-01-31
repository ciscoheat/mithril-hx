#if (haxe_ver >= 3.2)
import js.html.DOMElement in Element;
#else
import js.html.Element;
#end
import js.Lib;
import mithril.M;
import mithril.M.m;
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
	static var console(default,null) = Node.console;

	static function main() {
		var args : Array<String> = Node.process.argv;
		
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

	// A simple Express server, matching the routes in DashboardModule.
	static function startServer() {
		var dashboard = new DashboardModule();
		var renderer = new MithrilNodeRender();		
		
		var express : Dynamic = Lib.require('express');
		var app = express();
		
		app.use(Reflect.field(express, "static")('.'));
		
		function renderMithril(vnode : Vnodes, res : Dynamic) {
			Fs.readFile('index.html', { encoding: 'utf-8' }, function(err, html) {
				var output = renderer.render(vnode);
				res.send(html.replace('<!-- SERVERCONTENT -->', output));
			});
		}
		
		// Routes must be kept synchronized with DashboardModule.hx
		app.get('/', function(req, res : Dynamic) {
			res.redirect('/dashboard');
		});
		
		app.get('/dashboard/:app?', function(req, res) {
			dashboard.changeApp(req.params.app);
			renderMithril(dashboard.render(), res);
		});

		app.listen(2000, function() {
			console.log("Server started on port 2000");
		});
	}
}