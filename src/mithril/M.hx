package mithril;

import js.Browser;
import js.html.Document;
import js.html.DOMWindow;
#if (haxe_ver >= 3.2)
import js.html.DOMElement in Element;
#else
import js.html.Element;
#end
import js.Error;
import js.html.Event;
import js.html.XMLHttpRequest;

using Lambda;

private abstract Either<T1, T2>(Dynamic)
from T1 from T2 to T1 to T2 {}

private abstract Either3<T1, T2, T3>(Dynamic)
from T1 from T2 from T3 to T1 to T2 to T3 {}

private abstract Either4<T1, T2, T3, T4>(Dynamic)
from T1 from T2 from T3 from T4 to T1 to T2 to T3 to T4 {}

///// Interfaces /////

@:autoBuild(mithril.macros.ModuleBuilder.build(0)) interface Model {}

@:autoBuild(mithril.macros.ModuleBuilder.build(1)) interface View {
	function view() : ViewOutput;
}

@:autoBuild(mithril.macros.ModuleBuilder.build(1)) interface ControllerView<T> {
	function view(?ctrl : T) : ViewOutput;
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
	function view(?ctrl : T) : ViewOutput;
}

///// Typedefs /////

typedef BasicType = Either4<Bool, Float, Int, String>;

/**
 * A typedef of View<T> and Controller<T>, so it can be used by anonymous objects.
 * If you're using a class, implement Module<T> to get macro benefits.
 */
typedef MithrilModule<T> = {
	function controller() : T;
	function view(?ctrl : T) : ViewOutput;
}

typedef GetterSetter<T> = ?T -> T;
typedef EventHandler<T : Event> = T -> Void;

