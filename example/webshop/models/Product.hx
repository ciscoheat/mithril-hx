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

    public static function all() : Promise<Array<Product>, String> {
        return Category.all().then(function(cat)
            return cat.fold(function(c, products : Array<Product>)
                return products.concat(c.products), [])
        );
    }

    public static function search(partialName : String) : Promise<Array<Product>, String> {
        return all().then(function(products : Array<Product>)
            return products.filter(function(p) 
                return p.name.toLowerCase().indexOf(partialName) >= 0
            )
        );
    }
}
