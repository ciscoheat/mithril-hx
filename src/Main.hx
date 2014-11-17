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
	static var self : Main;

	public function new() {
		self = this;
		model = new Model();
		model.greeting = "Hello";
	}

	public function controller() {
		return self;
	}

	public function view() {
		return M.m("h1", model.greeting);
	}

	static function main()
	{
		M.module(Browser.document.body, new Main());
	}
}