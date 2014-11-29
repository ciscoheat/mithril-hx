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
class ShoppingCart extends haxe.ds.ObjectMap<Product, Int> implements Module<ShoppingCart>
{
    @prop var isOpen : Bool;

    public function new() {
        super();
        isOpen = M.prop(false);
        unserialize();
    }

    public function controller() {
    }

    public function serialize() {
        var output = new Map<String, Int>();

        for (p in {iterator: this.keys})
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

    public function add(p : Product) {
        if(exists(p)) set(p, get(p)+1);
        else set(p, 1);
    }

    override public function set(p : Product, v : Int) {
        if(v <= 0 && exists(p)) remove(p);
        else super.set(p, v);
        serialize();
    }

    public function open() {
        new JQuery('html').off("click.closeCart");

        Timer.delay(function() {
            new JQuery('html').on('click.closeCart', closeEvent);
        }, 10);

        isOpen(true);
        M.redraw();
    }

    function closeEvent(e : Event) {
        // Close cart if clicking outside it.
        if(new JQuery(e.target).parents("#shopping-cart").length > 0) return;

        isOpen(false);
        M.redraw();
    }

    public function view() : ViewOutput {
        return m("li", {
            "class": isOpen() ? "dropdown open" : "dropdown",
            config: function(el, isInit) {
                if(isInit) return;
                new JQuery(el).on("hide.bs.dropdown", function() return false);
                new JQuery("html").on("click.closeCart", closeEvent);
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
        ]);
    }

    function items() : Array<VirtualElement> {
        if(this.empty()) return [m("li", m("a", "Empty"))];

        var keys = {iterator: this.keys};
        var total = 0.0;

        var products = keys.map(function(p) {
            var subTotal = p.price * get(p);
            var name = ' ${p.name} | $$$subTotal';
            total += subTotal;
            return m("li", m("a", [
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
