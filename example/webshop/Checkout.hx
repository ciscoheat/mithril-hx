package webshop;

import mithril.M;
import webshop.models.*;
using Lambda;

private typedef FormField = {
    var id : String;
    var label : String;
    @:optional var required : Bool; // Default: true
    @:optional var type : String;   // Default: text
    @:optional var width : Int;     // Default: 5 (bootstrap columns)
}

/**
 * Left-side menu, listing the categories in the webshop.
 */
class Checkout implements Module<Checkout>
{
    var cart : ShoppingCart;
    var form : Array<FormField>;

    public function new(cart) {
        this.cart = cart;

        this.form = [
            {id: "name", label: "Name"},
            {id: "address1", label: "Address"},
            {id: "address1", label: "", required: false},
            {id: "city", label: "City", width: 4},
            {id: "zip", label: "Zip", width: 3},
            {id: "email", label: "E-mail", type: "email"}
        ];
    }

    public function controller() {
        
    }

    public function view() {
        return [
            m("h1", "Checkout"),
            m("form.form-horizontal[role=form]", 
                form.map(formFields).concat([
                    m(".form-group", 
                        m(".col-sm-offset-1.col-sm-5",
                            m("button.btn.btn-success", "Submit order")
                        )
                    )
                ])
            )
        ];
    }

    function formFields(f : FormField) {
        var required = f.required != false;
        return m(".form-group", [
            m("label.col-sm-1.control-label", {"for": f.id}, f.label + (required ? "*" : "")),
            m(".col-sm-" + (f.width == null ? 5 : f.width), 
                m("input.form-control" + (required ? "[required]" : ""), {
                    type: f.type == null ? "text" : f.type,
                    name: f.id,
                    id: f.id
                })
            )
        ]);
    }
}
