package mithril;

using Lambda;
using StringTools;

#if js
import js.Browser;
import js.html.Document;
import js.html.Event;
import js.html.Element;
import js.html.XMLHttpRequest;
import js.Error;
#elseif !dom_implemented
typedef Browser = Dynamic;
typedef Document = Dynamic;
typedef Event = Dynamic;
typedef Element = Dynamic;
typedef XMLHttpRequest = Dynamic;
typedef Error = Dynamic;
typedef InputElement = Dynamic;
#end

private abstract Either<T1, T2>(Dynamic)
from T1 from T2 to T1 to T2 {}

private abstract Either3<T1, T2, T3>(Dynamic)
from T1 from T2 from T3 to T1 to T2 to T3 {}

private abstract Either4<T1, T2, T3, T4>(Dynamic)
from T1 from T2 from T3 from T4 to T1 to T2 to T3 to T4 {}

///// Interfaces /////

@:autoBuild(mithril.macros.ModuleBuilder.build(0)) interface Model {}

@:autoBuild(mithril.macros.ModuleBuilder.build(1)) interface View<T> {
	function view(ctrl : T) : Children;
}

@:autoBuild(mithril.macros.ModuleBuilder.build(2)) interface Controller<T> {
	/**
	 * When implementing Controller<T>, the method will automatically return "this"
	 * unless otherwise specified.
	 */
	function controller() : T;
}

@:autoBuild(mithril.macros.ModuleBuilder.build(3)) interface Module<T> {
	function controller() : T;
	function view(ctrl : T) : ViewOutput;
}

///// Typedefs /////

typedef BasicType = Either4<Bool, Float, Int, String>;

/**
 * A typedef of View<T> and Controller<T>, so it can be used by anonymous objects.
 * If you're using a class, implement Module<T> to get macro benefits.
 */
typedef MithrilModule<T> = {
	function controller() : T;
	function view(ctrl : T) : Children;
}

typedef GetterSetter<T> = ?T -> T;
typedef EventHandler<T : Event> = T -> Void;

typedef Children = Either4<BasicType, VirtualElement, {subtree: String},
	Either3<Array<BasicType>, Array<VirtualElement>, Array<{subtree: String}>>>;

typedef VirtualElement = {
	var tag : String;
	var attrs : Dynamic;
	var children : Children;
};

typedef ViewOutput = Either4<VirtualElement, BasicType, Array<VirtualElement>, Array<BasicType>>;

typedef Promise<T, T2> = {
	// Haxe limitation: Cannot expose the GetterSetter directly. then() is required to get value.
	function then<T3, T4>(?success : T -> T3, ?error : T2 -> T4) : Promise<T3, T4>;
}

typedef Deferred<T, T2> = {
	var promise : Promise<T, T2>;
	function resolve(value : T) : Void;
	function reject(value : T2) : Void;
}

/**
 * Plenty of optional fields for this one:
 * http://lhorie.github.io/mithril/mithril.request.html#signature
 */
typedef XHROptions = {
	var method : String;
	var url : String;
	@:optional var user : String;
	@:optional var password : String;
	@:optional var data : Dynamic;
	@:optional var background : Bool;
	@:optional var initialValue : Dynamic;
	@:optional var unwrapSuccess : Dynamic -> Dynamic;
	@:optional var unwrapError : Dynamic -> Dynamic;
	@:optional var serialize : Dynamic -> String;
	@:optional var deserialize : String -> Dynamic;
	@:optional var extract : XMLHttpRequest -> XHROptions -> String;
	@:optional var type : Dynamic -> Void;
	@:optional var config : XMLHttpRequest -> XHROptions -> Null<XMLHttpRequest>;
};

typedef JSONPOptions = {
	var dataType : String;
	var url : String;
	@:optional var callbackKey : String;
	@:optional var data : Dynamic;
};

#if js

///// Externs for javascript (including Node.js) /////

