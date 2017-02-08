import haxe.Timer;
import haxe.Serializer;
import haxe.Unserializer;

using Lambda;

// Allow TodoList to change properties ("friend")
@:allow(TodoList)
class Todo
{
	public var description(default, null) : String;
	public var done(default, null) : Bool;

	public function new(description, done = false) {
		this.description = description;
		this.done = done;
	}
}

class TodoList
{
	var list : Array<Todo>;

	public function new() {
		this.list = [];
	}

	public function iterator() {
		return list.iterator();
	}

	public function add(description : String) {
		if (description == null || description.length == 0) return;
		list.push(new Todo(description));
		save();
	}
	
	public function setStatus(todo : Todo, done : Bool) {
		list.find(function(t) return todo == t).done = done;
		save();
	}

	public function clear() {
		list.splice(0, list.length);
		save();
	}
	
	///// Load/save to localStorage /////

	#if !server
	static var storage = js.Browser.window.localStorage;
	#end

	public static function load() : TodoList {
		#if !server
		return try {			
			cast Unserializer.run(storage.getItem("todo-app-list"));
		} catch (e : Dynamic) { 
			new TodoList();
		}
		#else
		return new TodoList();
		#end
	}

	public function save() : Void {
		#if !server
		storage.setItem("todo-app-list", Serializer.run(this));
		#end
	}
}
