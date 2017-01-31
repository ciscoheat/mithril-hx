
import js.Browser;
import mithril.M;
import ChainController;

@:enum abstract CurrentApp(String) from String {
	var None = "";
	var Todos = "todos";
	var Chain = "chain";
}

// A class just to test the unwrapSuccess and 
// type parameters for M.request.
class IpWrapper
{
	public var ip : String;
	public function new(data : String) {
		this.ip = data.split('.').join(' . ');
	}
}

class DashboardModule implements Mithril
{
	var todo : TodoModule;
	var chainView : ChainView;
	var chainModel : ChainModel;

	var ip : String = "";
	var test : String = "";
	var currentApp : CurrentApp = None;
	
	public function changeApp(app : CurrentApp) {
		currentApp = app;
		M.redraw();
	}

	public function new() {
		todo = new TodoModule();
		chainModel = new ChainModel();
		chainView = new ChainView(chainModel);		
	}

	public function render() return [
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

	#if !server
	public function onmatch(params : haxe.DynamicAccess<String>, url : String) {
		if(ip.length == 0) M.request("https://jsonip.com/").then(
			function(data : {ip: String}) ip = data.ip,
			function(_) ip = "Don't know!"
		);
		
		changeApp(params.get('app'));
	}
	
	public function setRoutes(body : js.html.Element) {
		#if isomorphic
		trace('Isomorphic mode active');
		// Changing route mode to "pathname" to get urls without hash.
		M.routePrefix("");
		#end

		// Routes must be kept synchronized with NodeRendering.hx
		M.route(body, "/dashboard", {
			"/dashboard": this,
			"/dashboard/:app": this
		});
	}
	
	public static function main() {
		new DashboardModule().setRoutes(Browser.document.body);
	}
	#end
}