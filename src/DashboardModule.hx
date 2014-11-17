package ;

import js.Browser;
import mithril.M;
import mithril.M.Module;
import mithril.M.VirtualElement;

class DashboardModule implements Module
{
	var id : String;

	public function new() {}

	public function controller() {
		id = M.routeParam("userID");
	}

	public function view() {
		return m("div", this.id);
	}

	public static function main() {
		var dashboard = new DashboardModule();

		M.routeMode = "hash";
		M.route(Browser.document.body, "/dashboard/johndoe", {
			"/dashboard/:userID": dashboard
		});
	}
}