package webshop;

import js.Browser;
#if (haxe_ver >= 3.2)
import js.html.DOMElement in Element;
#else
import js.html.Element;
#end
import js.html.Event;
import haxe.Timer;
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
    var isOpen : Bool;
    var cartParent : Element;
    var dropDownMenu : Element;

    public function new() {
        super();
        unserialize();
    }

    ///// Saving and restoring the cart to localStorage /////

    public function serialize() {
        var output = new Map<String, Int>();

        for (p in products())
            output.set(p.id, this.get(p));

        js.Browser.getLocalStorage()
        .setItem("cart", haxe.Serializer.run(output));
    }

    public function unserialize() {
        var data = Browser.getLocalStorage().getItem("cart");
        if(data == null) return;

        try {
            var cartData : Map<String, Int> = cast Unserializer.run(data);
            
            M.startComputation();
            Product.all().then(function(products) {
                products = products.filter(function(p) return cartData.exists(p.id));
                for(p in products) this.set(p, cartData.get(p.id));
                M.endComputation();
            });
        } catch(e : Dynamic) {}
    }

    //////////////////////////////////////////////////////////

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
        var html = Browser.document.documentElement;

        isOpen = true;

        // A little tweak to keep the menu size when removing items.
        // Set the width to auto and after a short delay its calculated width.
        dropDownMenu.style.width = "auto";
        html.removeEventListener("click", clickOutsideCart);

        Timer.delay(function() {
            html.addEventListener("click", clickOutsideCart);
            dropDownMenu.style.width = Std.string(dropDownMenu.offsetWidth) + "px";
            M.endComputation();
        }, 10);
    }

    function clickOutsideCart(e : Event) {
        // Close cart if clicking outside it.
        var el : Element = cast e.target;
        while(el != null) {
            if(el == cartParent) return;
            el = el.parentElement;
        }

        isOpen = false;
        M.redraw(); // Need to redraw because it's not a Mithril handled event.
    }

    public function view() [
		LI({
			"class": isOpen ? "dropdown open" : "dropdown",
			config: function(el, isInit) if(!isInit) {
				cartParent = el.parentElement;
				// Need to prevent dropdown from closing automatically:
				el.addEventListener("hide.bs.dropdown", function() return false);
			}
		}, [
			A.dropdown-toggle({
				href: "#",
				role: "button", 
				"aria-expanded": false,
				onclick: open
			}, [
				cast "Shopping cart ",
				SPAN.caret()
			]),
			UL.dropdown-menu({
				role: "menu",
				config: function(el, isInit) if(!isInit) dropDownMenu = el
			}, items())
		]),
		LI(this.empty() 
			? SPAN("Proceed to checkout")
			: A[href='/checkout']({config: M.route}, "Proceed to checkout"))
	];

    function items() : Array<VirtualElement> {
        if(this.empty()) return [LI(A("Empty"))];

        var total = 0.0;
        var products = products().map(function(p) {
            var subTotal = p.price * get(p);
            total += subTotal;
            
            LI(A([
                m("input[type=number]", {
                    min: 0, 
                    value: get(p), 
                    style: {width: "36px"},
                    oninput: M.withAttr("value", set.bind(p, _))
                }),
                SPAN(A({ 
                    config: M.route, 
                    href: '/product/${p.id}', 
                }, ' ${p.name}'), " | $" + subTotal)
            ]));
        }).concat([
            LI.divider(),
            LI(A('Total: $' + total))
        ]);

        return products.array();        
    }
}
