package webshop;

import js.Browser;
import mithril.M;
import webshop.models.*;
using Lambda;
using StringTools;

/**
 * A simple webshop to demonstrate the power of Mithril.
 */
class Webshop implements View
{
    var cart : ShoppingCart;
    var menu : Menu;
    var search : Search;
    var checkout : Checkout;
    var routes : Dynamic;

    // Create menu and routes.
    public function new() {
        menu = new Menu();
        cart = new ShoppingCart();
        search = new Search();

        routes = {
            "/": this,
            "/category/:categoryId": new ProductList(cart),
            "/product/:productId": new ProductPage(cart),
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
        M.mount(element("search"), search);

        // An "inline module" just to create the home link.
        M.mount(element("home-link"), {
            view: function() 
                m("a.navbar-brand[href='/']", {config: M.route}, "Mithril/Haxe Webshop")
        });
    }

    // Welcome text for the default route
    public function view() [
        H1("Welcome!"),
        P("Select a category on the left to start shopping."),
        P("Built in Haxe & Mithril. Source code: ", 
            A[href="https://github.com/ciscoheat/mithril-hx/tree/master/example/webshop"][target="_blank"](
                "https://github.com/ciscoheat/mithril-hx/tree/master/example/webshop"
        )),
        H2("Todo"),
        UL.list-group(todo().map(function(t) {
            var done = t.toLowerCase().startsWith("x ");
            LI.list-group-item({ 
                style: { textDecoration: done ? "line-through" : "none" }
            }, [
                INPUT[type=checkbox]({ checked: done ? "checked" : "" }), 
                SPAN[style='margin-left:5px'](done ? t.substring(2) : t)
            ]);
        }))
    ];

    private function element(id : String) {
        return Browser.document.getElementById(id);
    }

    ///////////////////////////

    function todo() {
        return [
            "Checkout page",
            "Thank you page",
            "x Make cart not change size when open and items are deleted",
            "Enable use of arrow keys when navigating search results",
            "URL slugs for products",
            "Fix css for navbar and cart for low-res devices",
            "Administration section..."
        ];
    }

    // Program entry point
    static function main() {
        new Webshop().start();
    }
}
