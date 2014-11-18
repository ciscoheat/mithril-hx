package mithril;

import js.Browser;
import js.html.DOMWindow;
import js.html.Element;
import js.Error;
import js.html.Event;

using Lambda;

private abstract Either<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}

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

//////////

typedef MithrilModule<T, T2> = {
	function controller() : T;
	function view(ctrl : T2) : VirtualElement;
}

typedef GetterSetter<T> = ?T -> T;
typedef EventHandler<T : Event> = T -> Void;

typedef VirtualElement = {
	var tag : String;
	var attributes : Dynamic;
	var children : Dynamic;
};

typedef Promise<T, T2> = {
	function then<T3, T4>(?success : GetterSetter<T> -> T3, ?error : GetterSetter<T2> -> T4) : Promise<T3, T4>;
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
};

typedef JSONPOptions = {
	var dataType : String;
	var url : String;
	var callbackKey : String;
	var data : Dynamic;
};

//////////

@:final @:native("Mithril")
extern class M
{
	public static function m(selector : String, ?attributes : Dynamic, ?children : Dynamic) : VirtualElement;

	public static function module<T, T2>(element : Element, module : MithrilModule<T, T2>) : T;

	public static function prop<T>(initialValue : T) : GetterSetter<T>;

	public static function withAttr<T, T2>(property : String, ?callback : T -> Void) : EventHandler<T2>;

	public static function route(?rootElement : Either<Element, String>, ?defaultRoute : Dynamic, ?routes : Dynamic<MithrilModule<Dynamic, Dynamic>>) : String;

	public static function request<T, T2>(options : Either<XHROptions, JSONPOptions>) : Promise<T, T2>;

	public static function deferred<T, T2>() : Deferred<T, T2>;

	public static function sync<T, T2>(promises : Array<Promise<T, T2>>) : Promise<T, T2>;

	public static function trust(html : String) : String;

	public static function render(rootElement : Element, children : Dynamic, forceRecreation : Bool) : Void;

	public static function redraw(?forceSync : Bool) : Void;

	public static function startComputation() : Void;

	public static function endComputation() : Void;

	public static function deps(window : Dynamic) : DOMWindow;

	///// Properties that uses function properties /////

	public static function routeParam(key : String) : String;

	public static var routeMode : String;

	public static var deferredOnerror : Error -> Void;

	public static var redrawStrategy : String;

	///// Haxe specific stuff /////

	static function __init__() : Void {
		// Add properties to support function properties in javascript
		untyped __js__("
			Mithril.m =               Mithril;
			Mithril.routeParam =      Mithril.route.param;
			Mithril.routeMode =       Mithril.route.mode;
			Mithril.deferredOnerror = Mithril.deferred.onerror;
			Mithril.redrawStrategy =  Mithril.redraw.strategy;
			Mithril.__module =        Mithril.module;
			Mithril.__cm =            null;
		");

		// Redefine Mithril.module to have access to the current module.
		untyped __js__("Mithril.module = function(root, module) { Mithril.__cm = module; return Mithril.__module(root, module); }");
	}

	// Stores the current module so it can be used in module() calls (added automatically by macro).
	@:noCompletion public static var __cm : Dynamic;
}
