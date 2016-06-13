package mithril;

using Lambda;

#if js
import js.Browser;
import js.html.Document;

#if (haxe_ver >= 3.2)
import js.html.DOMElement in Element;
#else
import js.html.Element;
#end

import js.Error;
import js.html.Event;
import js.html.XMLHttpRequest;
#else
// Mock js classes for server rendering
typedef XMLHttpRequest = Dynamic;
typedef Event = Dynamic;
#end

/////////////////////////////////////////////////////////////

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

@:autoBuild(mithril.macros.ModuleBuilder.build(2)) interface Controller<T> {
	function controller() : T;
}

/**
 * Haxe-style Component
 */
@:autoBuild(mithril.macros.ModuleBuilder.build(2)) interface Component {
	function controller() : Dynamic;
	function view() : ViewOutput;
}

/**
 * The loosely-typed path
 */
@:autoBuild(mithril.macros.ModuleBuilder.build(2)) interface Mithril {}

///// Deprecated interfaces /////

@:deprecated('ControllerView<T> is deprecated: Use Mitril instead')
@:autoBuild(mithril.macros.ModuleBuilder.build(1)) interface ControllerView<T> {
	function view(?ctrl : T) : ViewOutput;
}

@:deprecated('Module<T> interface is deprecated: Use Component or Mithril instead') 
@:autoBuild(mithril.macros.ModuleBuilder.build(3)) interface Module<T> {
	function controller() : T;
	function view(?ctrl : T) : ViewOutput;
}

@:deprecated('MithrilModule<T> is deprecated and can be removed.')
typedef MithrilModule<T> = {
	function controller() : T;
	function view(?ctrl : T) : ViewOutput;
}

///// Typedefs /////

typedef BasicType = Either4<Bool, Float, Int, String>;

typedef VirtualElementObject = {
	var tag : String;
	var attrs : Dynamic;
	var children : Dynamic;
};

typedef VirtualElement = Either<VirtualElementObject, Array<VirtualElementObject>>;

typedef ViewOutput = Either3<VirtualElement, BasicType, Array<BasicType>>;

typedef GetterSetter<T> = ?T -> T;
typedef EventHandler<T : Event> = T -> Void;

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

typedef JSONPOptions<T, T2> = {
	var dataType : String;
	var url : String;
	@:optional var callbackKey : String;
	@:optional var data : Dynamic;
	@:optional var background : Bool;
	@:optional var initialValue : T;
	@:optional var unwrapSuccess : Dynamic -> T;
	@:optional var unwrapError : Dynamic -> T2;
};

//////////

#if js
@:final @:native("m")
extern class M
{
	@:overload(function(selector : String) : VirtualElement {})
	@:overload(function(selector : String, attributes : Dynamic) : VirtualElement {})
	public static function m(selector : String, attributes : Dynamic, children : Dynamic) : VirtualElement;

	@:overload(function<T, T2, T3, T4, T5>(component : T, args : T2, extra1 : T3, extra2 : T4, extra3 : T5) : Dynamic {})
	@:overload(function<T, T2, T3, T4>(component : T, args : T2, extra1 : T3, extra2 : T4) : Dynamic {})
	@:overload(function<T, T2, T3>(component : T, args : T2, extra1 : T3) : Dynamic {})
	@:overload(function<T, T2>(component : T, args : T2) : Dynamic {})
	public static function component<T>(component : T) : Dynamic;

	public static function mount<T>(element : Element, component : T) : T;

	@:deprecated("M.module is deprecated: Use M.mount instead") 
	public static function module<T>(element : Element, module : T) : T;

	public static function prop<T>(?initialValue : T) : GetterSetter<T>;

	public static function withAttr<T, T2 : Event>(property : String, ?callback : T -> Void) : EventHandler<T2>;

	@:overload(function() : String {})
	@:overload(function(element : Document, isInitialized : Bool) : Void {})
	@:overload(function(element : Element, isInitialized : Bool) : Void {})
	@:overload(function(path : String) : Void {})
	@:overload(function(path : String, params : Dynamic) : Void {})
	@:overload(function(path : String, params : Dynamic, shouldReplaceHistory : Bool) : Void {})
	public static function route(rootElement : Element, defaultRoute : String, routes : Dynamic) : Void;

	@:overload(function<T, T2>(options : JSONPOptions<T, T2>) : Promise<T, T2> {})
	public static function request<T, T2, T3, T4>(options : XHROptions<T, T2, T3, T4>) : Promise<T, T2>;

	public static function deferred<T, T2>() : Deferred<T, T2>;

	public static function sync<T, T2>(promises : Array<Promise<T, T2>>) : Promise<T, T2>;

	public static function trust(html : String) : String;

	@:overload(function(rootElement : Element, children : Dynamic) : Void {})
	public static function render(rootElement : Element, children : Dynamic, forceRecreation : Bool) : Void;

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
		// Also makes a stack-based access to the current component
		// because m.mount and m.component makes a "new component.controller()" call which
		// removes the actual component from the scope.
		// It also prevents deferred being resolved on Node.js to avoid server rendering issues,
		// and converts List to Array so Lambda.map can be used conveniently.
		untyped __js__("(function(m) {
			if (m.__haxecomponents) return;
			m.m = function() {
				try { 
					for(var i=0; i < arguments.length; ++i) if(arguments[i] instanceof List) {
						var l = arguments[i].h; arguments[i] = [];
						while(l != null) { arguments[i].push(l[0]); l = l[1]; }
					}
				} catch(e) {}
				return m.apply(this, arguments);
			}
			m.__mount   = m.mount;
			m.__component = m.component;
			m.__haxecomponents = [];
			m.mount = function(root, component) { if(component.controller) m.__haxecomponents.push(component); return m.__mount(root, component); }
			m.component = function(component) { if(component.controller) m.__haxecomponents.push(component); return m.__component(component); }
			if (typeof module !== 'undefined' && module.exports) m.request = function(xhrOptions) { return m.deferred().promise; };
		})")(__varName);
	}

	// Stores the current component so it can be used in component.controller 
	// calls. See above (injected automatically in macros.ModuleBuilder).
	@:noCompletion public static var __haxecomponents : Dynamic;
}
#else

