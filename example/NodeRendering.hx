package ;

import mithril.M;

typedef MithrilNodeRenderer = VirtualElement -> String;

class NodeRendering
{
	static function require<T>(s : String) : T return untyped __js__('require(s)');
	static var console(default,null) : {log: Dynamic -> Void} = untyped __js__('console');

	static function main() {
		var render : MithrilNodeRenderer = require("mithril-node-render");
		var todoList = new TodoModule();

		todoList.todo.add("First one");
		todoList.todo.add("Second one");

		todoList.todo.list[0].done = true;

		console.log(render(todoList.view(todoList)));
	}	
}