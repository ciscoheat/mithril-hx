# Mithril for Haxe

[Mithril](http://lhorie.github.io/mithril/index.html) is a nice little javascript MVC framework with lots of power under the hood. Here's the Haxe version, of course with some improvements thanks to macros and the type inference.

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

`@prop` is available on all interfaces but the most obvious use is in a Model.

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
class TodoView implements View<TodoController>
{
    var model : Array<Todo>;

    public function new() {
        this.model = [new Todo("first"), new Todo("second")];
    }

    // The interface implementation.
    public function view(ctrl : TodoController) : VirtualElement {
        // Remember to use "m" here instead of "M" for autocompletion:
        return m("div", [
            m("h1", "Welcome!"),
            m("table", model.map(function(todo) {
                return m("tr", [
                    m("td", [ m("input[type=checkbox]", { checked: todo.done() }) ]),
                    m("td", todo.description())
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

    public function controller() {
        ...
    }

    // The argument to view() will be "this" in a Module, so it's not that useful.
    public function view(_) {
        ...
    }

    // Finally, here's how to start everything:
    static function main() {
        M.module(Browser.document.body, new TodoModule());
    }
}
```

If you don't need the type safety, you can always implement the interface with `<Dynamic>`.

That should hopefully be enough for you to get started. Remember, plenty of documentation over at the [Mithril](http://lhorie.github.io/mithril/index.html) site.

# Haxe examples

This repo contains a basic example so clone it, compile with `haxe mithril.js` and open `bin/index.html` in your browser.

If you want a bare-bones example, after [installing Haxe](http://haxe.org/download/) create the following two files and follow the instructions below:

**index.html**

```html
<!doctype html>
<body>
<script src="http://cdnjs.cloudflare.com/ajax/libs/mithril/0.1.24/mithril.min.js"></script>
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
        this.name = M.prop(name);
    }
}

class Example implements Module<Example>
{
    var user : User;

    public function new() {}

    public function controller() {
        this.user = new User("John Doe");
    }

    public function view(_) {
        return m("input", {
            onchange: M.withAttr("value", user.name),
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

1. `haxelib install mithril`
1. `haxe -lib mithril -js example.js -main Example`
1. Open index.html in a browser.

# Node.js support!

Without much hassle, it's possible to render a Mithril module/view serverside on Node.js. The repo contains two examples. Execute the following in the cloned repo directory to compile:

1. `npm install`
1. `haxelib install nodehx`
1. `haxe noderendering.hxml`
1. `cd bin`

## Example 1: Simple rendering

`node noderendering.js` outputs a simple HTML rendering example.

## Example 2: Isomorphic code

`node noderendering.js server`

Starts a server on [http://localhost:6789](http://localhost:6789) that executes the same code on server and client. The server generates the HTML so the page is percieved to load quickly, then the client enables the functionality. Check [this article](http://artsy.github.io/blog/2013/11/30/rendering-on-the-server-and-client-in-node-dot-js/) for more about isomorphic code.

# Feedback please!

This is an early version, so feedback is always welcome! [Open an issue](https://github.com/ciscoheat/mithril-hx/issues) and give me a piece of your mind. :)