/*
typedef Promise<T, T2> = {
	// Haxe limitation: Cannot expose the GetterSetter directly. then() is required to get value.
	function then<T3, T4>(?success : T -> T3, ?error : T2 -> T4) : Promise<T3, T4>;
}

typedef Deferred<T, T2> = {
	var promise : Promise<T, T2>;
	function resolve(value : T) : Void;
	function reject(value : T2) : Void;
}

typedef EventHandler<T : Event> = T -> Void;

typedef GetterSetter<T> = ?T -> T;
*/ 

class M 
{
	///// Stubs /////
	
	public static function redraw(?forceSync : Bool) {}
	public static function startComputation() {}
	public static function endComputation() {}	
	public static function deferred<T, T2>() : Deferred<T, T2> return {
		promise: { then: function(?success, ?error) return null },
		resolve: function(v) {},
		reject: function(v) {}
	}	
	public static function withAttr<T, T2 : Event>(property : String, ?callback : T -> Void) : EventHandler<T2> {
		return function(e) {}
	}
	
	///// Rendering /////
	
	public static function m(tag : String, ?attrs : Dynamic, ?children : Dynamic) : VirtualElement {
		// tag could be a Mithril object in original Mithril, but keeping it simple for now.
		
		var args = if(attrs == null) [] else if(children == null) [attrs] else [attrs, children];
		
		// Simplify?
		var hasAttrs = attrs != null && !Std.is(attrs, String) && !Std.is(attrs, Array) && Reflect.isObject(attrs) &&
			!(Reflect.hasField(attrs, "tag") || Reflect.hasField(attrs, "view") || Reflect.hasField(attrs, "subtree"));
		
		attrs = hasAttrs ? attrs : { };
		
		var cell = {
			tag: "div",
			attrs: { },
			children: getVirtualChildren(args, hasAttrs)
		}
		
		assignAttrs(cell.attrs, attrs, parseTagAttrs(cell, tag));
		
		return cell;
	}
	
	public static function trust(html : String) : VirtualElementObject {
		return {
			tag: html,
			attrs: null,
			children: null,
			"$trusted": true
		}
	}
	
	static function getVirtualChildren(args : Array<Dynamic>, hasAttrs : Bool) : Dynamic {
		var children = hasAttrs ? args.slice(1) : args;
		return children.length == 1 && Std.is(children[0], Array) ? children[0]	: children;
	}

	static function assignAttrs(target : Dynamic, attrs : Dynamic, classes : Array<String>) : Void {
		var classAttr = Reflect.hasField(attrs, "class") ? "class" : "className";

		for (attrName in Reflect.fields(attrs)) {
			if (Reflect.hasField(attrs, attrName)) {
				var currentAttribute : String = cast Reflect.field(attrs, attrName);
				if (attrName == classAttr && currentAttribute != null && currentAttribute.length > 0) {
					classes.push(currentAttribute);
					// create key in correct iteration order
					Reflect.setField(target, attrName, "");
				} else {
					Reflect.setField(target, attrName, currentAttribute);
				}
			}
		}

		if (classes.length > 0) Reflect.setField(target, classAttr, classes.join(" "));		
	}
	
	static function parseTagAttrs(cell : Dynamic, tag : String) : Array<String> {
		var classes = [];
		//trace("===== " + tag);
		var parser = ~/(?:(^|#|\.)([^#\.\[\]]+))|(\[.+?\])/g;

		while(parser.match(tag)) {		
			var match1 = parser.matched(1);
			var match2 = try parser.matched(2) catch (e : Dynamic) null;
			var match3 = try parser.matched(3) catch (e : Dynamic) null;
			
			//trace(match1); trace(match2); trace(match3);
			
			if (match1 == "" && match2 != null)
				cell.tag = match2;
			else if (match1 == "#")
				cell.attrs.id = match2;
			else if (match1 == ".")
				classes.push(match2);
			else if (match3.charAt(0) == "[") {
				var pair = ~/\[(.+?)(?:=("|'|)(.*?)\2)?\]/;
				pair.match(match3);
				var pair3 = try pair.matched(3) catch (e : Dynamic) "";
				Reflect.setField(cell.attrs, pair.matched(1), pair3);
			}
			
			tag = parser.matchedRight();
		}
		
		return classes;
	}
}
#end
