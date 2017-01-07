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

        Category.all().then(function(c) {
            categories = c;
            M.redraw();            
        });
    }

    function isActive(c : Category) {
        //trace(productList.currentCategory.id); trace(c.id);
        return productList.currentCategory.id == c.id;
        /*
        if(attrs == null) return false;
        trace(attrs);
        if(c.slug() == attrs.categoryId) return true;
        return c.products.exists(function(p) return p.id == attrs.productId);
        */
    }

    public function view() [
        m('ul.nav.nav-sidebar', categories.map(function(c) {
            m('li', {"class": isActive(c) ? "active" : ""}, 
                m('a', {
                    href: '/category/${c.slug()}',
                    oncreate: M.routeLink
                }, c.name)
            );
        }))
    ];
}
