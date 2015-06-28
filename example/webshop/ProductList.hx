package webshop;

import js.html.Element;
import js.html.MouseEvent;
import mithril.M;
import webshop.models.*;
using Lambda;

/**
 * Product listing for a Category.
 */
class ProductList implements Component
{
    @prop var category : Category;
    var loading : Loader;
    var cart : ShoppingCart;

    public function new(cart) {
        this.category = M.prop(new Category());
        this.cart = cart;
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
            H2.sub-header(category().name),
            DIV.table-responsive([
                TABLE.table.table-striped([
                    THEAD([
                        TR([
                            TH("Name"),
                            TH("Price"),
                            TH("Stock"),
                            TH()
                        ])
                    ]),
                    TBODY[id=products](category().products.map(function(p) 
                        TR([
                            TD(A({
                                href: '/product/${p.id}',
                                config: M.route
                            }, p.name)),
                            TD(p.price >= 0 ? '$$${p.price}' : ""),
                            TD({style: {color: p.stock < 10 ? "red" : ""}}, Std.string(p.stock)),
                            TD(p.stock == 0 ? null :
                                BUTTON.btn.btn-success.btn-xs({
                                    onclick: cart_add.bind(_, p)
                                }, [
                                    SPAN.glyphicon.glyphicon-shopping-cart({"aria-hidden": "true"}),
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