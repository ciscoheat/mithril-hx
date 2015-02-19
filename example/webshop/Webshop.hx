package webshop;

import js.Browser;
import mithril.M;
import webshop.models.*;
import jQuery.*;
using Lambda;
using StringTools;

/**
 * A simple webshop to demonstrate the power of Mithril.
 */
class Webshop implements Module<Dynamic>
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
        M.module(element("navigation"), menu);
        M.module(element("shopping-cart"), cart);
        M.module(element("search"), search);

        // An "inline module" just to create the home link.
        M.module(element("home-link"), {
            view: function() 
                m("a.navbar-brand[href='/']", {config: M.route}, "Mithril Webshop")
        });
    }

    // Welcome text for the default route
    public function view(?ctrl : Dynamic) : ViewOutput {
        return [
            m("h1.page-header", "Welcome!"),
            m("p", "Select a category on the left."),
            m("h2", "Todo"),

            m("ul.list-group", todo().map(function(t) {
                var done = t.toLowerCase().startsWith("x ");
                m("li.list-group-item", 
                    { style: { textDecoration: done ? "line-through" : "none" }},
                    [
                        m("input[type=checkbox]", { checked: done ? "checked" : "" }), 
                        m("span[style='margin-left:5px']", done ? t.substring(2) : t)
                    ]
                );
            }))
        ];
    }

    public function controller() : Dynamic {
    }

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
