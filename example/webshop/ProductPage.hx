package webshop;

import haxecontracts.*;
import js.html.Element;
import js.html.MouseEvent;
import mithril.M;
import webshop.models.*;

using Lambda;
using StringTools;

class ProductPage implements Mithril implements HaxeContracts
{
    var loader : Loader;
    var cart : ShoppingCart;
    var menu : Menu;

    var product : Null<Product>;

    public function new(menu, cart) {
        this.cart = cart;
        this.loader = new Loader();
        this.menu = menu;
    }

    public function onmatch(params : haxe.DynamicAccess<String>, url : String) {
        loader.start();

        Product.all().then(function(products : Array<Product>) { 
            menu.setActive(null);
            product = products.find(function(p) return p.id == params.get('key'));
            if(product != null) {
                menu.setActive(product.category.id);
                loader.done();
            } 
            else loader.error();
        }, 
            loader.error
        );
		
		return null;
    }

    function addToCart(p : Product) {
        cart.add(p);
        cart.open();
    }

    public function render(vnode) {
        var template = switch loader.state() {
            case Started: m('div.row', "");
            case Delayed: m('div.row', m('div.col-xs-12', m('h1', "Loading...")));
            case Error: m('div.row', m('div.col-xs-12', m('h1', {style: {color: "red"}}, "Loading error, please reload page.")));
            case Done: null;
        }
		
		var button = function() m('button.btn.btn-lg.btn-success[type=button]', 
            {onclick: addToCart.bind(product)},
            "Add to Cart"
        );

		return if (template != null) template else [
            m('div.row', m('div.col-xs-12', m('h1', product.name))),
            m('div.row', [
                m('div.col-xs-12.col-sm-12.col-md-7.col-lg-6', [
                    m("img[data-src='holder.js/100px450?auto=yes&random=yes']", {
                        oncreate: function() untyped __js__("Holder.run()")
                    }),
                    m('div.clearfix', {style: {"margin": "10px"}}),
                    m('div.row', [
                        m('div.col-xs-2', m('div.h2', "$" + product.price)),
                        m('div.col-xs-4', m('div.h2', product.stock > 0 ? button() : m('h3', "Out of stock")))
                    ])
                ]),
                m('div.col-xs-12.col-sm-12.col-md-5.col-lg-6', lorem.map(function(l) m('p', l)))
            ])
        ];
    }

    @invariants function invariants() {
        invariant(cart != null);
        invariant(loader != null);
        invariant(menu != null);
    }

    static var lorem = 
    "Cupcake ipsum dolor sit amet pudding. Tiramisu marshmallow cotton candy fruitcake gummies candy gummi bears. Powder pastry oat cake oat cake dragée soufflé apple pie. Chocolate bar bear claw cupcake I love dragée toffee oat cake marshmallow bonbon. Fruitcake marshmallow I love pudding I love jelly beans carrot cake biscuit. Lollipop brownie tart apple pie cotton candy sugar plum candy. Topping lollipop wafer cotton candy fruitcake toffee.
    Macaroon candy canes lemon drops sugar plum topping pudding. Lemon drops chocolate cupcake cheesecake. Jelly beans soufflé sugar plum donut cheesecake I love ice cream caramels. Muffin gummies toffee candy canes. Jelly beans I love fruitcake dragée chocolate. Chocolate bar candy canes danish soufflé. I love cotton candy liquorice jelly.
    Liquorice applicake tiramisu I love tiramisu applicake pie brownie applicake. Toffee danish tiramisu pie. Dessert jelly pudding marzipan jelly. Tootsie roll donut marshmallow jujubes marshmallow lollipop cookie brownie gummies. Brownie candy canes brownie. Fruitcake dessert toffee apple pie chocolate cake powder chocolate. Tart muffin jelly ice cream liquorice marzipan. Icing brownie liquorice I love ice cream.
    Toffee danish icing cheesecake I love. Cake croissant sweet topping jelly-o marzipan topping jelly-o sweet. Dragée I love cupcake I love sugar plum brownie apple pie. I love lollipop gummi bears soufflé gummi bears apple pie dragée tootsie roll candy canes. Lemon drops applicake fruitcake candy canes liquorice. Ice cream cookie brownie jujubes icing. Candy canes I love bonbon danish. Jelly jelly beans chocolate bar pastry biscuit ice cream chocolate cake jelly beans. Candy chupa chups jujubes ice cream. Tootsie roll tart caramels cupcake.
    Marzipan applicake ice cream brownie tart donut cake. Sweet roll soufflé tiramisu pastry gummi bears candy sweet roll topping apple pie. Dessert lemon drops fruitcake icing icing I love. Dragée fruitcake I love I love pie. Halvah dragée sweet cotton candy pudding apple pie chupa chups. Bear claw cotton candy I love muffin muffin unerdwear.com soufflé croissant. Cookie cookie danish tart sweet cheesecake.
    ".trim().split("\n");
}