@:final @:native("Mithril")
extern class M
{
	public static function m(selector : String, ?attributes : Dynamic, ?children : Children) : VirtualElement;

	public static function module<T>(element : Element, module : MithrilModule<T>) : T;

	public static function prop<T>(?initialValue : T) : GetterSetter<T>;

	public static function withAttr<T, T2>(property : String, ?callback : T -> Void) : EventHandler<T2>;

	@:overload(function() : String {})
	@:overload(function(element : Element, isInitialized : Bool) : Void {})
	@:overload(function(path : String, ?params : Dynamic, ?shouldReplaceHistory : Bool) : Void {})
	public static function route(rootElement : Element, defaultRoute : String, routes : Dynamic<MithrilModule<Dynamic>>) : Void;

	@:overload(function<T, T2>(options : JSONPOptions) : Promise<T, T2> {})
	public static function request<T, T2>(options : XHROptions) : Promise<T, T2>;

	public static function deferred<T, T2>() : Deferred<T, T2>;

	public static function sync<T, T2>(promises : Array<Promise<T, T2>>) : Promise<T, T2>;

	public static function trust(html : String) : String;

	@:overload(function(rootElement : Document, children : Children, ?forceRecreation : Bool) : Void {})
	public static function render(rootElement : Element, children : Children, ?forceRecreation : Bool) : Void;

	public static function redraw(?forceSync : Bool) : Void;

	public static function startComputation() : Void;

	public static function endComputation() : Void;

	public static function deps(window : Dynamic) : Dynamic;

	///// Properties that uses function properties /////

	public static var routeParam(get, set) : String -> String;
	static inline function get_routeParam() : String -> String { return untyped __js__("Mithril.route.param"); }
	static inline function set_routeParam(f : String -> String) : String -> String { return untyped __js__("Mithril.route.param = ") (f); }

	public static var redrawStrategy(get, set) : GetterSetter<String>;
	static inline function get_redrawStrategy() : GetterSetter<String> { return untyped __js__("Mithril.redraw.strategy"); }
	static inline function set_redrawStrategy(s : GetterSetter<String>) : GetterSetter<String> { return untyped __js__("Mithril.redraw.strategy = ") (s); }

	public static var routeMode(get, set) : String;
	static inline function get_routeMode() : String { return untyped __js__("Mithril.route.mode"); }
	static inline function set_routeMode(s : String) : String { return untyped __js__("Mithril.route.mode = ") (s); }

	public static var deferredOnerror(get, set) : Error -> Void;
	static inline function get_deferredOnerror() : Error -> Void { return untyped __js__("Mithril.deferred.onerror"); }
	static inline function set_deferredOnerror(f : Error -> Void) : Error -> Void { return untyped __js__("Mithril.deferred.onerror = ") (f); }

	///// Haxe specific stuff /////

	static function __init__() : Void {
		// Hacking time! For patching window.Mithril and the Node module.
		// Pass a property of window with the same value as the @:native metadata
		// to the inline function. It will be replaced with the var name.
		untyped __js__("try {");
		_patch(untyped Browser.window.Mithril);
		_patch(untyped __js__('require("mithril")'));
		untyped __js__("} catch(_) {}");
	}

	@:noCompletion public static inline function _patch(__varName : Dynamic) : Void {
		// Some extra properties that simplifies the API a lot.
		// Also redefines Mithril.module to have access to the current module,
		// and prevents deferred being resolved on Node.js.
		untyped __js__("try {");
		untyped __js__("(function(m) {
			m.m =        m;
			m.__module = m.module;
			m.__cm =     null;
			m.module = function(root, module) { m.__cm = module; return m.__module(root, module); }
			if (typeof module !== 'undefined' && module.exports) // Node.js detection
				m.request = function(xhrOptions) { return m.deferred().promise; };
		})")(__varName);
		untyped __js__("} catch(_) {}");
	}

	// Stores the current module so it can be used in module() calls (added automatically by macro).
	@:noCompletion public static var __cm : Dynamic;
}
#else

///// Implementation of Mithril for other platforms than js /////

private class MPromise<T, T2> {
	public function new() {}
	public function then<T3, T4>(?success : T -> T3, ?error : T2 -> T4) : Promise<T3, T4> {
		return new MPromise();
	}
}

/**
* Since M is used by macros to call M.instance, this class can be used to configure
* the actual instance retrieval.
*/
class MConfig
{
	public static var instance(default, default) : MConfig = new MConfig();

	public var currentMithril(default, default) : Void -> M;

	var mithril : M;

	public function new() {
		mithril = new M();
		currentMithril = function() return mithril;
	}
}

class M
{
	/**
	 * Singleton access to the current M instance. Not part of the Mithril API.
	 * In a class implementing one of the Module/Model/View/Controller interfaces
	 * this is not required, you can use M directly from there. It will look like a static
	 * call but macros will transform it to M.instance.
	 */
	public static var instance(get, null) : M;
	static function get_instance() return MConfig.instance.currentMithril();

