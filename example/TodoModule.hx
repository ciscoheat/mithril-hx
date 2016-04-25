import haxe.Timer;
import mithril.M;

#if (js && !nodejs)
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
	#if (js && !nodejs)
	static var storage = Browser.window.localStorage;
	#end

	public static function load() : TodoList {
		#if (sys || nodejs)
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
		#if (js && !nodejs)
		var ser = new Serializer();
		ser.serialize(list);
		storage.setItem("todo-app-list", ser.toString());
		#end
	}
}

class TodoModule implements View
{
	public var todo : TodoList;

	var todoAdding : Bool;

	public function new() {
		this.todo = TodoList.load();
	}

	public function clear() {
		M.startComputation();
		todo.clear();
		M.endComputation();
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
		// M.startComputation is used automatically in a real call to 
		// m.request, but here it's simulated.
		todoAdding = true;
		// First redraw to display the loading text:
		M.redraw();
		// Wait for request to finish:
		M.startComputation();
		deferMs(delay)
		.then(function(ok) { todo.add(todo.description); return ok; }, function(error) return error)
		.then(function(_) {
			// Request completed, set appropriate state:
			todo.description = "";
			todoAdding = false;
			// End computation which will trigger a redraw unless more
			// computations are queued.
			M.endComputation();
		});
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

	private function deferMs(delay : Int) : Promise<Bool, Bool> {
		var d = M.deferred();
		#if js
		Timer.delay(d.resolve.bind(true), delay);
		#end
		return d.promise;
	}

	#if js
	static function main() {
		M.mount(Browser.document.body, new TodoModule());
	}
	#end
}