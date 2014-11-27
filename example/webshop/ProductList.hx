package webshop;

import mithril.M;
import webshop.models.*;
using Lambda;

/**
 * Product listing for a Category.
 */
class ProductList implements Module<ProductList>
{
    @prop var category : Category;
    @prop var products : Array<Product>;
    @prop var loading : Bool;

    public function new() {
        this.category = M.prop();
        this.products = M.prop();
        this.loading = M.prop();
    }

    public function controller() {
        products([]);
        loading(true);
        
        // Set category based on the current route.
        category(Category.get().find(function(c) 
            return c.id == M.routeParam("categoryId")
        ));

        // Load products with an Ajax request.
        // It has background = true to allow navigation to update,
        // so a call to M.redraw is required when it finishes.
        Product.getByCategory(category().id)
        .then(products)
        .then(function(_) {
            loading(false);
            M.redraw();
        });
    }

    public function view() {
        var content : VirtualElement;

        if(loading()) {
            content = m("h3", {style: {"text-align": "center"}}, "Loading...");
        } else {
            content = 
                m(".table-responsive", [
                    m("table.table.table-striped", [
                        m("thead", [
                            m("tr", [
                                m("th", "#"),
                                m("th", "Name"),
                                m("th", "Price"),
                                m("th", "Stock")
                            ])
                        ]),
                        m("tbody#products", products().map(function(p) 
                            return m("tr", [
                                m("td", p.id),
                                m("td", p.name),
                                m("td", p.price >= 0 ? '$$${p.price}' : ""),
                                m("td", {style: {color: p.stock < 10 ? "red" : ""}}, p.stock)
                            ])
                        ))
                    ])
                ]);
        }
        return [
            m("h2.sub-header", category().name),
            content
        ];
    }
}