# Mithril for Haxe

[Mithril](http://lhorie.github.io/mithril/index.html) is a nice little javascript MVC framework with lots of power under the hood. Here's the Haxe version, of course with some improvements thanks to macros and the type inference.

# Installation

The normal procedure: `haxelib install mithril` and then `-lib mithril` in your .hxml file.

# How to use

Mithril has a great [getting started guide](http://lhorie.github.io/mithril/getting-started.html) and an astounding amount of documentation, so I'll only highlight the key differences here.

## Use M, not m!

The biggest difference! `import mithril.M` then use `M` instead of `m` in the documentation. You want to implement some interfaces as well to take advantage of the macro magic:

## Models

The simplest way to create a model is to use `@prop` for the fields and `M.prop` in the constructor:

```haxe
import mithril.M;

class Todo implements Model
{
	@prop public var description : String;
	@prop public var done : Bool;

	public function new(description) {
		this.description = M.prop(description);
		this.done = M.prop(false);
	}
}
```

`@prop` is available on all interfaces but the most obvious use is in a Model.

## Controllers

The Controller interface is simple:

```haxe
import mithril.M;

class Todo implements Controller
{
	public function new() {}

    // The interface implementation.
	public function controller() : Dynamic {
	}
}
```

## Views

**NOTE:** Mithril seems to have problems with Haxe's `List`, use `Array` instead.

```haxe
class TodoView implements View<TodoController>
{
    // Use Array, not List.
    var model : Array<Todo>;

    public function new() {
        this.model = [new Todo("first"), new Todo("second")];
    }

    // The interface implementation.
    public function view(ctrl : TodoController) : VirtualElement {
        // Use M just as m:
        return M("div", [
            M("h1", "Welcome!"),
            M("table", model.map(function(todo) {
                return M("tr", [
                    M("td", [ M("input[type=checkbox]", { checked: todo.done() }) ]),
                    M("td", todo.description())
                ]);
            }))
        ]);
    }
}
```

For simple or tightly coupled components, it's common to put together the view and controller in a Module:

## Modules

```haxe
import mithril.M;
import js.Browser;

class TodoModule implements Module<TodoModule>
{
	public function new() {
	    ...
	}

	public function controller() : Dynamic {
	    ...
	}

	// The argument to view() will be "this" in a Module,
	// so it's not needed.
	public function view(_) : VirtualElement {
	    ...
	}

	// Finally, here's how to start everything:
	static function main() {
	    M.module(Browser.document.body, new TodoModule());
	}
}
```

That should hopefully be enough for you to get started. Remember, plenty of documentation over at the [Mithril](http://lhorie.github.io/mithril/index.html) site.

# Haxe examples

This repo contains a basic example so clone it, compile and run `bin/index.html` in your browser.

If you want to test from scratch, here's a useful html template:

```html
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8"/>
	<title>Mithril</title>
</head>
<body>
	<script src="//cdnjs.cloudflare.com/ajax/libs/mithril/0.1.24/mithril.min.js"></script>
	<script src="YOUR_HAXE_FILE.js"></script>
</body>
</html>
```

# Feedback please!

This is an early version, so feedback is always welcome! [Open an issue](https://github.com/ciscoheat/mithril-hx/issues) and give me a piece of your mind. :) Macro suggestions are very welcome!
