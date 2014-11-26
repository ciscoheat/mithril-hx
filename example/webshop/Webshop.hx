package webshop;

import js.Browser;
import mithril.M;
import webshop.models.*;
import jQuery.*;
using Lambda;

///// View /////

class Menu implements Module<Menu>
{
    var categories : Iterable<Category>;

    public function new(categories) {
        this.categories = categories;
    }

    public function controller() {}

    public function view() {
        return m("ul.nav.nav-sidebar", categories.array().map(function(c) {
            return m("li", {"class": M.routeParam("categoryId") == c.id ? "active" : ""}, 
                m("a", {
                    href: '/category/${c.id}',
                    config: M.route
                }, c.name)
            );
        }));
    }

}

class ProductList implements Module<ProductList>
{
    var category : Category;
    var products : Array<Product>;

    public function new() {}

    public function controller() {
        var loadingProduct = new Product();
        loadingProduct.name = "Loading...";

        products = [loadingProduct];
        category = Category.get().find(function(c) 
            return c.id == M.routeParam("categoryId")
        );

        Product.getByCategory(category.id).then(function(p) {
            products = p;
            // getByCategory is a background request to allow the menu to change,
            // so redraw after it's finished.
            M.redraw();
        });
    }

    public function view() {
        return [
            m("h2.sub-header", category.name),
            m(".table-responsive", [
                m("table.table.table-striped", [
                    m("thead", [
                        m("tr", [
                            m("th", "#"),
                            m("th", "Name"),
                            m("th", "Price"),
                            m("th", "Stock")
                        ])
                    ]),
                    m("tbody#products", products.map(function(p) 
                        return m("tr", [
                            m("td", p.id),
                            m("td", p.name),
                            m("td", p.price),
                            m("td", {style: {color: p.stock < 10 ? "red" : ""}}, p.stock)
                        ])
                    ))
                ])
            ])
        ];
    }
}

class Webshop implements Module<Webshop>
{
    var menu : Menu;
    var routes : Dynamic<MithrilModule<Dynamic>>;

    public function new() {
        menu = new Menu(Category.get());
        routes = {
            "/": this,
            "/category/:categoryId": new ProductList()
        };
    }

    public function start() {
        route_init();
    }

    public function controller() {
    }

    public function view() {
        return [
            m("h1.page-header", "Welcome!"),
            m("p", "Select a category on the left.")
        ];
    }

    ///// Interactions /////

    function route_init() {
        M.route(Browser.document.getElementById("content"), "/", this.routes);
        menu_render();
    }

    function menu_render() {
        M.module(Browser.document.getElementById("navigation"), menu);
    }

    ///////////////////////////

    // Program entry point
    static function main() {
        new Webshop().start();
    }
}