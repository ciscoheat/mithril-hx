package  ;

#if !nodejs
import haxe.Serializer;
import haxe.Unserializer;
#end
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
		this.done = false;
	}
}

class TodoList implements Model
{
	#if !nodejs
	static var storage = Browser.window.localStorage;
	#end

	public static function load() : TodoList {
		#if nodejs
		return new TodoList();
		#else
		var list = storage.getItem("todo-app-list");
		if(list == "" || list == null) return new TodoList();

		var ser = new Unserializer(list);
		return new TodoList(cast ser.unserialize());
		#end
	}

	public var description : String;
	public var list : Array<Todo>;

	public function new(list = null) {
		this.list = list == null ? new Array<Todo>() : list;
		this.description = "";
	}

	public function add(?description : Null<String>) {
		if(description != null && description.length > 0) {
			this.list.push(new Todo(description));
			this.save();
		}
	}

	public function clear() {
		list.splice(0, list.length);
		save();
	}

	public function save() {
		#if !nodejs
		var ser = new Serializer();
		ser.serialize(list);
		storage.setItem("todo-app-list", ser.toString());
		#end
	}
}

class TodoModule implements Module<TodoModule>
{
	public var todo : TodoList;

	var loader : SpanElement;
	var input : InputElement;

	public function new() {
		this.todo = TodoList.load();
	}

	public function clear() {
		M.startComputation();
		todo.clear();
		M.endComputation();
	}

	public function controller() {}

	public function view() {
		m("div", [
			m("input", {
				config: function(e : InputElement) if(input == null) input = e,
				value: todo.description,
				onkeyup: input_keyUp
			}),
			// The add button has a second delay to simulate a slow ajax request.
			m("button", { onclick: todo_add.bind(1000) }, "Add"),
			m("span", {
				config: function(e : SpanElement) if(loader == null) loader = e,
				style: {display: "none"}
			}, " Adding..."),
			m("table", todo.list.map(function(task) {
				// Prevent "checked" being added to a todo if not set
				var attribs : Dynamic = { onclick: M.withAttr("checked", task_checked.bind(task)) } ;
				if(task.done) attribs.checked = "checked";

				return m("tr", [
					m("td", [ m("input[type=checkbox]", attribs) ]),
					m("td", { style: { textDecoration: task.done ? "line-through" : "none" }}, task.description)
				]);
			}))
		]);
	}

	private function todo_add(delay = 0) {
		// Calling the redrawing system because of the async delay.
		// See http://lhorie.github.io/mithril/auto-redrawing.html
		loader.style.display = "inline";
		M.startComputation();
		deferMs(delay)
		.then(function(ok) { todo.add(todo.description); return ok; }, function(error) return error)
		.then(function(_) {
			todo.description = "";
			loader.style.display = "none";
			M.endComputation();
		});
	}

	private function input_keyUp(e : KeyboardEvent) {
		todo.description = cast(e.target, InputElement).value;
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