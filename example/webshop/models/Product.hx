package webshop.models;

import mithril.M;
using Lambda;
using StringTools;

class Product 
{
    public var id : String;
    public var name : String;
    public var price : Float;
    public var stock : Int;

    public function new(?data) {
        if(data == null) return;
        this.id = data.id;
        this.name = data.name;
        this.price = data.price;
        this.stock = data.stock;
    }

    public function slug() {
        return name.replace(" ", "-").toLowerCase();
    }

    public static function all() : Promise<Array<Product>, String> {
        return Category.all().then(function(cat) {
            return cat.fold(function(c, products : Array<Product>) { 
                return products.concat(c.products);
            }, []);
        });
    }
}
