package mithril;
import js.html.Element;

abstract Either<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}

@:autoBuild(mithril.ModuleBuilder.build()) interface Module
{
	function controller() : Dynamic;
	function view() : VirtualElement;
}

typedef GetterSetter = Dynamic;
typedef EventHandler = Dynamic

typedef VirtualElement = {
	var tag : String;
	var attributes : Dynamic;
	var children : Dynamic;
};

class M
{
	static function __init__() {
		// Redefine Mithril.module to have access to the current module.
		untyped __js__("var __m_m = Mithril.module; Mithril.module = function(root, module) { mithril.M.controllerModule = module; return __m_m(root, module); }");
	}

	// Stores the current module so it can be used in module() calls (added automatically by macro).
	public static var controllerModule : Module;

	public static function m(selector : String, ?attributes : Dynamic, ?children : Dynamic) : VirtualElement
	{
		if (attributes != null && children != null)
			return untyped __js__("Mithril(selector, attributes, children)");
		else if(attributes != null)
			return untyped __js__("Mithril(selector, attributes)");
		else
			return untyped __js__("Mithril(selector)");
	}

	public static function module(element : Element, module : Module) : Dynamic
	{
		return untyped __js__("Mithril.module(element, module)");
	}

	public static function prop<T>(initialValue : T) : GetterSetter
	{
		return untyped __js__("Mithril.prop(initialValue)");
	}

	public static function withAttr(property : String, ?callback : Dynamic) : EventHandler
	{
		return untyped __js__("Mithril.withAttr(property, callback)");
	}

	public static function route(?rootElement : Either<Element, String>, ?defaultRoute : String, ?routes : Dynamic<Module>) : Void
	{
		if (rootElement != null && defaultRoute != null && routes != null)
			return untyped __js__("Mithril.route(rootElement, defaultRoute, routes)");
		else if(rootElement != null && defaultRoute != null)
			return untyped __js__("Mithril.route(rootElement, defaultRoute)");
		else if (rootElement != null)
			return untyped __js__("Mithril.route(rootElement)");
		else
			return untyped __js__("Mithril.route()");
	}

	public static function routeParam(key : String) : String {
		return untyped __js__("Mithril.route.param(key)");
	}

	public static var routeMode(get, set) : String;

	public static function get_routeMode() {
		return untyped __js__("Mithril.route.mode");
	}
	public static function set_routeMode(s : String) {
		return untyped __js__("Mithril.route.mode = s");
	}
}
