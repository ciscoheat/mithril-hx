package webshop;

import js.Browser;
import mithril.M;
import webshop.models.*;
import jQuery.*;
using Lambda;

/**
 * A simple webshop to demonstrate the power of Mithril.
 */
class Webshop implements Module<Webshop>
{
    var cart : ShoppingCart;
    var menu : Menu;
    var search : Search;
    var routes : Dynamic<MithrilModule<Dynamic>>;

    // Create menu and routes.
    public function new() {
        menu = new Menu();
        cart = new ShoppingCart();
        search = new Search();

        var productList = new ProductList(cart);

        routes = {
            "/": this,
            "/category/:categoryId": productList,
            "/category/:categoryId/:productId": productList
        };
    }

    // Call to start the whole site.
    // Define the routes and render the menu and cart.
    public function start() {
        M.route(element("content"), "/", routes);

        M.module(element("navigation"), menu);
        M.module(element("shopping-cart"), cart);
        M.module(element("search"), search);
    }

    public function controller() {}

    // Welcome text for the default route
    public function view() {
        return [
            m("h1.page-header", "Welcome!"),
            m("p", "Select a category on the left.")
        ];
    }

    private function element(id : String) {
        return Browser.document.getElementById(id);
    }

    ///////////////////////////

    // Program entry point
    static function main() {
        new Webshop().start();
    }
}
