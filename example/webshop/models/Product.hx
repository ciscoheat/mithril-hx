package webshop.models;

import mithril.M;
import js.Promise;
using Lambda;
using StringTools;

class Product 
{
    public var id : String;
    public var name : String;
    public var price : Float;
    public var stock : Int;
    
    public var category(default, null) : Category;

    public function new(data, category) {
        if(data != null) {
            this.id = data.id;
            this.name = data.name;
            this.price = data.price;
            this.stock = data.stock;
        }

        this.category = category;
    }

    public function slug() {
        return name.replace(" ", "-").toLowerCase();
    }

    public static function all() : Promise<Array<Product>> {
        return new Promise<Array<Product>>(function(resolve, reject) {
            Category.all().then(function(cat : Array<Category>) {
                var products = cat.fold(function(c, products : Array<Product>) return products.concat(c.products), []);
                resolve(products);
            });
        });
    }

    public static function search(partialName : String) : Promise<Array<Product>> {
        return all().then(function(products : Array<Product>)
            return products.filter(function(p) 
                return p.name.toLowerCase().indexOf(partialName) >= 0
            )
        );
    }
}
