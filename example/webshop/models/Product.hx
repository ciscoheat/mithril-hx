package webshop.models;

using mithril.M;

class Product 
{
    public var id : Int;
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

    public static function getByCategory(id : String) : Promise<Array<Product>, String> {
        return M.request({
            method: "GET",
            url: 'http://beta.json-generator.com/api/json/get/$id?delay=100',
            background: true
        }).then(function(data : Array<Dynamic>) {
            return data.map(function(d) return new Product(d));
        });
    }
}
