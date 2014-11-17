package mithril;
import js.html.Element;

typedef Module = {
	function controller() : Dynamic;
	function view() : VirtualElement;
}

extern class VirtualElement
{}

//@:native('m')
class M
{
	public static var modules = new List<Module>();

	public static function m(selector : String, ?attributes : Dynamic, ?children : Dynamic) : VirtualElement
	{
		if (attributes == null && children == null)
			return untyped __js__("Mithril(selector)");
		else if(attributes != null)
			return untyped __js__("Mithril(selector, attributes)");
		else
			return untyped __js__("Mithril(selector, attributes, children)");
	}

	public static function module(element : Element, module : Module) : Dynamic
	{
		modules.push(module);
		return untyped __js__("Mithril.module(element, module)");
	}
}
