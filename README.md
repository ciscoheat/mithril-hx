# Mithril for Haxe

[Mithril](http://mithril.js.org/) is a small, yet great javascript MVC framework that is faster and more flexible than most others. Here's the [Haxe](http://haxe.org/) version for Mithril 2, with some useful extra features thanks to macros and the type inference.

# Installation

Standard procedure: `haxelib install mithril` and then `-lib mithril` in your .hxml file.

# How to use

Mithril has a great introduction on its website and plenty of documentation, so I'll only highlight what you need to get started with the Haxe version here.

## Implement the Mithril interface

When using Mithril, you will create [components](http://mithril.js.org/components.html) that will be used with the Mithril API. The recommended way to create a component is using a class that implements the `Mithril` interface. Here's an example of a Mithril component:

```haxe
import mithril.M;

class TodoComponent implements Mithril
{
    var todos : Array<Todo>;

    public function new(todos) {
        this.todos = todos;
    }

    // When implementing Mithril, the last m() expression 
    // or Array of m() is returned automatically.
    public function view()
        m("div", [
            m("h1", "To do"),
            m("table", [for(todo in todos)
                m("tr", [
                    m("td", m("input[type=checkbox]", { 
                        onclick: e -> todo.done = e.target.checked,
                        checked: todo.done
                    })),
                    m("td", todo.description)
                ])
            ])
        ]);
}

/**
 * The model
 */
class Todo
{
    public var done : Bool;
    public var description : String;

    public function new(description, done = false) {
        this.description = description;
        this.done = done;
    }
}

class Main
{
    // Program entry point
    static function main() {
        var todos = [
            new Todo("Learn Haxe"),
            new Todo("??"),
            new Todo("Profit!")
        ];
        
        M.mount(js.Browser.document.body, new TodoComponent(todos));
    }
}
```

## The major API differences

- **Use M, not m!** `import mithril.M;`, then use `M` instead of `m` for the whole API. As you see above, the only exception is when using `m()`, you can use that without prefixing with `M`.
- `m.redraw.sync()` is available through `M.redrawSync()`.

### Upgrading from 1.x to 2.x

- The `M.route` methods can now be called as in the Mithril syntax, `M.route.param` etc. To call `M.route` however, use `M.route.route`.
- `M.withAttr` has been removed. Use an `e -> e.target` lambda function instead.

## When using Node.js

If you're using Node.js, you can install and use Mithril from npm instead of the Haxe port (see below for server side examples). To do that, define `-D mithril-native`.

## Side note: "this" is slightly different in native javascript

Because of the slight mismatch between Haxe classes and the classless Mithril structure, in [lifecycle methods](http://mithril.js.org/components.html#lifecycle-methods), the native javascript `this` points to `vnode.tag` instead of `vnode.state`. Otherwise it would have pointed to another object when inside instance methods.

This is usually nothing you have to worry about if you're using Haxe classes for your components and state. In that context, `this` works as expected.

# Haxe examples

This repo has some examples that can be interesting to test. Clone it, open a prompt in the directory and run:

`haxelib install mithril`

Then select one of the following:

## Some small apps

A collection of two demo apps, available on the Mithril site.

1. `haxe client.hxml`
1. `nekotools server -d bin`
1. Open [http://localhost:2000/](http://localhost:2000/) in a browser.

## Webshop

A simple e-commerce site to demonstrate the power of Mithril.

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
<script src="https://unpkg.com/mithril/mithril.js"></script>
<script src="example.js"></script>
</body>
```

**Example.hx**

```haxe
import mithril.M;

class User
{
    public var name : String;

    public function new(name) {
        this.name = name;
    }
}

class Example implements Mithril
{
    var user : User;

    public function new() {
        this.user = new User("Thorin Oakenshield");     
    }

    public function view() [
        // Display an input field
        m('input', {
            // Updates the model on input
            oninput: e -> user.name = e.target.value,

            // The redraw triggered by the oninput event will update
            // the input field value from the model automatically
            value: user.name
        }),
        
        // Display a div with class .user and some style
        m('.user', {style: {margin: "15px"}}, user.name)
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

The rendering part of Mithril has been ported to Haxe, so you can now enjoy writing Mithril templates and have them rendered to HTML anywhere. Here's a class to get you started:

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

(Note: The above code may not work in interp mode. Test it with neko instead.)

## Server side - Node.js & isomorphism

Without too much hassle, it's possible to render a Mithril component/view serverside on Node.js. Run the following in the repo directory:

1. `npm install`
1. `haxelib install hxnodejs`
1. `haxe server.hxml`
1. `cd bin`

### Example 1: Simple rendering

`node server.js` outputs a simple HTML rendering example.

### Example 2: Isomorphic code

`node server.js server`

Starts a server on [http://localhost:2000](http://localhost:2000) that executes the same code on server and client. The server generates the HTML so the page is perceived to load quickly and search engines can index it, then the client enables the functionality.

### Example 3: Cross-platform rendering

As a bonus, a Neko version of Example 1 will also be compiled. Test it with

`neko server.n`

The `MithrilNodeRender` is tested with [travix](https://github.com/back2dos/travix/) and should work on all targets. 

# Feedback please!

Feedback is always welcome! [Open an issue](https://github.com/ciscoheat/mithril-hx/issues) and give me a piece of your mind. :)
