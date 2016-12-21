package webshop;

import mithril.M;
import webshop.models.Category;
import webshop.models.*;
using Lambda;

/**
 * Left-side menu, listing the categories in the webshop.
 */
class Menu implements Mithril
{
    var categories : Array<Category> = [];
    var productList : ProductList;
    var productPage : ProductPage;

    public function new(productList, productPage) {
        this.productList = productList;
        this.productPage = productPage;
    }

    public function oncreate() {
        trace('Nav menu oncreate');
        //trace(this);
        Category.all().then(function(c) {
            trace('Back from promise');
            //trace(this);
            categories = c;
            trace(categories);
            M.redraw();
        });
    }

    function isActive(c : Category) {
        return false;
        /*
        if(attrs == null) return false;
        trace(attrs);
        if(c.slug() == attrs.categoryId) return true;
        return c.products.exists(function(p) return p.id == attrs.productId);
        */
    }

    public function view(vnode : VNode<Menu>) { //trace(this);
        m('ul.nav.nav-sidebar', categories.map(function(c) {
            m('li', {"class": isActive(c) ? "active" : ""}, 
                m('a', {
                    href: '/category/${c.slug()}',
                    oncreate: M.routeLink
                }, c.name)
            );
        }));
    }
}
