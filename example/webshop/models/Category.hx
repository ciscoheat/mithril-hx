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
        // Simulate a short delay, but every once in a while a long delay.
        var delay = Std.random(100);
        if(Math.random() > 0.87) delay = 2000;

        // See http://beta.json-generator.com/A0FlQeQ for content
        // (and a great site for generating JSON-data)

        return M.request({
            method: "GET",
            url: 'http://beta.json-generator.com/api/json/get/A0FlQeQ?delay=$delay',
            background: true,
            initialValue: [],
        }).then(function(data : Array<Dynamic>) {
            return data.map(function(d) {
                var products = d.products.map(function(p) return new Product(p));
                return new Category(d, products);
            });
        });
    }
}
