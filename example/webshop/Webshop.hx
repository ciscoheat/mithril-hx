package webshop;

#if js
import js.Browser;
#end
import mithril.M;
import webshop.models.*;
using Slambda;
using StringTools;

/**
 * A simple webshop to demonstrate the power of Mithril.
 */
class Webshop implements Mithril
{
	#if js
    var cart : ShoppingCart;
    var routes : Dynamic;
    var menu : Menu;

    // Create menu and routes.
    public function new(categories : Array<Category>) {
        cart = new ShoppingCart();
        menu = new Menu(categories);
        
        /*
        {
            onmatch: function(params : haxe.DynamicAccess<String>, url : String) 
                productList.changeCategory(params.get('categoryId')),
            render: function(vnode) return m(productList)
        }
        */

        routes = {
            "/": this,
            "/category/:key": new ProductList(menu, cart, categories),
            "/product/:key": new ProductPage(menu, cart),
            "/checkout": new Checkout(cart)
        };
    }

    // Call to start the whole site.
    public function start() {
        // Define routes for the main page content
        M.route(element("content"), "/", routes);

        // Define modules that should not change if the main content changes
        M.mount(element("navigation"), menu);
        M.mount(element("shopping-cart"), cart);
        M.mount(element("search"), new Search());

        // An "inline module" just to create the home link.
        M.mount(element("home-link"), {
            view: function() 
                m("a.navbar-brand[href='/']", {oncreate: M.routeLink}, "Mithril/Haxe Webshop")
        });
    }

    private inline function element(id : String) {
        return Browser.document.getElementById(id);
    }

    // Program entry point
    static function main() {
        Category.all().then(function(categories) {
            new Webshop(categories).start();
        });
    }

	#else
	public function new() {}
	#end

    // Welcome text for the default route
    public function view() [
        m('H1', "Welcome!"),
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
                m('input[type=checkbox]', { checked: done ? "checked" : "" }),
                m("span[style='margin-left:5px']", (done ? t.substring(2) : t))
            ]);
        }))
    ];

    function todo() return [
        "Checkout page",
        "Thank you page",
        "x Make cart not change size when open and items are deleted",
        "Enable use of arrow keys when navigating search results",
        "URL slugs for products",
        "Fix css for navbar and cart for low-res devices",
        "Administration section..."
    ];
}
