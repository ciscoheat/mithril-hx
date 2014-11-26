package webshop;

import mithril.M;
import webshop.models.*;
using Lambda;

/**
 * Product listing for a Category.
 */
class ProductList implements Module<ProductList>
{
    var category : Category;
    var products : Array<Product>;

    public function new() {}

    public function controller() {
        // Create a temporary product with a loading text.
        var loadingProduct = new Product();
        loadingProduct.name = "Loading...";
        loadingProduct.price = -1;

        // Set products and category based on the current route.
        products = [loadingProduct];
        category = Category.get().find(function(c) 
            return c.id == M.routeParam("categoryId")
        );

        // Load products with an Ajax request.
        Product.getByCategory(category.id).then(function(p) {
            // Replace current products when ready
            products.splice(0, products.length);
            for(prod in p) products.push(prod);

            // getByCategory is a background request to allow the
            // menu to change, so redraw after it's finished.
            M.redraw();
        });
    }

    public function view() {
        return [
            m("h2.sub-header", category.name),
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
                    m("tbody#products", products.map(function(p) 
                        return m("tr", [
                            m("td", p.id),
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