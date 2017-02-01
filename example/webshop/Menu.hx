package webshop;

import haxecontracts.*;
import mithril.M;
import webshop.models.Category;
import webshop.models.*;

using StringTools;
using Slambda;

/**
 * Left-side menu, listing the categories in the webshop.
 */
class Menu implements Mithril implements HaxeContracts
{
    var categories : Array<Category>;
    var active : Null<Category>;

    public function new(categories) {
        this.categories = categories;
    }

    public function setActive(categoryId : Null<String>) {
        this.active = categories.find(function(c) return c.id == categoryId);
    }

    public function view(vnode) [
        m('ul.nav.nav-sidebar', categories.map(function(c) {
            m('li', {"class": (active != null && active == c ? "active" : "")}, 
                m('a', {
                    href: '/category/${c.slug()}',
                    oncreate: M.routeLink
                }, c.name)
            );
        }))
    ];

    @invariants function invariants() {
        invariant(categories != null);
        invariant(active == null || categories.exists.fn(_ == active));
    }
}
