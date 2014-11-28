package webshop;

import haxe.Timer;
import jQuery.Event;
import jQuery.JQuery;
import mithril.M;
import webshop.models.*;
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
    }

    public function controller() {
    }

    public function add(p : Product) {
        if(exists(p)) set(p, get(p)+1);
        else set(p, 1);
    }

    public function open() {
        new JQuery('body').off("click.closeCart");

        Timer.delay(function() {
            new JQuery('body').on('click.closeCart', closeEvent);
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
                new JQuery("body").on("click.closeCart", closeEvent);
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
            var name = '${get(p)} ${p.name} | $$$subTotal';
            total += subTotal;
            return m("li", m("a", name));
        }).concat([
            m("li.divider"),
            m("li", m("a", 'Total: $$$total'))
        ]);

        return products.array();        
    }
}
