import haxe.Timer;
import mithril.M;
import mithril.M.m;
import TodoList;

#if !server
import js.Browser;
import js.html.InputElement;
import js.html.KeyboardEvent;
#else
// "js" types aren't available on every server target.
// If not, they are defined as Dynamic.
// If the server runs only on Node.js, this isn't required.
typedef Browser = Dynamic;
typedef KeyboardEvent = Dynamic;
typedef InputElement = Dynamic;
#end

// Controller and View
class TodoComponent implements Mithril
{
	var todos : TodoList;
	var inputBox : String;
	var waitingForServer : Bool;

	public function new(todos : TodoList) {
		this.todos = todos;
	}

	public function clear() {
		todos.clear();
	}

	public function view() {
		m("div", [
			m("input", {
				value: inputBox,
				onkeyup: inputBoxChange
			}),
			// The add button has a one second delay to simulate a slow ajax request.
			m("button", { onclick: addTodo.bind(1000) }, "Add"),
			m("span", {style: {display: waitingForServer ? "" : "none"}}, " Adding..."),
			// Using array comprehension here: https://haxe.org/manual/lf-array-comprehension.html
			m("table", [for(todo in todos) 
				m("tr", [
					m("td", m("input[type=checkbox]", { 
						onclick: M.withAttr("checked", todos.setStatus.bind(todo)),
						checked: todo.done
					})),
					m("td", { style: { textDecoration: todo.done ? "line-through" : "none" }}, todo.description)
				])
			])
		]);
	}

	function addTodo(delay = 0) {
		// The delay is for demonstration purposes, and the preprocessor directive is 
		// to avoid referencing Timer on server. Otherwise this would have been much simpler.
		#if !server
		waitingForServer = true;
		Timer.delay(function() { 
			todos.add(inputBox);
			inputBox = "";
			waitingForServer = false;
			M.redraw();
		}, delay);
		#end
	}

	function inputBoxChange(e : KeyboardEvent) {
		var input : InputElement = cast e.target;
		inputBox = input.value;
		if (e.keyCode == 13) addTodo();
	}
}