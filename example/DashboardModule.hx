package  ;

import js.Browser;
import mithril.M;
import mithril.M.Module;
import mithril.M.VirtualElement;

class DashboardModule implements DynModule
{
	var id : String;
	var todo : TodoModule;
	var chain : ChainController;

	public function new() {}

	public function controller() {
		id = M.routeParam("userID");
		todo = new TodoModule();
		chain = new ChainController();
	}

	public function view(_) {
		return M("div", [
			M("h1", this.id),
			M("div", {style: {width: "200px"}}, [
				todo.view(todo),
				M("hr"),
				chain.view.view(chain)
			])
		]);
	}

	public static function main() {
		var dashboard = new DashboardModule();

		M.routeMode = "hash";
		M.route(Browser.document.body, "/dashboard/Welcome", {
			"/dashboard/:userID": dashboard
		});
	}
}