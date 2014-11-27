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
    var menu : Menu;
    var routes : Dynamic<MithrilModule<Dynamic>>;

    // Create menu and routes.
    public function new() {
        menu = new Menu();
        routes = {
            "/": this,
            "/category/:categoryId": new ProductList()
        };
    }

    // Call to start the whole site.
    // Define the routes and render the menu.
    public function start() {
        M.route(element("content"), "/", routes);
        M.module(element("navigation"), menu);
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
