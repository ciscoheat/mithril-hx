import mithril.MithrilNodeRender;

class ServerRendering
{
	static function main() {
		var todoList = new TodoModule();

		todoList.todo.add("First one");
		todoList.todo.add("Second <one>");

		todoList.todo.list[0].done = true;

		Sys.println(new MithrilNodeRender().render(todoList.view()));
	}
}
