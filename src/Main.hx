package ;

import js.Browser;
import mithril.M;
import js.Lib;

class Todo
{
	public dynamic function description(?v : String) : String return v;
	public dynamic function done(?v : Bool) : Bool return v;

	public function new(description) {
		this.description = M.prop(description);
		this.done = M.prop(false);
	}
}

typedef TodoList = Array<Todo>;

class Vm
{
	public var list : TodoList;
	public dynamic function description(?v : String) : String return v;

	public function new() {
		this.list = new TodoList();
		this.description = M.prop("");
	}

	public function add() {
		if (this.description() != "") {
			this.list.push(new Todo(this.description()));
			this.description("");
		}
	}
}

class Main
{
	var todo : Vm;

	public function new() {
	}

	public function controller() {
		///// MACRO
		if (M.modules.first() != this) {
			M.modules.first().controller();
			return M.modules.pop();
		}
		///// END MACRO

		todo = new Vm();

		///// MACRO
		return this;
		///// END MACRO
	}

	public function view() {
		return M.m("body", [
			M.m("input", { onchange: M.withAttr("value", todo.description), value: todo.description() }),
			M.m("button", { onclick: todo.add }, "Add"),
			M.m("table", todo.list.map(function(task) {
				return M.m("tr", [
					M.m("td", [
						M.m("input[type=checkbox]", { onclick: M.withAttr("checked", task.done), checked: task.done() } )
					]),
					M.m("td", { style: { textDecoration: task.done() ? "line-through" : "none" }}, task.description())
				]);
			}))
		]);
	}

	static function main()
	{
		M.module(Browser.document.body, new Main());
	}
}