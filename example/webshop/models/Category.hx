package webshop.models;

class Category
{
    public var name : String;
    public var id : String;

    public function new(?data) {
        if(data == null) return;
        this.name = data.name;
        this.id = data.id;
    }

    public static function get() {
        return [
            new Category({name: "Food", id: "GLE4gMg"}),
            new Category({name: "Cutlery", id: "L6IPYJU"}),
            new Category({name: "Cars", id: "DU-YQHt"}),
            new Category({name: "Useless stuff", id: "F_GyG6p"}),
        ];
    }
}
