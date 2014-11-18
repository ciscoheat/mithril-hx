package  ;

import js.Browser;
import mithril.M;
import mithril.M.Module;
import mithril.M.VirtualElement;
import ChainController;

class DashboardModule implements DynModule
{
	public function new() {}

	public function controller() {}

	public function view(_) {
		return m("div", [
			m("h1", "Welcome!"),
			m("p", "Choose your app:"),
			m("div", {style: {width: "300px"}}, [
				m("a[href='/dashboard/todo']", {config: M.route}, "Todo list"),
				m("span", M.trust("&nbsp;")),
				m("a[href='/dashboard/chain']", {config: M.route}, "Don't break the chain"),
				m("hr"),
				m("#app")
			])
		]);
	}

	public static function main() {
		//var app = new DashboardModule();
		//var todo = new TodoModule();
		var chain = {controller: new ChainController().controller, view: new ChainView(new ChainModel()).view };

		M.routeMode = "hash";

		M.route(Browser.document.body, "/dashboard", {
			"/dashboard": new DashboardModule(),
		//});

		//M.route("#app", "/dashboard/todo", {
			"/dashboard/todo": new TodoModule(),
			"/dashboard/chain": {
				controller: new ChainController().controller, 
				view: new ChainView(new ChainModel()).view 
			}
		});
	}
}