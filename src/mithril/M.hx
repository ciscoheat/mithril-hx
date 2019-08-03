package mithril;

import haxe.DynamicAccess;

#if js
import js.Browser;
import js.lib.Promise;
import js.html.XMLHttpRequest;
import js.html.Element;
#else
import haxe.Constraints;
// Mock some js classes for server rendering
typedef XMLHttpRequest = Dynamic;
typedef Event = Dynamic;
typedef Promise<T> = Dynamic;
typedef Element = Dynamic;
#end

/////////////////////////////////////////////////////////////

private abstract Either<T1, T2>(Dynamic)
from T1 from T2 to T1 to T2 {}

///// Interfaces /////

@:autoBuild(mithril.macros.ModuleBuilder.build()) interface Mithril {}

///// Typedefs /////

typedef Component1 = {
	function view() : Vnodes;
};

typedef Component2 = {
	function view(vnode : Vnode) : Vnodes;
};

typedef Component = Either<Component1, Component2>;

typedef RouteResolver<T : Component> = {
	@:optional function onmatch(args : DynamicAccess<String>, requestedPath : String) : Either<T, Promise<T>>;
	@:optional function render(vnode : Null<Vnode>) : Vnodes;
}

typedef Vnode = {
	var tag : Either<String, Component>;
	var key : Null<String>;
	var children : Null<Array<Vnode>>;
	var text : Null<Dynamic>;
	var attrs : Null<DynamicAccess<Dynamic>>;
	var state : Null<Dynamic>;
	#if js
	var dom : Null<Element>;
	#else
	var dom : Null<Dynamic>;
	#end
	var domSize : Null<Int>;
};

typedef Vnodes = Either<Vnode, Array<Vnode>>;

typedef XHROptions<T, T2> = {
	@:optional var method : String;
	@:optional var url : String;
	@:optional var params : DynamicAccess<String>;
	@:optional var body : T2;
	@:optional var async : Bool;
	@:optional var user : String;
	@:optional var password : String;
	@:optional var withCredentials : Bool;
	@:optional var timeout : Int;
	@:optional var responseType : String;
	@:optional var config : XMLHttpRequest -> XMLHttpRequest;
	@:optional var headers : DynamicAccess<String>;
	@:optional var type : T -> Dynamic;
	@:optional var serialize : T2 -> String;
	@:optional var deserialize : String -> T2;
	@:optional var extract : XMLHttpRequest -> XHROptions<T, T2> -> Dynamic;
	@:optional var background : Bool;
};

typedef JSONPOptions<T, T2> = {
	@:optional var url : String;
	@:optional var params : DynamicAccess<String>;
	@:optional var type : T -> Dynamic;
	@:optional var callbackName : String;
	@:optional var callbackKey : String;
	@:optional var background : Bool;
};

#if ((js && !nodejs) || (js && nodejs && mithril_native))
@:final extern class MithrilRoute
{
	@:selfCall 
	public function route(
		rootElement : Element, defaultRoute : String, 
		routes : Dynamic<Either<Component, RouteResolver<Dynamic>>>
	) : Void;

	public function set(path : String, ?params : { }, ?options : {
		?replace : Bool,
		?state : { },
		?title : String
	}) : Void;

	public function get() : String;

	public var prefix(default, default) : String;	
	public var Link(default, null) : Component;

	@:overload(function() : DynamicAccess<String> {})
	public function param(key : String) : String;

	public var SKIP(default, null) : Component;
}

