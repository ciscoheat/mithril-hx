package webshop;

import js.html.Element;
import js.html.MouseEvent;
import mithril.M;
import webshop.models.*;
using Lambda;

/**
 * Product listing for a Category.
 */
class ProductList implements Mithril
{
    var category = new Category();
    var loading = new Loader();
    var cart : ShoppingCart;

    public function new(cart) {
        this.cart = cart;
    }

    public function onbeforeupdate(vnode : VNode<ProductList>) {
        //trace('onbeforeupdate ProductList');
        trace(vnode.attrs);

        // Get category based on the current route.
        var getCurrentCategory = function(categories : Array<Category>) {
            return categories.find(function(c) return c.slug() == vnode.attrs.categoryId);
        };

        // Load products with an Ajax request.
        // It has background = true to allow navigation to update, so a call 
        // to M.redraw (executed in loading.done) is required when it finishes.
        Category.all().then(function(c) { 
            category = getCurrentCategory(c);
            loading.done();
            trace('New category loaded: ' + category.name);
            M.redraw();
        }, 
            loading.error
        );
    }

    function cart_add(e : MouseEvent, p : Product) {
        cart.add(p);
        cart.open();
    }

    public function view() {
        var template = switch(loading.state()) {
            case Started: m("h2.sub-header", "");
            case Delayed: m("h2.sub-header", "Loading...");
            case Error: m("h2.sub-header", {style: {color: "red"}}, "Loading error, please reload page.");
            case Done: null;
        }
		
		return if(template != null) template else [
            m('H2.sub-header', category.name),
            m('div.table-responsive', [
                m('table.table.table-striped', [
                    m('thead', [
                        m('tr', [
                            m('th', "Name"),
                            m('th', "Price"),
                            m('th', "Stock"),
                            m('th', null)
                        ])
                    ]),
                    m('tbody[id=products]', category.products.map(function(p) 
                        m('tr', [
                            m('td', m('a', {
                                href: '/product/${p.id}',
                                oncreate: M.routeLink
                            }, p.name)),
                            m('td', p.price >= 0 ? '$$${p.price}' : ""),
                            m('td', {style: {color: p.stock < 10 ? "red" : ""}}, Std.string(p.stock)),
                            m('td', p.stock == 0 ? null :
                                m('button.btn.btn-success.btn-xs', {
                                    onclick: cart_add.bind(_, p)
                                }, [
                                    m('span.glyphicon.glyphicon-shopping-cart', {"aria-hidden": "true"}),
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