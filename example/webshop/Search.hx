package webshop;

#if (haxe_ver >= 3.2)
import js.html.DOMElement in Element;
#else
import js.html.Element;
#end
import js.html.Event;
import js.html.InputElement;
import js.html.KeyboardEvent;
import mithril.M;
import webshop.models.*;
using Lambda;
using StringTools;

class Search implements View
{
    @prop var results : Array<Product>;

    public function new() {
        this.results = M.prop([]);
    }

    function search(phrase : String) {
        if(phrase.length < 2) 
            clear();
        else
            Product.search(phrase.toLowerCase()).then(results).then(function(_) M.redraw());
    }

    function closeEvent(parent : Element, e : Event) {
        // Clear results (same as closing the dropdown menu) if clicking outside it.
        var el : Element = cast e.target;
        while(el != null) {
            if(el == parent) return;
            el = el.parentElement;
        }
        clear();
    }

    function clear() {
        results([]);
        M.redraw();
    }

    public function view() {
        [
            m("input.form-control", {
                placeholder: "Search...",
                oninput: M.withAttr("value", search),
                onfocus: M.withAttr("value", search)
            }),
            m("ul.dropdown-menu.dropdown-menu-right", {
                role: "menu",
                style: {display: results().length > 0 ? "block" : "none"},
                config: function(el, isInit, context) if(!isInit) {
                    js.Browser.document.documentElement.addEventListener("click", closeEvent.bind(el.parentElement));
                }
            }, results().map(function(p)
                m("li", {role: "presentation"},
                    m("a", {
                        role: "menuitem",
                        tabindex: -1,
                        href: '/product/${p.id}',
                        config: M.route
                    }, p.name)
                )
            ))
        ];
    }
}
