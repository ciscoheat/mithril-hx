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

	public function new() {
		todo = new TodoModule();
		chainController = new ChainController();
		chainView = new ChainView(new ChainModel());
	}

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
				switch(M.routeParam("app")) {
					case "todo": todo.view(todo);
					case "chain": chainView.view(chainController);
					case _: m("#app");
				}
			])
		]);
	}

	public static function main() {
		var app = new DashboardModule();

		M.routeMode = "hash";

		M.route(Browser.document.body, "/dashboard", {
			"/dashboard": app,
			"/dashboard/:app": app
		});
	}
}