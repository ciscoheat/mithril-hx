package webshop;

import haxe.DynamicAccess;
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
    public var currentCategory(default, null) = new Category();

    var loader = new Loader();
    var cart : ShoppingCart;

    public function new(cart) {
        this.cart = cart;
    }

    public function onmatch(params : DynamicAccess<String>, url : String) {
        // Get category based on the current route.
        function getCurrentCategory(categories : Array<Category>) {
            return categories.find(function(c) return c.slug() == params.get('categoryId'));
        }

        loader.start();

        Category.all().then(function(c) { 
            currentCategory = getCurrentCategory(c);
            //trace('New category loaded: ' + currentCategory.name);
            loader.done();
        }, 
            loader.error
        );
    }

    function addToCart(e : MouseEvent, p : Product) {
        cart.add(p);
        cart.open();
    }

    public function render(vnode : VNode<ProductList>) {
        var template = switch(loader.state()) {
            case Started: m("h2.sub-header", "");
            case Delayed: m("h2.sub-header", "Loading...");
            case Error: m("h2.sub-header", {style: {color: "red"}}, "Loading error, please reload page.");
            case Done: null;
        }
		
		return if(template != null) template else [
            m('H2.sub-header', currentCategory.name),
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
                    m('tbody[id=products]', currentCategory.products.map(function(p) 
                        m('tr', [
                            m('td', m('a', {
                                href: '/product/${p.id}',
                                oncreate: M.routeLink
                            }, p.name)),
                            m('td', p.price >= 0 ? '$$${p.price}' : ""),
                            m('td', {style: {color: p.stock < 10 ? "red" : ""}}, Std.string(p.stock)),
                            m('td', p.stock == 0 ? null :
                                m('button.btn.btn-success.btn-xs', {
                                    onclick: addToCart.bind(_, p)
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