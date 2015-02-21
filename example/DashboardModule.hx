package  ;

import js.Browser;
import mithril.M;
import mithril.M.Module;
import mithril.M.VirtualElement;
import ChainController;

class DashboardModule implements Module<Dynamic>
{
	var todo : TodoModule;
	var chainController : ChainController;
	var chainView : ChainView;

	@prop var ip : String;

	public function new() {
		todo = new TodoModule();
		chainController = new ChainController();
		chainView = new ChainView(new ChainModel());
		ip = M.prop("");
	}

	public function controller() {
		// Detect IP in background so it won't stop the rendering.
		M.request({
			method: "GET",
			url: "http://ip.jsontest.com/",
			background: true,
			initialValue: '',
			unwrapSuccess: function(data: {ip : String}) return data.ip
		}).then(
			function(currentIp : String) { ip(currentIp); M.redraw(); },
			function(_) { ip("Don't know!"); M.redraw(); }
		);
	}

	public function view() {
		[
			m("h1", "Welcome!"),
			m("p", "Choose your app:"),
			m("div", {style: {width: "300px"}}, [
				m("a[href='/dashboard/todo']", {config: M.route}, "Todo list"),
				m("span", M.trust("&nbsp;")),
				m("a[href='/dashboard/chain']", {config: M.route}, "Don't break the chain"),
				m("hr"),
				switch(M.routeParam("app")) {
					case "todo": todo.view();
					case "chain": chainView.view(chainController);
					case _: m("#app");
				},
				m("hr"),
				m("div", ip().length == 0 ? "Retreiving IP..." : "Your IP: " + ip()),
				m("button", { onclick: clearData }, "Clear stored data")
			])
		];
	}

	public function clearData() {
		M.startComputation();
		todo.clear();
		chainController.clear();
		M.endComputation();
	}

	public function setRoutes(body : js.html.Element) {
		#if isomorphic
		// Changing route mode to "pathname" to get urls without hash.
		M.routeMode = "pathname";
		#else
		M.routeMode = "hash";
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