package webshop;

#if js
import js.Browser;
#end
import mithril.M;
import webshop.models.*;

using StringTools;

/**
 * A simple webshop to demonstrate the power of Mithril.
 */
class Webshop implements Mithril
{
	//
	// Program entry point
	// With a preprocessor directive to support testing.
	//
	#if !buddy
    static function main() {
        Category.all().then(function(categories) {
            new Webshop(categories);
        });
    }
	
    public function new(categories : Array<Category>) {
        var cart = new ShoppingCart();
        var menu = new Menu(categories);
		
		var element = Browser.document.getElementById;
        
		// Note the key parameters in the routes: https://mithril.js.org/route.html#key-parameter
        var routes = {
            "/": this,
            "/category/:key": new ProductList(menu, cart, categories),
            "/product/:key": new ProductPage(menu, cart),
            "/checkout": new Checkout(cart)
        };
		
        // Routes for the main page content
        M.route.route(element("content"), "/", routes);

        // Define components that should not change if the main content changes
        M.mount(element("navigation"), menu);
        M.mount(element("shopping-cart"), cart);
        M.mount(element("search"), new Search());

        // An "inline component" just to create the home link.
        M.mount(element("home-link"), {
            view: function() 
                m(M.route.Link, {
                    "class": "navbar-brand",
                    href: '/'
                }, "Mithril/Haxe Webshop")
        });
    }
	#else
	public function new() {}
	#end

    public function view() [
        m('h1', "Welcome!"),
        m('p', "Select a category on the left to start shopping."),
        m('p', "Built in Haxe & Mithril. Source code: ", 
            m('a', 
                {href: "https://github.com/ciscoheat/mithril-hx/tree/master/example/webshop", target: "_blank"}, 
                "https://github.com/ciscoheat/mithril-hx/tree/master/example/webshop"
            )
        ),
        m('h2', "Todo"),
        m('ul.list-group', todo().map(function(t) {
            var done = t.toLowerCase().startsWith("x ");
            m('li.list-group-item', { 
                style: { textDecoration: done ? "line-through" : "none" }
            }, [
                m('input[type=checkbox]', { checked: done }),
                m("span[style='margin-left:5px']", (done ? t.substring(2) : t))
            ]);
        }))
    ];

    function todo() return [
        "x Mithril 2.0 library update",
        "x Make cart not change size when open and items are deleted",
        "Checkout page",
        "Thank you page",
        "Enable use of arrow keys when navigating search results",
        "URL slugs for products",
        "Fix css for navbar and cart for mobile devices",
        "Administration section..."
    ];
}
