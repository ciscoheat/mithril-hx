package  ;

import haxe.Timer;
import js.Browser;
import js.html.Event;
import js.html.InputElement;
import js.html.KeyboardEvent;
import js.html.SpanElement;
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

class TodoList implements Model
{
	@prop public var description : String;

	// Mithril has problems with Haxe Lists and map so we need to use an Array.
	public var list : Array<Todo>;

	public function new() {
		this.list = new Array<Todo>();
		this.description = M.prop("");
	}

	public function add() {
		if (this.description() != "") {
			this.list.push(new Todo(this.description()));
			this.description("");
		}
	}
}

class TodoModule implements Module<TodoModule>
{
	var todo : TodoList;

	public function new() {
		todo = new TodoList();
	}

	public function controller() {}

	public function view(_) {
		var loader : SpanElement = null;

		// Calling the redrawing system because of the async delay.
		// See http://lhorie.github.io/mithril/auto-redrawing.html
		var addTodo = function(delay = 0) {
			M.startComputation();
			loader.style.display = "inline";
			return deferMs(delay)
			.then(function(_) todo.add(), function(_) { /* Error, just pass through */ })
			.then(function(_) {
				loader.style.display = "none";
				M.endComputation();
			});
		}

		return m("div", [
			m("input", {
				config: function(e : InputElement) e.focus(),
				onchange: M.withAttr("value", todo.description),
				value: todo.description(),
				onkeyup: function(e : KeyboardEvent) {
					todo.description(cast(e.target, InputElement).value);
					if (e.keyCode == 13) addTodo();
				}
			}),
			// For testing, the add button has a second delay.
			m("button", { onclick: addTodo.bind(1000) }, "Add"),
			m("span", {
				config: function(e : SpanElement) loader = e,
				style: {display: "none"}
			}, " Loading..."),
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

	private function deferMs(delay : Int) {
		var d = M.deferred();
		Timer.delay(d.resolve.bind("ok"), delay);
		return d.promise;
	}

	static function main()
	{
		M.module(Browser.document.body, new TodoModule());
	}
}