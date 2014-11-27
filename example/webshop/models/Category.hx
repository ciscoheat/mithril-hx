package webshop.models;

import mithril.M;
using StringTools;

class Category
{
    public var id : String;
    public var name : String;
    public var products : Array<Product>;

    public function new(?data, ?products) {
        if(data != null)
            this.name = data.name;

        if(products != null)
            this.products = products;
    }

    public function slug() {
        return name.replace(" ", "-").toLowerCase();
    }

    ///// Data access /////

    public static function all() : Promise<Array<Category>, String> {
        return M.request({
            method: "GET",
            url: 'http://beta.json-generator.com/api/json/get/A0FlQeQ?delay=100',
            background: true,
            initialValue: [],
        }).then(function(data : Array<Dynamic>) {
            // See http://beta.json-generator.com/A0FlQeQ for content
            // (and a great site for generating JSON-data)
            return data.map(function(d) {
                var products = d.products.map(function(p) return new Product(p));
                return new Category(d, products);
            });
        });
    }
}
