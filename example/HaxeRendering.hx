package ;

import mithril.M;
import mithril.M.Module;
using StringTools;

class HaxeRendering
{
	static function main() {
		displayTodo();
	}	

	static function displayTodo() {
		var todoList = new TodoModule();

		todoList.todo.add("First one");
		todoList.todo.add("Second one");

		todoList.todo.list[0].done = true;

		Sys.println(M.render(todoList.view(todoList)));
	}
}