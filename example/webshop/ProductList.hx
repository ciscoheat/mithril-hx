package webshop;

import haxecontracts.*;
import haxe.DynamicAccess;
import js.html.Element;
import mithril.M;
import webshop.models.*;

using Slambda;

/**
 * Product listing for a Category.
 */
class ProductList implements Mithril implements HaxeContracts
{
    var menu : Menu;
    var categories : Array<Category>;
    var cart : ShoppingCart;
    var loader : Loader;
    var products : Array<Product>;

    var currentCategory : Category;

    public function new(menu, cart, categories) {
        this.menu = menu;
        this.cart = cart;
        this.categories = categories;
        this.loader = new Loader();
        this.products = [];
    }

    // The reason for not passing products directly to the products property is that
    // then another part of the program has to manage the loader, which breaks encapsulation.
    public function onmatch(params : haxe.DynamicAccess<String>, url : String) {
        requires(params != null);

        loader.start();
        menu.setActive(null);

        // Set current category
        currentCategory = categories.find(function(c) return c.slug() == params.get('key'));

        if(currentCategory == null) {
            loader.error();
            return;
        }

        menu.setActive(currentCategory.id);

        // Load new products
        Product.inCategory(currentCategory).then(function(products) {
            this.products = products;
            loader.done();
        }, loader.error);
    }

    function addToCart(p : Product) {
        cart.add(p);
        cart.open();
    }

    // Note that the ProductList isn't a Component (no view method), so it cannot have 
    // lifecycle methods unless explicitly displayed with m().
    public function render() {
        var loading = switch loader.state() {
            case Started: m('div.row', "");
            case Delayed: m('div.row', m('div.col-xs-12', m('h1', "Loading...")));
            case Error: m('div.row', m('div.col-xs-12', m('h1', {style: {color: "red"}}, "Loading error, please reload page.")));
            case Done: null;
        }

		return if(loading != null) loading else [
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
                    m('tbody[id=products]', products.map(function(p) 
                        m('tr', [
                            m('td', m('a', {
                                href: '/product/${p.id}',
                                oncreate: M.routeLink
                            }, p.name)),
                            m('td', p.price >= 0 ? '$$${p.price}' : ""),
                            m('td', {style: {color: p.stock < 10 ? "red" : ""}}, Std.string(p.stock)),
                            m('td', p.stock == 0 ? null :
                                m('button.btn.btn-success.btn-xs', {
                                    onclick: addToCart.bind(p)
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

    @invariants function invariants() {
        invariant(products != null);
        invariant(menu != null);
        invariant(categories != null);
        invariant(cart != null);
        invariant(loader != null);
        invariant(currentCategory == null || categories.exists.fn(_ == currentCategory));
    }    
}