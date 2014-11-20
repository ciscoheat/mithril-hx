package  ;

import js.Browser;
import mithril.M;
import mithril.M.Module;
import mithril.M.VirtualElement;
import ChainController;

class DashboardModule implements DynModule
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
		// Detect IP, but with a minimal delay so it won't stop the rendering.
		if(ip().length == 0) haxe.Timer.delay(function() {
			M.request({
				method: "GET",
				url: "http://ip.jsontest.com/"
			}).then(
				function(r : {ip : String}) ip(r.ip), 
				function(_) ip("Don't know!")
			);
		}, 0);
	}

	public function view(_) {
		return m("div", [
			m("h1", "Welcome!"),
			m("p", "Choose your app:"),
			m("div", {style: {width: "300px"}}, [
				m("a[href='/dashboard/todo']", {config: M.route}, "Todo list"),
				m("span", M.trust("&nbsp;")),
				m("a[href='/dashboard/chain']", {config: M.route}, "Don't break the chain"),
				m("hr"),
				switch(M.routeParam("app")) {
					case "todo": todo.view(todo);
					case "chain": chainView.view(chainController);
					case _: m("#app");
				},
				m("hr"),
				m("div", ip().length == 0 ? "Retreiving IP..." : "Your IP: " + ip()),
				m("button", { onclick: clearData }, "Clear stored data")
			])
		]);
	}

	public function clearData() {
		M.startComputation();
		todo.clear();
		chainController.clear();
		M.endComputation();
	}

	public function setRoutes(body : js.html.Element) {
		M.routeMode = "pathname";

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