	static var parser : EReg = ~/(?:(^|#|\.)([^#\.\[\]]+))|(\[.+?\])/g;
	static var attrParser : EReg = ~/\[(.+?)(?:=("|'|)(.*?)\2)?\]/;
	static var voidElements : EReg = ~/^(AREA|BASE|BR|COL|COMMAND|EMBED|HR|IMG|INPUT|KEYGEN|LINK|META|PARAM|SOURCE|TRACK|WBR)$/;
	static var voidElementsArray = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 
									'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr'];

	public function new() {
		this.redrawStrategy = this.prop(null);
		this.routeParam = function(s) return "";
		this.deferredOnerror = function(_) {};
	}

	public function m(selector : String, ?attributes : Dynamic, ?children : Children) : VirtualElement {
		var hasAttrs = Reflect.isObject(attributes) && Type.getClass(attributes) == null &&
			!Reflect.hasField(attributes, "tag") && !Reflect.hasField(attributes, "subtree");

		var attrs = hasAttrs ? attributes : {};
		var classAttrName = Reflect.hasField(attrs, "class") ? "class" : "className";
		var cell : Dynamic = {tag: "div", attrs: {}};
		var match = [];
		var classes = [];

		var isEmpty = function(s : String) { return s == null || s == ""; };

		var tempSelector = selector;
		while(parser.match(tempSelector)) {
			var m = parser.matched;
			if(m(1) == "" && !isEmpty(m(2))) cell.tag = m(2);
			else if(m(1) == "#") cell.attrs.id = m(2);
			else if(m(1) == ".") classes.push(m(2));
			else {
				var attr = m(3);
				if(attr.substr(0, 1) == "[") {
					attrParser.match(attr);
					var value = attrParser.matched(3);
					Reflect.setField(cell.attrs, attrParser.matched(1), 
						isEmpty(value) 
							? isEmpty(attrParser.matched(2)) ? "" : true
							: value
					);
				}
			}
			tempSelector = parser.matchedRight();
		}
		if(classes.length > 0) {
			Reflect.setField(cell.attrs, classAttrName, classes.join(" "));
		}

		var realChildren : Children = cast (children == null ? attributes : children);
		if(Std.is(realChildren, Array)) {
			Reflect.setField(cell, "children", realChildren);
		} else {
			var childArray = [];
			if(attributes != null && !hasAttrs) childArray.push(attributes);
			else if(children != null) childArray.push(children);
			Reflect.setField(cell, "children", childArray);
		}

		//trace('##### $selector #####');

		for (attrName in Reflect.fields(attrs)) {
			var attrValue = Reflect.field(attrs, attrName);			
			//trace('# $attrName => ' + attrValue);
			if(attrName == classAttrName) {
				var cellValue = Reflect.field(cell.attrs, attrName);
				Reflect.setField(cell.attrs, attrName, (cellValue == null ? "" : cellValue) + " " + attrValue);
			} else {
				Reflect.setField(cell.attrs, attrName, attrValue);
			}
		}

		return cell;
	}

	public function render(view : Children) : String {
		if(view == null) return "";
		if(Std.is(view, String)) return cast view;
		if(Std.is(view, Array)) return cast(view, Array<Dynamic>).map(render).join('');

		// view must be a VirtualElement now.
		var el : VirtualElement = cast view;
		// Special case for trusted data.
		if(el.tag == "$trusted") return createTrustedContent(el);

		var children = createChildrenContent(el);
		if(children.length == 0 && voidElementsArray.indexOf(el.tag) >= 0) {
			return '<' + el.tag + createAttrString(el.attrs) + '>';
		}

		return [
			'<', el.tag, createAttrString(el.attrs), '>',
			children,
			'</', el.tag, '>'
		].join('');
	}

	function createChildrenContent(el : VirtualElement) : String {
		if(el.children == null || !Std.is(el.children, Array)) return '';
		return render(cast el.children);
	}

	function createTrustedContent(el : VirtualElement) : String {
		return el.attrs;
	}

	function createAttrString(attrs : Dynamic) {
		if(attrs == null || Reflect.fields(attrs).length == 0) return '';

		return Reflect.fields(attrs).map(function(name) {
			var value = Reflect.field(attrs, name);
			if(Reflect.isFunction(value)) return '';

			if(name == 'style') {
				return ' style="' + Reflect.fields(value).map(function(property) {
					return [camelToDash(property).toLowerCase(), Reflect.field(value, property)].join(':');
				}).join(';') + '"';
			}
			return ' ' + (name == 'className' ? 'class' : name) + '="' + value + '"';
		}).join('');
	}

	function camelToDash(str : String) {
		str = (~/\W+/g).replace(str, '-');
		return (~/([a-z\d])([A-Z])/g).replace(str, '$1-$2');		
	}

	public function trust(v : Dynamic) {
		return {
			tag: "$trusted",
			attrs: Std.string(v),
			children: []
		}
	}

	public function prop<T>(?initialValue : T) : GetterSetter<T> { 
		var value = initialValue;
		return function(?v) { if(v != null) value = v; return value; }; 
	}

	///// Stubs /////

	public function module<T>(element : Element, module : MithrilModule<T>) : T { return module.controller(); }
	public function route(rootElement : Element, defaultRoute : String, routes : Dynamic<MithrilModule<Dynamic>>) : Void {}
	public function request<T, T2>(options : Either<XHROptions, JSONPOptions>) : Promise<T, T2> { return new MPromise(); }
	public function sync<T, T2>(promises : Array<Promise<T, T2>>) : Promise<T, T2> { return new MPromise(); }
	public function redraw(?forceSync : Bool) : Void {}
	public function deps(window : Dynamic) : Dynamic { return window; }
	public function startComputation() : Void {}
	public function endComputation() : Void {}
	public function withAttr<T, T2>(property : String, ?callback : T -> Void) : EventHandler<T2> { return function(_) {}; }
	public function deferred<T, T2>() : Deferred<T, T2> { 
		return {
			promise: new MPromise(),
			resolve: function(_) {},
			reject: function(_) {}
		}; 
	}

	public var routeParam(default, default) : String -> String; 
	public var redrawStrategy(default, default) : GetterSetter<String>;
	public var routeMode(default, default) : String;
	public var deferredOnerror(default, default) : Error -> Void;

	// Stores the current module so it can be used in module() calls (added automatically by macro).
	@:noCompletion public var __cm : Dynamic;
}
#end
