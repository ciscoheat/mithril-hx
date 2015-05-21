package webshop;

import mithril.M;
import webshop.models.Category;
import webshop.models.*;
using Lambda;

/**
 * Left-side menu, listing the categories in the webshop.
 */
class Menu implements Component
{
    @prop var categories : Array<Category>;

    public function new() {
        this.categories = M.prop([]);
    }

    public function controller() {
        Category.all().then(function(c) return categories(c)).then(function(_) M.redraw());
    }

    function isActive(c : Category) {
        if(c.slug() == M.routeParam('categoryId')) return true;
        return c.products.exists(function(p) return p.id == M.routeParam('productId'));
    }

    public function view() {
        m("ul.nav.nav-sidebar", 
            categories().array().map(function(c) {
                m("li", {"class": isActive(c) ? "active" : ""}, 
                    m("a", {
                        href: '/category/${c.slug()}',
                        config: M.route
                    }, c.name)
                );
            })
        );
    }
}
