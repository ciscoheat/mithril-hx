package ;

import js.Browser;
import mithril.M;
import js.Lib;

class Model
{
	public var greeting : String;

	public function new() {}
}

class Main
{
	var model : Model;

	public function new() {

	}

	public function controller() {
		///// MACRO
		if (M.modules.first() != this) {
			M.modules.first().controller();
			return M.modules.pop();
		}
		///// END MACRO

		model = new Model();
		model.greeting = "Hello";

		///// MACRO
		return this;
		///// END MACRO
	}

	public function view() {
		return M.m("h1", model.greeting);
	}

	static function main()
	{
		M.module(Browser.document.body, new Main());
	}
}