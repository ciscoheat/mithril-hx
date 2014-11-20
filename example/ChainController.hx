package  ;

#if !nodejs
import haxe.Serializer;
import haxe.Unserializer;
#end
import haxe.ds.IntMap;
import haxe.Json;
import js.Browser;
import js.html.Event;
import js.html.InputElement;
import js.html.Storage;
import js.Lib;
import mithril.M;
import mithril.M.Module;
import mithril.M.VirtualElement;

class ChainModel extends IntMap<Bool>
{
	#if !nodejs
	static var storage = Browser.window.localStorage;
	#end

	public static function load() : ChainModel {
		#if nodejs
		return new ChainModel();
		#else
		var list = storage.getItem("chain-app-list");
		if(list == "" || list == null) return new ChainModel();

		var ser = new Unserializer(list);
		return cast ser.unserialize();
		#end
	}

	public function new() {
		super();
	}

	public function clear() {
		for(key in keys()) this.remove(key);
		resetDate();
		save();
	}

	public function save() : Void {
		#if !nodejs
		var ser = new Serializer();
		ser.serialize(this);
		storage.setItem("chain-app-list", ser.toString());
		#end
	}

	public function today() : Date {
		var now = Date.now();
		return new Date(now.getFullYear(), now.getMonth(), now.getDay(), 0, 0, 0);
	}

	public function resetDate() : Float {
		var time = today().getTime();
		#if !nodejs
		storage.setItem("chain-app.start-date", Std.string(time));
		#end
		return time;
	}

	public function startDate() : Date {
		#if nodejs
		var date = null;
		#else
		var date = Std.parseInt(storage.getItem("chain-app.start-date"));
		#end
		return Date.fromTime(date == null ? resetDate() : date);
	}

	public function dateAt(days) : Date {
		return Date.fromTime(startDate().getTime() + days * 60 * 60 * 24);
	}
}

class ChainController implements Controller<ChainController>
{
	var list : ChainModel;
	public var view : ChainView;

	public function new() {
		this.list = ChainModel.load();
		this.view = new ChainView(list);
	}

	public function controller() {
	}

	public function clear() {
		M.startComputation();
		list.clear();
		M.endComputation();
	}

	public function isChecked(index) {
		return list.get(index) == true;
	}

	public function check(index : Int, status : Bool) {
		if (list.dateAt(index).getTime() <= list.today().getTime()) {
			list.set(index, status);
			list.save();
		}
	}

	public static function main() {
		var controller = new ChainController();
		M.module(Browser.document.body, { controller: controller.controller, view: controller.view.view });
	}
}

class ChainView implements View<ChainController>
{
	var model : ChainModel;

	public function new(model : ChainModel) {
		this.model = model;
	}

	public function view(ctrl : ChainController) : VirtualElement {
		return m("table", this.seven(function(y) {
			return m("tr", this.seven(function(x) {
				var index = indexAt(x, y);
				return m("td", highlights(index), [
					m("input[type=checkbox]", checks(ctrl, index))
				]);
			}));
		}));
	}

	private function seven(subject)	{
		var output = [];
		var i = -1;
		while (i++ < 6) output.push(subject(i));
		return output;
	}

	public function checks(ctrl : ChainController, index : Int) {
		var attribs : Dynamic = {
			onclick: function(e : Event) {
				var checkBox = cast(e.target, InputElement);
				ctrl.check(index, checkBox.checked);
			},
		};
		
		if(ctrl.isChecked(index)) attribs.checked = "checked";
		return attribs;
	}

	public function highlights(index) {
		return {
			style: {
				background: model.dateAt(index).getTime() == model.today().getTime() ? "silver" : ""
			}
		}
	}

	private function indexAt(x, y) return y * 7 + x;
}