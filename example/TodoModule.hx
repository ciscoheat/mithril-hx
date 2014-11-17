package  ;

import js.Browser;
import js.html.Event;
import js.html.InputElement;
import js.html.KeyboardEvent;
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

	public function new() {
		todo = new ViewModel();
	}

	public function controller() {
	}

	public function view(_) {
		return M("div", [
			M("input", {
				config: function(e : InputElement) e.focus(),
				onchange: M.withAttr("value", todo.description),
				value: todo.description(),
				onkeyup: function(e : KeyboardEvent) {
					todo.description(cast(e.target, InputElement).value);
					if (e.keyCode == 13) todo.add();
				}
			}),
			M("button", { onclick: function() todo.add() }, "Add"),
			M("table", todo.list.map(function(task) {
				return M("tr", [
					M("td", [
						M("input[type=checkbox]", { onclick: M.withAttr("checked", task.done), checked: task.done() } )
					]),
					M("td", { style: { textDecoration: task.done() ? "line-through" : "none" }}, task.description())
				]);
			}))
		]);
	}

	static function main()
	{
		M.module(Browser.document.body, new TodoModule());
	}
}