@:final @:native("m")
extern class M
{
	@:overload(function(selector : Mithril) : Vnodes {})
	@:overload(function(selector : Either<String, Component>) : Vnodes {})
	@:overload(function(selector : Either<String, Component>, attributes : Dynamic) : Vnodes {})
	public static function m(selector : Either<String, Component>, attributes : Dynamic, children : Dynamic) : Vnodes;

	@:overload(function(rootElement : Element, children : Vnodes) : Void {})
	public static function render(rootElement : Element, children : Vnodes, redraw : Void -> Void) : Void;
	
	public static function mount(element : Element, component : Null<Component>) : Void;

	public static var route(default, null) : MithrilRoute;
	
	@:overload(function<T, T2>(url : String) : Promise<T> {})
	@:overload(function<T, T2>(options : XHROptions<T, T2>) : Promise<T> {})
	public static function request<T, T2>(url : String, options : XHROptions<T, T2>) : Promise<T>;

	@:overload(function<T>(url : String) : Promise<T> {})
	@:overload(function<T, T2>(options : JSONPOptions<T, T2>) : Promise<T> {})
	public static function jsonp<T, T2>(url : String, options : JSONPOptions<T, T2>) : Promise<T>;

	public static function parseQueryString(querystring : String) : DynamicAccess<String>;
	public static function buildQueryString(data : DynamicAccess<String>) : String;

	public static function buildPathname(path : String, data : DynamicAccess<String>) : String;
	public static function parsePathname(string : String) : {path: String, params: DynamicAccess<String>};

	public static function trust(html : String) : Vnode;
	
	@:overload(function() : Vnode {})
	@:overload(function(attrs : {}) : Vnode {})
	@:overload(function(children : Array<Dynamic>) : Vnode {})
	public static function fragment(attrs : {}, children : Array<Dynamic>) : Vnode;

	public static function redraw() : Void;
	public static inline function redrawSync() : Void { return untyped __js__("m.redraw.sync()"); }
	
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
		untyped __js__('global.m = require("mithril")');
		_patch(untyped __js__('global.m'));
		untyped __js__("} catch(_) {}");
	}

	@:noCompletion public static inline function _patch(__varName : Dynamic) : Void {
		// Add m.m which simplifies the API.
		// It also prevents deferred being resolved on Node.js to avoid server rendering issues,
		// and converts List to Array so Lambda.map can be used conveniently.
		//
		// if (typeof module !== 'undefined' && module.exports) m.request = function(args, extra) { return new Promise(function(res, rej) {}); };
		untyped __js__("(function(m) {
			if (m.m) return;
			m.m = function() {
				try { 
					for(var i=0; i < arguments.length; ++i) if(arguments[i] instanceof List) {
						var list = arguments[i].h; arguments[i] = [];
						while(list != null) { arguments[i].push(l[0]); list = l[1]; }
					}
				} catch(e) {}
				return m.apply(this, arguments);
			}
		})")(__varName);
	}
}

#else

///// Cross-platform implementation of Mithril. /////

@:final class MithrilRoute
{
	public function new() {}

	public function route(
		rootElement : Element, defaultRoute : String, 
		routes : Dynamic<Either<Component, RouteResolver<Dynamic>>>
	) : Void {}

	public function set(path : String, ?params : { }, ?options : {
		?replace : Bool,
		?state : { },
		?title : String
	}) : Void {}

	public function get() : String return "";

	public var prefix(default, default) : String = "";
	public var Link(default, null) : String = "";	
	public var SKIP(default, null) : String = "";

	public function param(?key : String) : String return "";
}

@:final
class M 
{
	///// Stubs /////
	
	public static function redraw(?forceSync : Bool) {}
	public static var route(default, null) = new MithrilRoute();
	
	///// Rendering /////
	
