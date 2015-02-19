package webshop;

import haxe.Timer;
import jQuery.Event;
import jQuery.JQuery;
import mithril.M;
import webshop.models.*;
import haxe.Serializer;
import haxe.Unserializer;
using Lambda;

/**
 * Left-side menu, listing the categories in the webshop.
 */
class ShoppingCart extends haxe.ds.ObjectMap<Product, Int> implements View
{
    @prop var isOpen : Bool;

    public function new() {
        super();
        isOpen = M.prop(false);
        unserialize();
    }

    public function serialize() {
        var output = new Map<String, Int>();

        for (p in products())
            output.set(p.id, this.get(p));

        js.Browser.getLocalStorage()
        .setItem("cart", haxe.Serializer.run(output));
    }

    public function unserialize() {
        var data = js.Browser.getLocalStorage().getItem("cart");
        if(data == null) return;

        var cartData : Map<String, Int> = cast Unserializer.run(data);
        
        M.startComputation();
        Product.all().then(function(products) {
            products = products.filter(function(p) return cartData.exists(p.id));
            for(p in products) this.set(p, cartData.get(p.id));
            M.endComputation();
        });
    }

    function products() {
        return {iterator: this.keys};
    }

    public function add(product : Product) {
        var existing = products().find(function(p) return p.id == product.id);
        if(existing != null) set(existing, get(existing)+1);
        else set(product, 1);
    }

    override public function set(product : Product, v : Int) {
        var existing = products().find(function(p) return product.id == p.id);

        if(v <= 0 && existing != null) remove(product);
        else if(v > 0) super.set(product, v);

        serialize();
    }

    public function open() {
        M.startComputation();

        isOpen(true);
        new JQuery('html').off("click.clickOutsideMenu");

        // A little tweak to keep the menu size when removing items.
        // Set the width to auto and after a short delay its calculated width.
        var menu = new JQuery("#shopping-cart .dropdown-menu").css('width', "auto");

        Timer.delay(function() {
            new JQuery('html').on('click.clickOutsideMenu', clickOutsideMenu);

            menu.css('width', menu.outerWidth());
            M.endComputation();
        }, 10);
    }

    function clickOutsideMenu(e : Event) {
        if(new JQuery(e.target).parents("#shopping-cart").length > 0) return;

        isOpen(false);
        M.redraw();
    }

    public function view() : ViewOutput {
        [
            m("li", {
                "class": isOpen() ? "dropdown open" : "dropdown",
                config: function(el, isInit) {
                    if(isInit) return;
                    new JQuery(el).on("hide.bs.dropdown", function() return false);
                    new JQuery("html").on("click.clickOutsideMenu", clickOutsideMenu);
                }
            }, [
                m("a.dropdown-toggle", {
                    href: "#",
                    role: "button", 
                    "aria-expanded": false,
                    onclick: open
                }, [
                    cast "Shopping cart ",
                    m("span.caret")
                ]),
                m("ul.dropdown-menu", {role: "menu"}, items())
            ]),
            m("li", this.empty() 
                ? m("span", "Proceed to checkout")
                : m("a[href='/checkout']", {config: M.route}, "Proceed to checkout"))
        ];
    }

    function items() : Array<VirtualElement> {
        if(this.empty()) return [m("li", m("a", "Empty"))];

        var total = 0.0;

        var products = products().map(function(p) {
            var subTotal = p.price * get(p);
            var name = ' ${p.name} | $$$subTotal';
            total += subTotal;
            
            m("li", m("a", [
                m("input[type=number]", {
                    min: 0, 
                    value: get(p), 
                    style: {width: "36px"},
                    oninput: M.withAttr("value", set.bind(p, _))
                }),
                name
            ]));
        }).concat([
            m("li.divider"),
            m("li", m("a", 'Total: $$$total'))
        ]);

        return products.array();        
    }
}
