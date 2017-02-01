import haxe.Timer;
import mithril.M;
import mithril.M.m;

#if !server
import haxe.Serializer;
import haxe.Unserializer;
#end

#if js
import js.Browser;
import js.html.Event;
import js.html.InputElement;
import js.html.KeyboardEvent;
import js.html.SpanElement;
import js.Lib;
#else
typedef KeyboardEvent = Dynamic;
typedef InputElement = Dynamic;
#end

// Model
class Todo
{
	public var description : String;
	public var done : Bool;

	public function new(description) {
		this.description = description;
		this.done = false;
	}
}

// Model
class TodoList
{
	#if !server
	static var storage = Browser.window.localStorage;
	#end

	public static function load() : TodoList {
		#if server
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
		#if !server
		var ser = new Serializer();
		ser.serialize(list);
		storage.setItem("todo-app-list", ser.toString());
		#end
	}
}

// Controller/View
class TodoComponent implements Mithril
{
	public var todo : TodoList;

	var todoAdding : Bool;

	public function new() {
		this.todo = TodoList.load();
	}

	public function clear() {
		todo.clear();
	}

	public function view() {
		m("div", [
			m("input", {
				value: todo.description,
				onkeyup: todo_setDescription
			}),
			// The add button has a one second delay to simulate a slow ajax request.
			m("button", { onclick: todo_add.bind(1000) }, "Add"),
			m("span", {style: {display: todoAdding ? "" : "none"}}, " Adding..."),
			m("table", todo.list.map(function(task) {
				// Prevent "checked" being added to a todo if not set
				var attribs : Dynamic = { onclick: M.withAttr("checked", setTaskStatus.bind(task)) } ;
				if(task.done) attribs.checked = "checked";

				m("tr", [
					m("td", [ m("input[type=checkbox]", attribs) ]),
					m("td", { style: { textDecoration: task.done ? "line-through" : "none" }}, task.description)
				]);
			}))
		]);
	}

	private function todo_add(delay = 0) {
		// For testing purposes
		#if !server
		todoAdding = true;
		// First redraw to display the loading text:
		M.redraw();
		// Wait for request to finish:
		Timer.delay(function() { 
			todo.add(todo.description);
			// Request completed, set appropriate state:
			todo.description = "";
			todoAdding = false;
			M.redraw();
		}, delay);
		#end
	}

	private function todo_setDescription(e : KeyboardEvent) {
		var input : InputElement = cast e.target;
		todo.description = input.value;
		if (e.keyCode == 13) todo_add();
	}

	private function setTaskStatus(task : Todo, checked : Bool) {
		task.done = checked;
		todo.save();
	}
}