	// Latest version at https://github.com/MithrilJS/mithril.js/blob/next/render/hyperscript.js
	public static function m(selector : Either<String, Mithril>, ?attrs : Dynamic, ?children : Dynamic) : Vnode {
		if (selector == null || !Std.is(selector, String) && Reflect.hasField(selector, "view")) {
			throw "The selector must be either a string or a component.";
		}
		
		//trace("=== " + selector);
		
		if (Std.is(selector, String) && !selectorCache.exists(selector)) {
			var tag : String = null, classes : Array<String> = [];
			var attributes : DynamicAccess<Dynamic> = {}, tempSelector = selector;
			
			while (selectorParser.match(tempSelector)) {
				var matched = selectorParser.matched;
				var type = matched(1), value = matched(2);
				if (type == "" && value != "") tag = value;
				else if (type == "#") attributes.set('id', value);
				else if (type == ".") classes.push(value);
				else if (matched(3).charAt(0) == "[") {
					var attrValue = matched(6);
					if (attrValue != null) {
						attrValue = ~/\\(["'])/g.replace(attrValue, "$1");
						attrValue = ~/\\\\/g.replace(attrValue, "\\");
					}
						
					if (matched(4) == "class") 
						classes.push(attrValue);
					else 
						attributes.set(matched(4), attrValue == null ? true : attrValue);
				}
				tempSelector = selectorParser.matchedRight();
			}
			
			if (classes.length > 0) 
				attributes.set('className', classes.join(" "));
			
			selectorCache[selector] = function(attrs : DynamicAccess<Dynamic>, children) {
				var hasAttrs = false, childList : Array<Vnode> = null, text : String = null;
				
				var className = if (attrs.exists("className") && attrs.get("className") != null && cast(attrs.get("className"), String).length > 0)
					attrs.get("className")
				else if (attrs.exists("class") && attrs.get("class") != null && cast(attrs.get("class"), String).length > 0)
					attrs.get("class")
				else
					null;
				
				for (key in attributes.keys()) attrs.set(key, attributes.get(key));
				
				if (className != null) {
					if (attrs.get("class") != null) {
						#if python
						// Cannot delete "class" field on python
						var newAttrs: DynamicAccess<Dynamic> = {};
						for (key in attrs.keys()) if (key != 'class') 
							newAttrs.set(key, attrs.get(key));
						attrs = newAttrs;
						#else
						attrs.remove("class");
						#end
						attrs.set("className", className);
					}
					if (attributes.get("className") != null) {
						attrs.set("className", attributes.get("className") + " " + className);
					}
				}

				for (key in attrs.keys()) if (key != "key") {
					hasAttrs = true;
					break;
				}
				
				var childArray : Array<Vnode> = Std.is(children, Array) ? cast children : null;
				
				//trace("selectorCache[" + selector + "] childArray:"); trace(childArray);
				
				if (childArray != null && childArray.length == 1 && 
					childArray[0] != null && Reflect.hasField(childArray[0], "tag") && Reflect.field(childArray[0], "tag") == "#"
				) {
					//trace("setting text: "); trace(childArray);
					text = Std.string(Reflect.field(childArray[0], "children"));
				}
				else {
					//trace("assigning childList: "); trace(children);
					childList = children;
				}
					
				//trace("return vnode =====");
				
				return vnode(tag == null ? "div" : tag, attrs.get("key"), hasAttrs ? attrs : null, childList, text, null);
			}			
		}

		var arguments : Array<Dynamic> = if(attrs == null) [null] else if(children == null) [null, attrs] else [null, attrs, children];

		var attrs = { };
		var childrenIndex = if(
			(arguments.length >= 2 && arguments[1] == null) || 
			!Std.is(arguments[1], String) &&
			Reflect.isObject(arguments[1]) && 
			!Reflect.hasField(arguments[1], "tag") && 
			!Std.is(arguments[1], Array)
		) {
			attrs = arguments[1];
			2;
		}
		else 1;
		
		var newChildren = if (arguments.length == childrenIndex + 1) {
			Std.is(arguments[childrenIndex], Array) ? arguments[childrenIndex] : [arguments[childrenIndex]];
		}
		else {
			[for (i in childrenIndex...arguments.length) arguments[i]];
		}
		
		//trace(arguments); trace(attrs);
		
		return if (Std.is(selector, String)) {
			// php cannot call the selector directly
			var cacheFunc = selectorCache[selector];
			cacheFunc(attrs, vnodeNormalizeChildren(newChildren));
		}
		else {
			vnode(
				selector, 
				Reflect.hasField(attrs, "key") ? Reflect.field(attrs, "key") : null, 
				attrs, vnodeNormalizeChildren(newChildren), null, null
			);
		}
	}
	
	public static function trust(html : String) : Vnode {
		// Implementation differs from native Mithril, html is stored in state instead
		// because of static platform types.
		return {
			state: html,
			tag: "<",
			key: null,
			attrs: null,
			children: null,
			text: null,
			dom: null,
			domSize: 0
		}
	}
	
	static var selectorCache = new Map<String, DynamicAccess<Dynamic> -> Dynamic -> Vnode>();
	
	static function vnode(tag : Dynamic, key, attrs0, children : Dynamic, text, dom) : Dynamic {
		return { 
			tag: tag, key: key, attrs: attrs0, children: children, text: text, 
			dom: dom, domSize: 0,
			state: {}, events: null, instance: null, skip: false			
		}
	}

	static function vnodeNormalize(node : Dynamic) : DynamicAccess<Dynamic> {
		return if (Std.is(node, Array)) vnode("[", null, null, vnodeNormalizeChildren(node), null, null)
		else if (node != null && !Reflect.isObject(node)) vnode("#", null, null, node == false ? "" : node, null, null)
		else node;
	}
	
	static function vnodeNormalizeChildren(children : Array<DynamicAccess<Dynamic>>) {
		return [for (c in children) vnodeNormalize(c)];
	}	
		
	static var selectorParser : EReg = new EReg("(?:(^|#|\\.)([^#\\.\\[\\]]+))|(\\[(.+?)(?:\\s*=\\s*(\"|'|)((?:\\\\[\"'\\]]|.)*?)\\5)?\\])", "g");
}
#end
