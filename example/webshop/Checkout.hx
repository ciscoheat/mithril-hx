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

class Checkout implements View
{
    var cart : ShoppingCart;
    var checkoutForm : Array<FormField>;

    public function new(cart) {
        this.cart = cart;

        this.checkoutForm = [
            {id: "name", label: "Name"},
            {id: "address1", label: "Address"},
            {id: "address1", label: "", required: false},
            {id: "city", label: "City", width: 4},
            {id: "zip", label: "Zip", width: 3},
            {id: "email", label: "E-mail", type: "email"}
        ];
    }

    public function view() [
        h1("Checkout"),
        form.form-horizontal[role=form]( 
            checkoutForm.map(formFields).concat([
                div.form-group(
                    div.col-sm-offset-1.col-sm-5(
                        button.btn.btn-success("Submit order")
                    )
                )
            ])
        )
    ];

    function formFields(f : FormField) {
        var required = f.required != false;
        div.form-group([
            label.col-sm-1.control-label({"for": f.id}, f.label + (required ? "*" : "")),
            div({"class": "col-sm-" + (f.width == null ? 5 : f.width)}, 
                input({
                    "class": "form-control", 
                    required: required,
                    type: f.type == null ? "text" : f.type,
                    name: f.id,
                    id: f.id
                })
            )
        ]);
    }
}
