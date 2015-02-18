# Mithril for Haxe

[Mithril](http://lhorie.github.io/mithril/index.html) is a nice little javascript MVC framework with lots of power under the hood. Here's the Haxe version, of course with some useful extra features thanks to macros and the type inference.

# Installation

The normal procedure: `haxelib install mithril` and then `-lib mithril` in your .hxml file.

# How to use

Mithril has a great [getting started guide](http://lhorie.github.io/mithril/getting-started.html) and an astounding amount of documentation, so I'll only highlight the key differences here.

## Use M, not m!

The biggest difference! `import mithril.M` then use `M` instead of `m` for the whole API. The only exception is when building the DOM tree with `m()`, if you want autocompletion you need to use lowercase m for that (though uppercase is still supported).

You'll want to implement some interfaces as well to take advantage of the macro features:

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

**NOTE:** `@prop` and `M.prop` doesn't work well with Haxe serialization, so if you're using `haxe.Serializer` on a class like this, you cannot have such a property as a class field.

## Controllers

The Controller interface is simple:

```haxe
import mithril.M;

class Todo implements Controller<Todo>
{
    public function new() {}

    // The interface implementation.
    // It will automatically return "this" unless you specify otherwise.
    public function controller() : Todo {
    }
}
```

## Views

```haxe
class TodoView implements View
{
    var model : Array<Todo>;

    public function new(model) {
        this.model = model;
    }

    // The interface implementation:
    public function view() : VirtualElement {
        // Remember to use "m" here instead of "M" for autocompletion.
		// The last m() expression (or Array of m()) is returned automatically.
        m("div", [
            m("h1", "Welcome!"),
            m("table", model.map(function(todo) {
                m("tr", [
                    m("td", m("input[type=checkbox]", { checked: todo.done() })),
                    m("td", todo.description())
                ]);
            }))
        ]);
    }
}
```

If you want to use another object as controller, for example when composing a module from different objects, implement `ControllerView`:

```haxe
class TodoView implements ControllerView<TodoController>
{
    var model : Array<Todo>;

    public function new(model) {
        this.model = model;
    }

    public function view(?ctrl : TodoController) : VirtualElement {
        m("div", [
            m("h1", "Welcome!"),
            m("table", model.map(function(todo) {
                m("tr", [
                    m("td", m("input[type=checkbox]", { checked: todo.done() })),
                    m("td", todo.description())
                ]);
            }))
        ]);
    }
}
```

For simple or tightly coupled components, it's common to put the view and controller together in a Module:

## Modules

```haxe
import mithril.M;
import js.Browser;

class TodoModule implements Module<TodoModule>
{
    public function new() {
    }

    public function controller() {
        // Do controller things here, managing child views for example.
    }

    // The argument to view() will be "this" in a Module, so you don't
    // have to specify it unless you want to use it explicitly.
    public function view() {
        m("h1", "Hello world!");
    }

    // Finally, here's how to start everything:
    static function main() {
        M.module(Browser.document.body, new TodoModule());
    }
}
```

That should hopefully be enough for you to get started. Remember, plenty of documentation over at the [Mithril](http://lhorie.github.io/mithril/index.html) site.

# Haxe examples

After [installing Haxe](http://haxe.org/download/), this repo has some examples that can be interesting to test. Clone it, open a prompt in the directory and execute:

`haxelib install mithril`

Then select one of the following:

## Some small apps

A collection of two demo apps, available on the Mithril site.

1. `haxe mithril.hxml`
1. Open `bin/index.html` in a browser.

## Webshop

A simple (and incomplete) webshop to demonstrate the power of Mithril.

1. `haxe webshop.hxml`
1. Open `bin/webshop/index.html` in a browser.

## From scratch

If you prefer a bare-bones example (doesn't require cloning), create the following two files and follow the instructions below:

**index.html**

```html
<!doctype html>
<body>
<script src="http://cdnjs.cloudflare.com/ajax/libs/mithril/0.1.28/mithril.min.js"></script>
<script src="example.js"></script>
</body>
```

**Example.hx**

```haxe
package;
import mithril.M;

class User implements Model
{
    @prop public var name : String;

    public function new(name) {
        // Using M.prop, this.name is now a method similar to
        // jQuery's methods. If called with no parameters the
        // value is returned, otherwise the value is set.
        this.name = M.prop(name);
    }
}

class Example implements Module<Example>
{
    var user : User;

    public function new() {}

    public function controller() {
        this.user = new User("Thorin Oakenshield");
    }

    public function view() {
        // Display an input field.
        m("input", {
            // Listens to the "onchange" event of the field and will
            // set user.name with the fields "value" attribute.
            onchange: M.withAttr("value", user.name),
            // The redraw triggered by the onchange event will
            // get and display the latest value automatically.
            value: user.name()
        });
    }

    // Program entry point
    static function main() {
        M.module(js.Browser.document.body, new Example());
    }
}
```

Compile and run with:

1. `haxe -lib mithril -js example.js -main Example`
1. Open index.html in a browser.

## Node.js

Without too much hassle, it's possible to render a Mithril module/view serverside on Node.js. The repo contains two examples for that. Execute the following:

1. `npm install`
1. `haxelib install nodehx`
1. `haxe noderendering.hxml`
1. `cd bin`

### Example 1: Simple rendering

`node noderendering.js` outputs a simple HTML rendering example.

### Example 2: Isomorphic code

`node noderendering.js server`

Starts a server on [http://localhost:6789](http://localhost:6789) that executes the same code on server and client. The server generates the HTML so the page is percieved to load quickly, then the client enables the functionality. Check [this article](http://artsy.github.io/blog/2013/11/30/rendering-on-the-server-and-client-in-node-dot-js/) for more about isomorphic code.

# Feedback please!

This is an early version, so feedback is always welcome! [Open an issue](https://github.com/ciscoheat/mithril-hx/issues) and give me a piece of your mind. :)
