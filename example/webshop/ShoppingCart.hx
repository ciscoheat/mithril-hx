package webshop;

import jQuery.JQuery;
import mithril.M;
import webshop.models.*;
using Lambda;

/**
 * Left-side menu, listing the categories in the webshop.
 */
class ShoppingCart extends haxe.ds.ObjectMap<Product, Int> implements Module<ShoppingCart>
{
    var el : JQuery;
    @prop public var open : Bool;

    public function new() {
        super();
        open = M.prop(false);
    }

    public function controller() {
        //el = new JQuery("#shopping-cart").find(".dropdown");
    }

    public function add(p : Product) {
        if(exists(p)) set(p, get(p)+1);
        else set(p, 1);
    }

    public function view() : ViewOutput {
        return m("li", {"class": "dropdown" + (open() ? " open" : "")} , [
            m("a.dropdown-toggle", {href: "#", "data-toggle": "dropdown", role: "button", "aria-expanded": false}, [
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
