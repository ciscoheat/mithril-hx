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
    var loading : Loader;

    public function new() {
        this.category = M.prop(new Category());
    }

    public function controller() {
        loading = new Loader();

        // Get category based on the current route.
        var getCurrentCategory = function(categories : Array<Category>) {
            return categories.find(function(c) return c.slug() == M.routeParam("categoryId"));
        };

        // Load products with an Ajax request.
        // It has background = true to allow navigation to update, so a call 
        // to M.redraw (executed in loading.done) is required when it finishes.
        Category.all().then(getCurrentCategory, loading.error).then(category).then(loading.done);
    }

    public function view() : ViewOutput {
        switch(loading.state()) {
            case Started:
                return null;
            case Delayed:          
                return m("h2.sub-header", {style: {"text-align": "center"}}, "Loading...");
            case Error:
                return m("h2.sub-header", {style: {"text-align": "center", color: "red"}}, "Loading error, please reload page.");
            case Done:
        }

        return [
            m("h2.sub-header", category().name),
            m(".table-responsive", [
                m("table.table.table-striped", [
                    m("thead", [
                        m("tr", [
                            m("th", "Name"),
                            m("th", "Price"),
                            m("th", "Stock")
                        ])
                    ]),
                    m("tbody#products", category().products.map(function(p) 
                        return m("tr", [
                            m("td", p.name),
                            m("td", p.price >= 0 ? '$$${p.price}' : ""),
                            m("td", {style: {color: p.stock < 10 ? "red" : ""}}, p.stock)
                        ])
                    ))
                ])
            ])
        ];
    }
}