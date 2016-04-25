# Mithril for Haxe

[Mithril](http://lhorie.github.io/mithril/index.html) is a small, yet great javascript MVC framework that is faster and more flexible than most others. Here's the [Haxe](http://haxe.org/) version, with some useful extra features thanks to macros and the type inference.

# Installation

Standard procedure: `haxelib install mithril` and then `-lib mithril` in your .hxml file.

# How to use

Mithril has a great [getting started guide](http://lhorie.github.io/mithril/getting-started.html) and an astounding amount of documentation, so I'll only highlight what you need to get started with the Haxe version here.

## Use M, not m!

The biggest difference! `import mithril.M` then use `M` instead of `m` for the whole API. The only exception is when using `m()`, if you want autocompletion you must use lowercase m for that (uppercase still works).

## Implement one of the following interfaces

Because Javascript is so dynamic and Haxe is strongly typed, there will be a shifting balance between flexibility and compiler safety. When using Mithril, you will create objects that will be used in calls to for example `M.mount` or `M.route`. For those objects it is **required** to implement one of the following interfaces. When doing that you will also be able to take advantage of some nice macro features:

* Simple syntax for `M.prop`
* Automatically return `this` in `controller` methods
* Automatically return `m()` in any function.
* Sugartags syntax

## Sugartags syntax?

There is a nice alternative syntax for templates that you can use instead of `m(...)`. It looks like this:

```haxe
DIV([
    H1[id=welcome]("Welcome!"),
    TABLE.some-class(todos.map(function(todo)
        TR([
            TD(INPUT[type=checkbox]({ checked: todo.done() })),
            TD(todo.description())
        ])
    ))
]);
```

The syntax is simple, just replace `m('tag', ...)` with `TAG(...)`, where TAG is a valid HTML5 tag. There are two compiler directives that you can use in your `.hxml` file to configure it:

`-D lowercase-mithril-sugartags` - If you don't like UPPERCASE tags. Understandable, but increases the risk for compilation errors since the lowercase tags may collide with variables.

`-D no-mithril-sugartags` - To turn off this syntax completely, and only use `m('tag', ...)` for building view templates.

Based on [mithril.sugartags](https://github.com/jsguy/mithril.sugartags) by jsguy. Thanks!

# Going typesafe or flexible

If you're a seasoned Mithril user and/or just want to keep things simple and dynamic, skip to "The loosely-typed path" below. Otherwise keep reading for some helpful examples and more strict interfaces.

## The typesafe path

### Model

With this interface (and all others) you can use `@prop` for the fields:

```haxe
import mithril.M;

class Todo implements Model
{
    // Will create an M.prop(false)
    @prop public var done : Bool = false;

    // Will create an M.prop(null)
    @prop public var description : String;

    public function new(description) {
        // If you need to create it in the constructor:
        this.description = M.prop(description);
    }
}
```

**NOTE:** `@prop` and `M.prop` doesn't work well with Haxe serialization, so if you're using `haxe.Serializer` on a class like this, you cannot have such a property as a class field.

## View

Use the View interface when you have a `view()` method in the object and want it to be a View. (Note that a [MVC View is an object](https://groups.google.com/d/msg/object-composition/glaWzT7yJJY/WlDPe60pTnIJ), so don't confuse a view template or a function named view with a real MVC View.)

```haxe
class TodoView implements View
{
    var model : Array<Todo>;

    public function new(model) {
        this.model = model;
    }

    // The interface implementation.
    // The last m() expression (or Array of m()) is returned automatically.
    public function view() : VirtualElement {
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

## Controller

The Controller interface is simple, and when you implement it the `controller()` method will automatically return "this" (required for Mithril to work properly).

```haxe
import mithril.M;

class Todo implements Controller<Todo>
{
    public function new() {}

    // The interface implementation.
    // It will automatically return "this" unless you specify otherwise.
    public function controller() : Todo {
        // Called only once in the Component lifecycle, before rendering.
        // Do controller things here, managing child views for example.
    }
}
```

## Component

[Components](http://lhorie.github.io/mithril/mithril.component.html) are new from version 0.2.0 of Mithril, and is a way to encapsulate functionality into reusable units. There is a slight mismatch between them and traditional Haxe objects, again because of the dynamic, "classless" nature of Mithril and Javascript.

The `Component` interface is also very simple:

```haxe
interface Component {
    function controller() : Dynamic;
    function view() : ViewOutput;
}
```

Implemented in a Haxe class, it could look like this:

```haxe
import mithril.M;
import js.Browser;

class Todo implements Component
{
    // Model
    var todos : Array<Todo>;

    public function new(todos) {
        this.todos = todos;
    }

    // One part of the Component interface:
    public function controller() {
        // Not much to do here in this simple example.
    }

    // The other part of the Component interface:
    public function view() {
        H1("Hello world!", /* Render Todos */);
    }

    // Starting up with M.mount:
    static function main() {
        M.mount(Browser.document.body, new Todo());
    }
}
```

The `controller` method works like a constructor in plain-js Mithril, but in Haxe most things you need could be passed to the real constructor instead. Because of that you may not need the [parameterized components](http://mithril.js.org/mithril.component.html#parameterized-components) feature and such. In that case, as in the class above, just implement `Component` and you're done. If the `controller` method won't do anything however, you can implement `View` instead, or keep reading for an alternative.

## The loosely-typed path

If you think that the `view` and `controller` methods are simple enough to implement without relying on a specific interface, or if you want to use some more advanced Component stuff, there's an easy way out:

### Mithril

Just implement Mithril and you can forget all the interface stuff above. :) Like this example:

```haxe
import mithril.M;
import js.Browser;

class HelloWorld implements Mithril
{
    public function new() {}

    public function controller(?args : {color: String}) 
        if(args == null) args = {color: "red"};

    public function view(ctrl, args : {color : String})
        H1({style: {color: args.color}}, "Hello world!");

    static function main() {
        var hello = M.component(new HelloWorld(), {color: "teal"});
        M.mount(Browser.document.body, hello);
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
1. `nekotools server -d bin`
1. Open [http://localhost:2000/](http://localhost:2000/) in a browser.

## Webshop

A simple (and incomplete) webshop to demonstrate the power of Mithril.

1. `haxe webshop.hxml`
1. `nekotools server -d bin/webshop`
1. Open [http://localhost:2000/](http://localhost:2000/) in a browser.

**Live demo here:** [http://ciscoheat.github.io/webshop](http://ciscoheat.github.io/webshop)

## From scratch

If you prefer a bare-bones example (doesn't require cloning), create the following two files and follow the instructions below:

**index.html**

```html
<!doctype html>
<body>
<script src="http://cdnjs.cloudflare.com/ajax/libs/mithril/0.2.3/mithril.min.js"></script>
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

class Example implements Component
{
    var user : User;

    public function new() {}

    public function controller() {
        this.user = new User("Thorin Oakenshield");
    }

    public function view() [
        // Display an input field.
        INPUT({
            // Listens to the "oninput" event of the input field and
            // will set user.name to the field's "value" attribute:
            oninput: M.withAttr("value", user.name),

            // The redraw triggered by the above event will
            // update the value from the model automatically:
            value: user.name()
        }),
        
        // Display a div with class .user and some style
        DIV.user({style: {margin: "15px"}}, user.name())
    ];

    // Program entry point
    static function main() {
        M.mount(js.Browser.document.body, new Example());
    }
}
```

Compile and run with:

1. `haxe -lib mithril -js example.js -main Example`
1. Open index.html in a browser.

## Server side - All targets

The rendering part of Mithril has been ported to Haxe, so you can now enjoy writing Mithril templates, and have them rendered to HTML anywhere. You can test it like this:

`haxe serverrendering.hxml`

And here's a class if you want to get started:

```haxe
import mithril.MithrilNodeRender;
import mithril.M.m;

class Main {
	static function main() {
		var view = m("ul", [
			m("li", "item 1"),
			m("li", "item 2"),
		]);

		// <ul><li>item 1</li><li>item 2</li></ul>
		Sys.println(new MithrilNodeRender().render(view)); 
	}
}
```

## Server side - Node.js, routes & isomorphism

Without too much hassle, it's possible to render a Mithril component/view serverside on Node.js, using the Mithril routes both on client and server. Execute the following:

1. `npm install`
1. `haxelib install hxnodejs`
1. `haxe noderendering.hxml`
1. `cd bin`

### Example 1: Simple rendering

`node noderendering.js` outputs a simple HTML rendering example.

### Example 2: Isomorphic code

`node noderendering.js server`

Starts a server on [http://localhost:6789](http://localhost:6789) that executes the same code on server and client. The server generates the HTML so the page is percieved to load quickly and search engines can index it, then the client enables the functionality.
# Feedback please!

Feedback is always welcome! [Open an issue](https://github.com/ciscoheat/mithril-hx/issues) and give me a piece of your mind. :)
