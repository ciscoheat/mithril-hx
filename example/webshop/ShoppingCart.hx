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
class ShoppingCart implements Mithril
{
    var isOpen : Bool;
    var cartParent : Element;
    var dropDownMenu : Element;

    var content : haxe.ds.ObjectMap<Product, Int> = new haxe.ds.ObjectMap<Product, Int>();

    public function new() {
        unserialize();
    }

    ///// Saving and restoring the cart to localStorage /////

    public function serialize() {
        var output = new Map<String, Int>();

        for (p in products())
            output.set(p.id, content.get(p));

        js.Browser.getLocalStorage()
        .setItem("cart", haxe.Serializer.run(output));
    }

    public function unserialize() {
        var data = Browser.getLocalStorage().getItem("cart");
        if(data == null) return;

        try {
            var cartData : Map<String, Int> = cast Unserializer.run(data);
            
            Product.all().then(function(products : Array<Product>) {
                products = products.filter(function(p) return cartData.exists(p.id));
                for(p in products) this.set(p, cartData.get(p.id));
                M.redraw();
            });
        } catch(e : Dynamic) {}
    }

    //////////////////////////////////////////////////////////

    function products() {
        return {iterator: content.keys};
    }

    public function add(product : Product) {
        var existing = products().find(function(p) return p.id == product.id);
        if(existing != null) set(existing, content.get(existing)+1);
        else set(product, 1);
    }

    public function set(product : Product, v : Int) {
        var existing = products().find(function(p) return product.id == p.id);

        if(v <= 0 && existing != null) content.remove(product);
        else if(v > 0) content.set(product, v);

        serialize();
    }

    public function open() {
        var html = Browser.document.documentElement;

        isOpen = true;

        // A little tweak to keep the menu size when removing items.
        // Set the width to auto and after a short delay its calculated width.
        dropDownMenu.style.width = "auto";
        html.removeEventListener("click", clickOutsideCart);

        Timer.delay(function() {
            html.addEventListener("click", clickOutsideCart);
            dropDownMenu.style.width = Std.string(dropDownMenu.offsetWidth) + "px";
            M.redraw();
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
		m('li', {
			"class": isOpen ? "dropdown open" : "dropdown",
			oncreate: function(vnode : VNode<ShoppingCart>) {
				cartParent = vnode.dom.parentElement;
				// Need to prevent dropdown from closing automatically:
				vnode.dom.addEventListener("hide.bs.dropdown", function() return false);
			}
		}, [
			m('a.dropdown-toggle', {
				href: "#",
				role: "button", 
				"aria-expanded": false,
				onclick: open
			}, [
				cast "Shopping cart ",
				m('span.caret', null)
			]),
			m('ul.dropdown-menu', {
				role: "menu",
				config: function(el, isInit) if(!isInit) dropDownMenu = el
			}, items())
		]),
		m('li', content.empty() 
			? m('span', "Proceed to checkout")
			: m("a[href='/checkout']", {oncreate: M.routeLink}, "Proceed to checkout")
        )
	];

    function items() : Array<VirtualElement> {
        if(content.empty()) return [m('li', m('a', "Empty"))];

        var total = 0.0;
        var products = products().map(function(p) {
            var subTotal = p.price * content.get(p);
            total += subTotal;
            
            m('li', m('a', [
                m("input[type=number]", {
                    min: 0, 
                    value: content.get(p), 
                    style: {width: "36px"},
                    oninput: M.withAttr("value", set.bind(p, _))
                }),
                m('span', m('a', { 
                    oncreate: M.routeLink, 
                    href: '/product/${p.id}', 
                }, ' ${p.name}'), " | $" + subTotal)
            ]));
        }).concat([
            m('li.divider', null),
            m('li', m('a', 'Total: $' + total))
        ]);

        return products.array();        
    }
}
