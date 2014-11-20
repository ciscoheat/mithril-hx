package mithril;

import js.Browser;
import js.html.DOMWindow;
import js.html.Element;
import js.Error;
import js.html.Event;
import js.html.XMLHttpRequest;

using Lambda;

private abstract Either<T1, T2, T3, T4>(Dynamic)
from T1 from T2 from T3 from T4 to T1 to T2 to T3 to T4 {}

//////////

@:autoBuild(mithril.macros.ModuleBuilder.build()) interface Model {}

@:autoBuild(mithril.macros.ModuleBuilder.build()) interface View<T> {
	function view(ctrl : T) : VirtualElement;
}

@:autoBuild(mithril.macros.ModuleBuilder.build()) interface Controller<T> {
	function controller() : T;
}

interface Module<T> extends Controller<T> extends View<T> {}

interface DynView extends View<Dynamic> {}
interface DynController extends Controller<Dynamic> {}
interface DynModule extends DynController extends DynView {}


typedef MithrilModule<T> = {
	function controller() : T;
	function view(ctrl : T) : VirtualElement;
}

typedef DynMithrilModule = MithrilModule<Dynamic>;

//////////

typedef GetterSetter<T> = ?T -> T;
typedef EventHandler<T : Event> = T -> Void;

typedef Children = Either<String, VirtualElement, {subtree: String},
	Either<Array<String>, Array<VirtualElement>, Array<{subtree: String}>, Array<Children>>>;

typedef VirtualElement = {
	var tag : String;
	var attributes : Dynamic;
	var children : Children;
};

typedef Promise<T, T2> = {
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
	@:optional var extract : XMLHttpRequest -> XHROptions -> Dynamic;
	@:optional var type : Dynamic -> Void;
	@:optional var config : XMLHttpRequest -> XHROptions -> Null<XMLHttpRequest>;
};

typedef JSONPOptions = {
	var dataType : String;
	var url : String;
	@:optional var callbackKey : String;
	@:optional var data : Dynamic;
};

//////////

@:final @:native("Mithril")
extern class M
{
	public static function m(selector : String, ?attributes : Dynamic, ?children : Children) : VirtualElement;

	public static function module<T>(element : Element, module : MithrilModule<T>) : T;

	public static function prop<T>(?initialValue : T) : GetterSetter<T>;

	public static function withAttr<T, T2>(property : String, ?callback : T -> Void) : EventHandler<T2>;

	@:overload(function() : String {})
	@:overload(function(path : String, ?params : Dynamic) : Void {})
	@:overload(function(element : Element, isInitialized : Bool) : Void {})
	public static function route(
		rootElement : Element,
		defaultRoute : String,
		routes : Dynamic<MithrilModule<Dynamic>>) : Void;

	@:overload(function<T, T2>(options : JSONPOptions) : Promise<T, T2> {})
	public static function request<T, T2>(options : XHROptions) : Promise<T, T2>;

	public static function deferred<T, T2>() : Deferred<T, T2>;

	public static function sync<T, T2>(promises : Array<Promise<T, T2>>) : Promise<T, T2>;

	public static function trust(html : String) : String;

	public static function render(
		rootElement : Element,
		children : Children,
		?forceRecreation : Bool) : Void;

	public static function redraw(?forceSync : Bool) : Void;

	public static function startComputation() : Void;

	public static function endComputation() : Void;

	public static function deps(window : Dynamic) : DOMWindow;

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

	public static inline function _patch(__varName : Dynamic) : Void {
		// Some extra properties that simplifies the API a lot.
		// Also redefines Mithril.module to have access to the current module,
		// and removes ajax requests on Node.js.
		untyped __js__("try {");
		untyped __js__("(function(m) {
			m.m =        m;
			m.__module = m.module;
			m.__cm =     null;
			m.module = function(root, module) { m.__cm = module; return m.__module(root, module); }
			if (typeof module !== 'undefined' && module.exports) 
				m.request = function(xhrOptions) { return m.deferred().promise; };
		})")(__varName);
		// var def = m.deferred(); def.reject(); return def.promise;
		untyped __js__("} catch(_) {}");
	}

	// Stores the current module so it can be used in module() calls (added automatically by macro).
	@:noCompletion public static var __cm : Dynamic;
}
