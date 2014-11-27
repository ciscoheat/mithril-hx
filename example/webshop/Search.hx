package webshop;

import mithril.M;
import webshop.models.*;
using Lambda;

class Search implements Module<Search>
{
    @prop var categories : Array<Category>;

    public function new() {
        this.categories = M.prop([]);
    }

    public function controller() {
        Category.all().then(categories).then(function(_) M.redraw());
    }

    public function view() {
        return m("ul.nav.nav-sidebar", 
            categories().array().map(function(c) {
                return m("li", {"class": M.routeParam("categoryId") == c.slug() ? "active" : ""}, 
                    m("a", {
                        href: '/category/${c.slug()}',
                        config: M.route
                    }, c.name)
                );
            })
        );
    }
}
