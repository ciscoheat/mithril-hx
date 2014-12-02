package webshop;

import mithril.M;
import webshop.models.Category;
import webshop.models.*;
using Lambda;

/**
 * Left-side menu, listing the categories in the webshop.
 */
class Menu implements Module<Menu>
{
    @prop public var active : Category;
    @prop var categories : Array<Category>;

    public function new() {
        this.categories = M.prop([]);
        this.active = M.prop(null);
    }

    public function controller() {
        Category.all().then(categories).then(function(_) M.redraw());
    }

    public function isActive(c : Category) {
        return (active() != null && active().id == c.id);
    }

    public function view() {
        return m("ul.nav.nav-sidebar", 
            categories().array().map(function(c) {
                return m("li", {"class": isActive(c) ? "active" : ""}, 
                    m("a", {
                        href: '/category/${c.slug()}',
                        config: M.route
                    }, c.name)
                );
            })
        );
    }
}