typedef VirtualElement = {
	var tag : String;
	var attrs : Dynamic;
	var children : Dynamic;
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

typedef DataConstructible<T> = {
	public function new(data : T) : Void;
}

/**
 * Plenty of optional fields for this one:
 * http://lhorie.github.io/mithril/mithril.request.html#signature
 */
typedef XHROptions<T, T2, T3, T4> = {
	var method : String;
	var url : String;
	@:optional var user : String;
	@:optional var password : String;
	@:optional var data : Dynamic;
	@:optional var background : Bool;
	@:optional var initialValue : T;
	@:optional var unwrapSuccess : Dynamic -> T;
	@:optional var unwrapError : Dynamic -> T2;
	@:optional var serialize : T3 -> T4;
	@:optional var deserialize : T4 -> T3;
	@:optional var extract : XMLHttpRequest -> XHROptions<T, T2, T3, T4> -> T4;
	@:optional var config : XMLHttpRequest -> XHROptions<T, T2, T3, T4> -> Null<XMLHttpRequest>;
};

/**
 * A limitation here is that you must specify the correct callback yourself.
 * If you're returing Array<T5> from unwrapSuccess, make you're using
 * then(Array<T5>).
 */
typedef XHRTypeOptions<T : Either<DataConstructible<T5>, Array<DataConstructible<T5>>>, T2, T3, T4, T5> = {
	var method : String;
	var url : String;
	var type : Class<DataConstructible<T5>>;
	@:optional var user : String;
	@:optional var password : String;
	@:optional var data : Dynamic;
	@:optional var background : Bool;
	@:optional var initialValue : T;
	@:optional var unwrapSuccess : Dynamic -> Either<Array<T5>, T5>;
	@:optional var unwrapError : Dynamic -> T2;
	@:optional var serialize : T3 -> T4;
	@:optional var deserialize : T4 -> T3;
	@:optional var extract : XMLHttpRequest -> XHRTypeOptions<T, T2, T3, T4, T5> -> T4;
	@:optional var config : XMLHttpRequest -> XHRTypeOptions<T, T2, T3, T4, T5> -> Null<XMLHttpRequest>;
};

typedef JSONPOptions = {
	var dataType : String;
	var url : String;
	@:optional var callbackKey : String;
	@:optional var data : Dynamic;
};

//////////

@:final @:native("m")
extern class M
{
	@:overload(function(selector : String, ?attributes : Dynamic, ?children : Array<Array<{subtree: String}>>) : VirtualElement {})
	@:overload(function(selector : String, ?attributes : Dynamic, ?children : Array<Array<VirtualElement>>) : VirtualElement {})
	@:overload(function(selector : String, ?attributes : Dynamic, ?children : Array<Array<String>>) : VirtualElement {})
	@:overload(function(selector : String, ?attributes : Dynamic, ?children : Array<{subtree: String}>) : VirtualElement {})
	@:overload(function(selector : String, ?attributes : Dynamic, ?children : Array<VirtualElement>) : VirtualElement {})
	@:overload(function(selector : String, ?attributes : Dynamic, ?children : Array<String>) : VirtualElement {})
	@:overload(function(selector : String, ?attributes : Dynamic, ?children : {subtree: String}) : VirtualElement {})
	@:overload(function(selector : String, ?attributes : Dynamic, ?children : String) : VirtualElement {})
	public static function m(selector : String, ?attributes : Dynamic, ?children : VirtualElement) : VirtualElement;

	public static function mount<T>(element : Element, module : T) : T;
	public static function module<T>(element : Element, module : T) : T;

	public static function prop<T>(?initialValue : T) : GetterSetter<T>;

	public static function withAttr<T, T2 : Event>(property : String, ?callback : T -> Void) : EventHandler<T2>;

	@:overload(function() : String {})
	@:overload(function(element : Document, isInitialized : Bool) : Void {})
	@:overload(function(element : Element, isInitialized : Bool) : Void {})
	@:overload(function(path : String, ?params : Dynamic, ?shouldReplaceHistory : Bool) : Void {})
	public static function route(rootElement : Element, defaultRoute : String, routes : Dynamic) : Void;

	@:overload(function<T, T2>(options : JSONPOptions) : Promise<T, T2> {})
	@:overload(function<T : Either<DataConstructible<T5>, Array<DataConstructible<T5>>>, T2, T3, T4, T5>(options : XHRTypeOptions<T, T2, T3, T4, T5>) : Promise<T, T2> {})
	public static function request<T, T2, T3, T4>(options : XHROptions<T, T2, T3, T4>) : Promise<T, T2>;

	public static function deferred<T, T2>() : Deferred<T, T2>;

	public static function sync<T, T2>(promises : Array<Promise<T, T2>>) : Promise<T, T2>;

	public static function trust(html : String) : String;

	@:overload(function(rootElement : Document, children : Array<{subtree: String}>, ?forceRecreation : Bool) : Void {})
	@:overload(function(rootElement : Document, children : Array<VirtualElement>, ?forceRecreation : Bool) : Void {})
	@:overload(function(rootElement : Document, children : Array<String>, ?forceRecreation : Bool) : Void {})
	@:overload(function(rootElement : Document, children : {subtree: String}, ?forceRecreation : Bool) : Void {})
	@:overload(function(rootElement : Document, children : VirtualElement, ?forceRecreation : Bool) : Void {})
	@:overload(function(rootElement : Document, children : String, ?forceRecreation : Bool) : Void {})
	@:overload(function(rootElement : Element, children : Array<{subtree: String}>, ?forceRecreation : Bool) : Void {})
	@:overload(function(rootElement : Element, children : Array<VirtualElement>, ?forceRecreation : Bool) : Void {})
	@:overload(function(rootElement : Element, children : Array<String>, ?forceRecreation : Bool) : Void {})
	@:overload(function(rootElement : Element, children : {subtree: String}, ?forceRecreation : Bool) : Void {})
	@:overload(function(rootElement : Element, children : VirtualElement, ?forceRecreation : Bool) : Void {})
	public static function render(rootElement : Element, children : String, ?forceRecreation : Bool) : Void;

	public static function redraw(?forceSync : Bool) : Void;

	public static function startComputation() : Void;

	public static function endComputation() : Void;

	public static function deps(window : Dynamic) : Dynamic;

	///// Properties that uses function properties /////

	public static var routeParam(get, set) : String -> String;
	static inline function get_routeParam() : String -> String { return untyped __js__("m.route.param"); }
	static inline function set_routeParam(f : String -> String) : String -> String { return untyped __js__("m.route.param = ") (f); }

	public static var redrawStrategy(get, set) : GetterSetter<String>;
	static inline function get_redrawStrategy() : GetterSetter<String> { return untyped __js__("m.redraw.strategy"); }
	static inline function set_redrawStrategy(s : GetterSetter<String>) : GetterSetter<String> { return untyped __js__("m.redraw.strategy = ") (s); }

	public static var routeMode(get, set) : String;
	static inline function get_routeMode() : String { return untyped __js__("m.route.mode"); }
	static inline function set_routeMode(s : String) : String { return untyped __js__("m.route.mode = ") (s); }

	public static var deferredOnerror(get, set) : Dynamic -> Void;
	static inline function get_deferredOnerror() : Dynamic -> Void { return untyped __js__("m.deferred.onerror"); }
	static inline function set_deferredOnerror(f : Dynamic -> Void) : Dynamic -> Void { return untyped __js__("m.deferred.onerror = ") (f); }

	///// Haxe specific stuff /////

	static function __init__() : Void {
		// Hacking time! For patching window.m and the Node module.
		// Pass a property of window with the same value as the @:native metadata
		// to the inline function. It will be replaced with the var name.
		untyped __js__("try {");
		_patch(untyped Browser.window.m);
		untyped __js__("} catch(_) {}");
		// Node patch
		untyped __js__("try {");
		untyped __js__('GLOBAL.m = require("mithril")');
		_patch(untyped __js__('GLOBAL.m'));
		untyped __js__("} catch(_) {}");
	}

	@:noCompletion public static inline function _patch(__varName : Dynamic) : Void {
		// Some extra properties that simplifies the API.
		// Also redefines m.module to have access to the current module
		// because m.module makes a "new controller.module()" call which
		// removes the actual module from the scope.
		// It also prevents deferred being resolved on Node.js
		// to avoid server rendering issues.
		untyped __js__("(function(m) {
			m.m         = m;
			m.__mount   = m.mount;
			m.__currMod = null;
			m.mount = function(root, component) { m.__currMod = component; return m.__mount(root, component); }
			if (typeof module !== 'undefined' && module.exports) 
				m.request = function(xhrOptions) { return m.deferred().promise; };
		})")(__varName);
	}

	// Stores the current module so it can be used in controller.module() 
	// calls. See above (injected automatically in macros.ModuleBuilder).
	@:noCompletion public static var __currMod : Dynamic;
}
