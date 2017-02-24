#if server

#if nodejs
import js.Lib;
import js.node.Fs;
#end

import mithril.M;
import mithril.MithrilNodeRender;

using StringTools;

class Server
{
	//
	// Entrypoint for the server application
	//
	static function main() {
		if(Sys.args().length > 0 && Sys.args()[0] == "server")
			startServer();
		else
			displayTodo();
	}	

	static function displayTodo() {
		var todos = new TodoList();
		
		// Add some test data
		todos.add("First one");
		todos.add("Second <one>");
		todos.setStatus(todos.iterator().next(), true);
		
		var todoList = new TodoComponent(todos);

		Sys.println(new MithrilNodeRender().render(todoList.view()));
	}

	// A simple Express server, matching the routes in DashboardModule.
	static function startServer() {
		#if nodejs
		var dashboard = new DashboardComponent();
		var renderer = new MithrilNodeRender();		
		
		var express : Dynamic = Lib.require('express');
		var app = express();
		
		// Using working dir as static directory (only for testing!)
		// must use Reflect since static is a reserved word in Haxe.
		app.use(Reflect.field(express, "static")('.'));

		// Reads the html template, renders the mithril template and merges them.
		function renderMithril(vnodes : Vnodes, res : Dynamic, next : ?Dynamic -> Void) {
			Fs.readFile('index.html', { encoding: 'utf-8' }, function(err, html) {
				if (err != null) return next(err);
				var output = renderer.render(vnodes);
				res.send(html.replace('<!-- SERVERCONTENT -->', output));
			});
		}
		
		///// Routes must be kept synchronized with DashboardModule.hx ////////
		
		app.get('/', function(req, res, next) {
			res.redirect('/dashboard');
		});
		
		app.get('/dashboard/:app?', function(req, res, next) {
			dashboard.changeApp(req.params.app);
			renderMithril(dashboard.render(), res, next);
		});
		
		///////////////////////////////////////////////////////////////////////

		app.listen(2000, function() {
			Sys.println("Server started on port 2000");
		});
		#else
		Sys.println("Server mode currently only supported on Node.js");
		#end
	}
}
#end
