package webshop;

import js.html.Element;
import js.html.MouseEvent;
import mithril.M;
import webshop.models.*;
using Lambda;

/**
 * Product listing for a Category.
 */
class ProductList implements Module<ProductList>
{
    @prop var category : Category;
    var loading : Loader;
    var cart : ShoppingCart;
    var menu : Menu;

    public function new(cart, menu) {
        this.category = M.prop(new Category());
        this.cart = cart;
        this.menu = menu;
    }

    public function controller() {
        loading = new Loader();

        // Get category based on the current route.
        var getCurrentCategory = function(categories : Array<Category>) {
            return categories.find(function(c) return c.slug() == M.routeParam("categoryId"));
        };

        // Load products with an Ajax request.
        // It has background = true to allow navigation to update, so a call 
        // to M.redraw (executed in loading.done) is required when it finishes.
        Category.all().then(function(c) { 
            category(getCurrentCategory(c));
            menu.active(category());
            loading.done();
        }, 
            loading.error
        );
    }

    function cart_add(e : MouseEvent, p : Product) {
        cart.add(p);
        cart.open();
    }

    public function view() : ViewOutput {
        switch(loading.state()) {
            case Started:
                return null;
            case Delayed:          
                return m("h2.sub-header", "Loading...");
            case Error:
                return m("h2.sub-header", {style: {color: "red"}}, "Loading error, please reload page.");
            case Done:
        }

        [
            m("h2.sub-header", category().name),
            m(".table-responsive", [
                m("table.table.table-striped", [
                    m("thead", [
                        m("tr", [
                            m("th", "Name"),
                            m("th", "Price"),
                            m("th", "Stock"),
                            m("th")
                        ])
                    ]),
                    m("tbody#products", category().products.map(function(p) 
                        m("tr", [
                            m("td", m("a", {
                                href: '/product/${p.id}',
                                config: M.route
                            }, p.name)),
                            m("td", p.price >= 0 ? '$$${p.price}' : ""),
                            m("td", {style: {color: p.stock < 10 ? "red" : ""}}, Std.string(p.stock)),
                            m("td", p.stock == 0 ? null :
                                m("button.btn.btn-success.btn-xs", {
                                    onclick: cart_add.bind(_, p)
                                }, [
                                    m("span.glyphicon.glyphicon-shopping-cart", {"aria-hidden": "true"}),
                                    cast "Add to cart" // Need a cast since mixed Arrays aren't valid.
                                ])
                            )
                        ])
                    ))
                ])
            ])
        ];
    }
}