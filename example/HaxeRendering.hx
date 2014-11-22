package ;

import mithril.M;

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

		Sys.println(M.instance.render(todoList.view(todoList)));
	}
}