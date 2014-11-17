package mithril;
import js.Browser;
import js.html.DOMWindow;
import js.html.Element;
import js.Error;

abstract Either<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}

@:autoBuild(mithril.ModuleBuilder.build()) interface View<T>
{
	function view(ctrl : T) : VirtualElement;
}

@:autoBuild(mithril.ModuleBuilder.build()) interface Controller
{
	function controller() : Dynamic;
}

typedef Module<T> = {
	function controller() : Dynamic;
	function view(ctrl : T) : VirtualElement;
}

typedef GetterSetter = Dynamic;
typedef EventHandler = Dynamic

typedef VirtualElement = {
	var tag : String;
	var attributes : Dynamic;
	var children : Dynamic;
};

typedef Promise<T> = {
	function then(?success : Void -> T, ?error : Void -> T) : Promise<T>;
}

typedef Deferred<T> = {
	var promise : Promise<T>;
	function resolve(value : T) : Void;
	function reject(value : T) : Void;
}

typedef XHROptions = Dynamic;

typedef JSONPOptions = {
	var dataType : String;
	var url : String;
	var callbackKey : String;
	var data : Dynamic;
};

class M
{
	static function __init__() {
		// Redefine Mithril.module to have access to the current module.
		untyped __js__("var __m_m = Mithril.module; Mithril.module = function(root, module) { mithril.M.controllerModule = module; return __m_m(root, module); }");
	}

	// Stores the current module so it can be used in module() calls (added automatically by macro).
	@:noCompletion public static var controllerModule : Controller;

	public static function m(selector : String, ?attributes : Dynamic, ?children : Dynamic) : VirtualElement {
		return untyped __js__("Mithril(selector, attributes, children)");
	}

	public static function module<T>(element : Element, module : T) : T {
		return untyped __js__("Mithril.module(element, module)");
	}

	public static function prop<T>(initialValue : T) : GetterSetter	{
		return untyped __js__("Mithril.prop(initialValue)");
	}

	public static function withAttr(property : String, ?callback : Dynamic) : EventHandler {
		return untyped __js__("Mithril.withAttr(property, callback)");
	}

	public static function route(
		?rootElement : Either<Element, String>,
		?defaultRoute : String,
		?routes : Dynamic<Module<Dynamic>>) : Void
	{
		return untyped __js__("Mithril.route(rootElement, defaultRoute, routes)");
	}

	public static function routeParam(key : String) : String {
		return untyped __js__("Mithril.route.param(key)");
	}

	public static var routeMode(get, set) : String;

	@:noCompletion public static function get_routeMode() {
		return untyped __js__("Mithril.route.mode");
	}
	@:noCompletion public static function set_routeMode(s : String) {
		return untyped __js__("Mithril.route.mode = s");
	}

	public static function request<T>(options : Either<XHROptions, JSONPOptions>) : Promise<T> {
		return untyped __js__("Mithril.request(options)");
	}

	public static function deferred<T>() : Deferred<T> {
		return untyped __js__("Mithril.deferred()");
	}

	public static var deferredOnerror(get, set) : Error -> Void;

	@:noCompletion public static function get_deferredOnerror() {
		return untyped __js__("Mithril.deferred.onerror");
	}
	@:noCompletion public static function set_deferredOnerror(f : Error -> Void) {
		return untyped __js__("Mithril.deferred.onerror = f");
	}

	public static function sync<T>(promises : Array<Promise<T>>) : Promise<T> {
		return untyped __js__("Mithril.sync(promises)");
	}

	public static function trust(html : String) : String {
		return untyped __js__("Mithril.trust(html)");
	}

	public static function render(rootElement : Element, children : Dynamic, forceRecreation : Bool) {
		return untyped __js__("Mithril.render(rootElement, children, forceRecreation)");
	}

	public static function redraw(forceSync : Bool) : Void {
		return untyped __js__("Mithril.redraw(forceSync)");
	}

	public static var redrawStrategy(get, set) : String;

	@:noCompletion public static function get_redrawStrategy() {
		return untyped __js__("Mithril.redraw.strategy");
	}
	@:noCompletion public static function set_redrawStrategy(s : String) {
		return untyped __js__("Mithril.redraw.strategy = s");
	}

	public static function startComputation() : Void {
		return untyped __js__("Mithril.startComputation()");
	}

	public static function endComputation() : Void {
		return untyped __js__("Mithril.endComputation()");
	}

	public static function deps(window : Dynamic) : DOMWindow {
		return untyped __js__("Mithril.deps(window)");
	}
}
