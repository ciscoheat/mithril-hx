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
    @prop var results : Array<Product> = [];

    public function new() {}

    function searchEvent(phrase : String) {
        if(phrase.length < 2) 
            results([]);
        else
            Product.search(phrase.toLowerCase()).then(results).then(function(_) M.redraw());
    }

    function documentClickEvent(parent : Element, e : Event) {
        // Clear results (same as closing the dropdown menu) if clicking outside it.
        var el : Element = cast e.target;
        while(el != null) {
            if(el == parent) return;
            el = el.parentElement;
        }

        results([]);
        M.redraw(); // Need to redraw because it's not a Mithril handled event.
    }

    public function view() {
        [
            INPUT.form-control({
                placeholder: "Search...",
                oninput: M.withAttr("value", searchEvent),
                onfocus: M.withAttr("value", searchEvent)
            }),
            UL.dropdown-menu.dropdown-menu-right({
                role: "menu",
                style: {display: results().length > 0 ? "block" : "none"},
                config: function(el, isInit) if(!isInit) {
                    js.Browser.document.documentElement.addEventListener("click", 
                        documentClickEvent.bind(el.parentElement));
                }
            }, results().map(function(p)
                LI({role: "presentation"},
                    A({
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
