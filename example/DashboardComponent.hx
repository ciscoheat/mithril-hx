
import mithril.M;
import ChainComponent;

@:enum abstract CurrentApp(String) from String {
	var None = "";
	var Todos = "todos";
	var Chain = "chain";
}

class DashboardComponent implements Mithril
{
	var todo : TodoComponent;
	var chainView : ChainComponent;
	var chainModel : ChainModel;

	var ip : String = "";
	var currentApp : CurrentApp = None;
	
	///////////////////////////////////////////////////////////////////////////
	
	public function new() {
		todo = new TodoComponent(TodoList.load());
		chainModel = new ChainModel();
		chainView = new ChainComponent(chainModel);
		
		#if !server
		M.request("https://jsonip.com/").then(
			data -> ip = data.ip,
			_ -> ip = "Don't know!"
		);
		#end
	}
	
	public function changeApp(app : CurrentApp) {
		if (app == null) app = None;
		currentApp = app;
		M.redraw();
	}

	public function view() [
		m("h1", "Welcome!"),
		m("p", "Choose your app:"),
		m("div", {style: {width: "300px"}}, [
			m(M.route.Link, {href: "/dashboard/todos"}, "Todo list"),
			m("span", M.trust("&nbsp;")),
			m(M.route.Link, {href: "/dashboard/chain"}, "Don't break the chain"),
			m("hr"),
			switch(M.route.param('app')) {
				case Todos: m(todo);
				case Chain: m(chainView);
				case _: m("#app");
			},
			m("hr"),
			m("div", ip.length == 0 ? "Retreiving IP..." : "Your IP: " + ip),
			m("button", { onclick: clearData }, "Clear stored data")
		])
	];

	function clearData() {
		todo.clear();
		chainModel.clear();
	}

	#if !server
	//
	// Client entry point
	//
	public static function main() {
		var dashboard = new DashboardComponent();
		var htmlBody = js.Browser.document.body;
		
		#if isomorphic
		trace('Isomorphic mode active');
		// Changing route mode to "pathname" to get urls without hash.
		M.route.prefix = "";
		#end

		///// Routes must be kept synchronized with NodeRendering.hx /////
		M.route.route(htmlBody, "/dashboard", {
			"/dashboard": dashboard,
			"/dashboard/:app": dashboard
		});		
	}
	#end
}