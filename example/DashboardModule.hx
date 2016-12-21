
import js.Browser;
import mithril.M;
import ChainController;

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
	var chainController : ChainController;
	var chainView : ChainView;

	var ip : String = "";
	var test : String = "";

	var currentApp : String = "";

	public function new() {
		todo = new TodoModule();
		chainController = new ChainController();
		chainView = new ChainView(new ChainModel());
	}

	public function oninit() {
		M.request({
			method: "GET",
			url: "http://jsonip.com/",
			// Use unwrapSuccess to transform the requested data
			unwrapSuccess: function(data: {ip : String}) return new IpWrapper(data.ip)
		}).then(
			function(currentIp : IpWrapper) ip = currentIp.ip,
			function(_) ip = "Don't know!"
		);
	}

	public function onupdate(vnode : VNode<DashboardModule>) {
		currentApp = vnode.attrs.app;
	}

	public function view() {
		[
			m("h1", "Welcome!"),
			m("p", "Choose your app:"),
			m("div", {style: {width: "300px"}}, [
				m("a[href='/dashboard/todo']", {oncreate: M.routeLink}, "Todo list"),
				m("span", M.trust("&nbsp;")),
				m("a[href='/dashboard/chain']", {oncreate: M.routeLink}, "Don't break the chain"),
				m("hr"),
				switch(currentApp) {
					case "todo": todo.view();
					case "chain": chainView.view(chainController);
					case _: m("#app");
				},
				m("hr"),
				m("div", ip.length == 0 ? "Retreiving IP..." : "Your IP: " + ip),
				m("button", { onclick: clearData }, "Clear stored data")
			])
		];
	}

	public function clearData() {
		todo.clear();
		chainController.clear();
	}

	public function setRoutes(body : js.html.Element) {
		#if isomorphic
		trace('Isomorphic mode active');
		// Changing route mode to "pathname" to get urls without hash.
		M.routePrefix("");
		#end

		M.route(body, "/dashboard", {
			"/dashboard": this,
			"/dashboard/:app": this
		});
	}

	public static function main() {
		Browser.document.addEventListener('DOMContentLoaded', function(e){
			new DashboardModule().setRoutes(Browser.document.body);
		});
	}
}