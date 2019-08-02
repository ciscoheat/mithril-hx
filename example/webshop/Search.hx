package webshop;

import js.html.DOMElement in Element;
import haxe.Constraints.Function;
import js.Browser;
import js.html.Event;
import mithril.M;
import webshop.models.*;

class Search implements Mithril
{
    var results : Array<Product> = [];
	var clickHandler : Function;

    public function new() {}

    function searchEvent(phrase : String) {
        if(phrase.length < 2) 
            results = [];
        else
            Product.search(phrase.toLowerCase()).then(function(r) return results = r).then(function(_) M.redraw());
    }

    function documentClickEvent(parent : Element, e : Event) {
        // Clear results (same as closing the dropdown menu) if clicking outside it.
        var el : Element = cast e.target;
        while(el != null) {
            if(el == parent) return;
            el = el.parentElement;
        }

        results = [];
        M.redraw(); // Need to redraw because it's not a Mithril handled event.
    }

    public function view() {
        [
            m('input.form-control', {
                placeholder: "Search...",
                oninput: e -> searchEvent(e.currentTarget.value),
                onfocus: e -> searchEvent(e.currentTarget.value)
            }),
            m('UL.dropdown-menu.dropdown-menu-right', {
                role: "menu",
                style: {display: results.length > 0 ? "block" : "none"},
                oncreate: function(vnode) {					
					clickHandler = documentClickEvent.bind(vnode.dom.parentElement);
                    Browser.document.documentElement.addEventListener("click", clickHandler);
                },
				onremove: function(vnode) {
					Browser.document.documentElement.removeEventListener("click", clickHandler);
				}
            }, results.map(function(p)
                m('li', {role: "presentation"},
                    m(M.route.Link, {
                        role: "menuitem",
                        tabindex: -1,
                        href: '/product/${p.id}'
                    }, p.name)
                )
            ))
        ];
    }
}
