package ;

import js.Browser;
import mithril.M;
import js.Lib;

class Todo implements Model
{
	@prop public var description : String;
	@prop public var done : Bool;

	public function new(description) {
		this.description = M.prop(description);
		this.done = M.prop(false);
	}
}

typedef TodoList = Array<Todo>;

class ViewModel implements Model
{
	@prop public var description : String;
	public var list : TodoList;

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

class TodoModule implements DynModule
{
	var todo : ViewModel;

	public function new() {}

	public function controller() {
		todo = new ViewModel();
	}

	public function view(_) {
		return m("body", [
			m("input", { onchange: M.withAttr("value", todo.description), value: todo.description() }),
			m("button", { onclick: todo.add }, "Add"),
			m("table", todo.list.map(function(task) {
				return m("tr", [
					m("td", [
						m("input[type=checkbox]", { onclick: M.withAttr("checked", task.done), checked: task.done() } )
					]),
					m("td", { style: { textDecoration: task.done() ? "line-through" : "none" }}, task.description())
				]);
			}))
		]);
	}

	static function main()
	{
		M.module(Browser.document.body, new TodoModule());
	}
}