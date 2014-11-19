package  ;

import haxe.Serializer;
import haxe.Unserializer;
import haxe.Timer;
import js.Browser;
import js.html.Event;
import js.html.InputElement;
import js.html.KeyboardEvent;
import js.html.SpanElement;
import mithril.M;
import js.Lib;

/**
* Cannot use @prop and M.prop(), doesn't work well with
* Haxe serialization.
*/
class Todo implements Model
{
	public var description : String;
	public var done : Bool;

	public function new(description) {
		this.description = description;
	}
}

class TodoList implements Model
{
	static var storage = Browser.window.localStorage;

	public static function load() : TodoList {
		var list = storage.getItem("todo-app-list");
		if(list == "" || list == null) return new TodoList();

		var ser = new Unserializer(list);
		return new TodoList(cast ser.unserialize());
	}

	@prop public var description : String;
	public var list : Array<Todo>;

	public function new(list = null) {
		this.list = list == null ? new Array<Todo>() : list;
		this.description = M.prop("");
	}

	public function add() {
		if (this.description() != "") {
			this.list.push(new Todo(this.description()));
			this.description("");
			this.save();
		}
	}

	public function clear() {
		list.splice(0, list.length);
		save();
	}

	public function save() {
		var ser = new Serializer();
		ser.serialize(list);
		storage.setItem("todo-app-list", ser.toString());
	}
}

class TodoModule implements Module<TodoModule>
{
	var todo : TodoList;
	var loader : SpanElement;

	public function new() {
		this.todo = TodoList.load();
	}

	public function clear() {
		M.startComputation();
		todo.clear();
		M.endComputation();
	}

	public function controller() {}

	public function view(_) {
		return m("div", [
			m("input", {
				config: function(e : InputElement) e.focus(),
				value: todo.description(),
				onkeyup: input_keyUp
			}),
			// The add button has a second delay to simulate a slow ajax request.
			m("button", { onclick: todo_add.bind(1000) }, "Add"),
			m("span", {
				config: function(e : SpanElement) if(loader == null) loader = e,
				style: {display: "none"}
			}, " Adding..."),
			m("table", todo.list.map(function(task) {
				return m("tr", [
					m("td", [
						m("input[type=checkbox]", { 
							onclick: M.withAttr("checked", task_checked.bind(task)), 
							checked: task.done
						})
					]),
					m("td", { style: { textDecoration: task.done ? "line-through" : "none" }}, task.description)
				]);
			}))
		]);
	}

	private function todo_add(delay = 0) {
		// Calling the redrawing system because of the async delay.
		// See http://lhorie.github.io/mithril/auto-redrawing.html
		M.startComputation();
		loader.style.display = "inline";
		deferMs(delay)
		.then(function(ok) { todo.add(); return ok; }, function(error) return error)
		.then(function(_) {
			loader.style.display = "none";
			M.endComputation();
		});
	}

	private function input_keyUp(e : KeyboardEvent) {
		todo.description(cast(e.target, InputElement).value);
		if (e.keyCode == 13) todo_add();
	}

	private function task_checked(task : Todo, checked : Bool) {
		task.done = checked;
		todo.save();
	}

	private function deferMs(delay : Int) : Promise<Bool, Bool> {
		var d = M.deferred();
		Timer.delay(d.resolve.bind(true), delay);
		return d.promise;
	}

	static function main()
	{
		M.module(Browser.document.body, new TodoModule());
	}
}