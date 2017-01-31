
import mithril.M;
import ChainModel;

@:enum abstract CurrentApp(String) from String {
	var None = "";
	var Todos = "todos";
	var Chain = "chain";
}

class DashboardModule implements Mithril
{
	var todo : TodoModule;
	var chainView : ChainView;
	var chainModel : ChainModel;

	var ip : String = "";
	var currentApp : CurrentApp = None;
	
	///////////////////////////////////////////////////////////////////////////
	
	public function new() {
		todo = new TodoModule();
		chainModel = new ChainModel();
		chainView = new ChainView(chainModel);
		
		#if !server
		M.request("https://jsonip.com/").then(
			function(data : {ip: String}) ip = data.ip,
			function(_) ip = "Don't know!"
		);
		#end
	}
	
	public function changeApp(app : CurrentApp) {
		currentApp = app;
		M.redraw();
	}

	public function render(vnode) return [
		m("h1", "Welcome!"),
		m("p", "Choose your app:"),
		m("div", {style: {width: "300px"}}, [
			m("a[href='/dashboard/todos']", {oncreate: M.routeLink}, "Todo list"),
			m("span", M.trust("&nbsp;")),
			m("a[href='/dashboard/chain']", {oncreate: M.routeLink}, "Don't break the chain"),
			m("hr"),
			switch(currentApp) {
				case Todos: todo.view();
				case Chain: chainView.view();
				case None: m("#app");
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

	public function onmatch(params : haxe.DynamicAccess<String>, url : String) {
		changeApp(params.get('app'));
		return null;
	}
	
	#if !server
	public static function main() {
		var dashboard = new DashboardModule();
		var htmlBody = js.Browser.document.body;
		
		#if isomorphic
		trace('Isomorphic mode active');
		// Changing route mode to "pathname" to get urls without hash.
		M.routePrefix("");
		#end

		///// Routes must be kept synchronized with NodeRendering.hx /////
		M.route(htmlBody, "/dashboard", {
			"/dashboard": dashboard,
			"/dashboard/:app": dashboard
		});		
	}
	#end
}