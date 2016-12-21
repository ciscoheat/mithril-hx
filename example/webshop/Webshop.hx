package webshop;

#if js
import js.Browser;
#end
import mithril.M;
import webshop.models.*;
using Lambda;
using StringTools;

/**
 * A simple webshop to demonstrate the power of Mithril.
 */
class Webshop implements Mithril
{
	#if js
    var cart : ShoppingCart;
    var menu : Menu;
    var search : Search;
    var checkout : Checkout;
    var routes : Dynamic;

    // Create menu and routes.
    public function new() {
        search = new Search();
        cart = new ShoppingCart();
        
        var productList = new ProductList(cart);
        var productPage = new ProductPage(cart);

        menu = new Menu(productList, productPage);

        routes = {
            "/": this,
            "/category/:categoryId": productList,
            "/product/:productId": productPage,
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
                m("a.navbar-brand[href='/']", {oncreate: M.routeLink}, "Mithril/Haxe Webshop")
        });
    }

    private inline function element(id : String) {
        return Browser.document.getElementById(id);
    }

    // Program entry point
    static function main() {
        new Webshop().start();
    }

	#else
	public function new() {}
	#end

    // Welcome text for the default route
    public function view() { if(this.todo == null) trace('OBJECT SCHIZOPHRENIA');
        return [
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
    ];}

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
}
