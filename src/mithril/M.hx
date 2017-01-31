package mithril;

using Lambda;
using StringTools;

import haxe.Constraints.Function;
import haxe.DynamicAccess;

#if js

import js.Browser;
import js.Promise;
import js.Error;
import js.html.Document;
import js.html.Event;
import js.html.XMLHttpRequest;

#if (haxe_ver >= 3.2)
import js.html.DOMElement in Element;
#else
import js.html.Element;
#end

#else

// Mock js classes for server rendering
typedef XMLHttpRequest = Dynamic;
typedef Event = Dynamic;

#end

/////////////////////////////////////////////////////////////

private abstract Either<T1, T2>(Dynamic)
from T1 from T2 to T1 to T2 {}

///// Interfaces /////

@:autoBuild(mithril.macros.ModuleBuilder.build()) interface Mithril {}

///// Typedefs /////

typedef Component = {
	var view : Function;
};

typedef Vnode<T> = {
	var state : Null<T>;
	var tag : Dynamic;
	var key : Null<String>;
	var attrs : Null<DynamicAccess<Dynamic>>;
	var children : Null<Array<Vnode<Dynamic>>>;	
	var text : Null<Dynamic>;
	#if js
	var dom : Null<Element>;
	var domSize : Int;
	#else
	var dom : Null<Dynamic>;
	var domSize : Int;
	#end
};

typedef Vnodes = Either<Vnode<Dynamic>, Array<Vnode<Dynamic>>>;

/**
 * Plenty of optional fields for this one.
 * @see http://mithril.js.org/request.html
 */
typedef XHROptions<T, T2, T3> = {
	@:optional var url : String;
	@:optional var method : String;
	@:optional var data : Dynamic;
	@:optional var async : Bool;
	@:optional var user : String;
	@:optional var password : String;
	@:optional var withCredentials : Bool;
	@:optional var config : XMLHttpRequest -> XMLHttpRequest;
	@:optional var headers : DynamicAccess<String>;
	@:optional var type : T -> Dynamic;
	@:optional var serialize : T3 -> String;
	@:optional var deserialize : String -> T3;
	@:optional var extract : XMLHttpRequest -> XHROptions<T, T2, T3> -> String;
	@:optional var useBody : Bool;
	@:optional var background : Bool;
};

typedef JSONPOptions<T, T2> = {
	@:optional var url : String;
	@:optional var data : Dynamic;
	@:optional var type : T -> Dynamic;
	@:optional var callbackName : String;
	@:optional var callbackKey : String;
};

//////////

#if ((js && !nodejs) || (js && nodejs && mithril_native))
@:final @:native("m")
extern class M
{
	@:overload(function<T>(selector : Either<String, Component>) : Vnode<T> {})
	@:overload(function<T>(selector : Either<String, Component>, attributes : Dynamic) : Vnode<T> {})
	public static function m<T>(selector : Either<String, Component>, attributes : Dynamic, children : Dynamic) : Vnode<T>;

	public static function render(rootElement : Element, children : Vnodes) : Void;
	
	public static function mount(element : Element, component : Null<Component>) : Void;

	public static function route(rootElement : Element, defaultRoute : String, routes : { } ) : Void;
	
	///// Special route accessors /////
	
	public static inline function routeSet(route : String, ?data : { }, ?options : {
		?replace : Bool,
		?state : { },
		?title : String
	}) : Void { 
		return untyped __js__("m.route.set({0}, {1}, {2})", route, data, options); 		
	}
	public static inline function routeGet() : String  { return untyped __js__("m.route.get()"); }
	public static inline function routePrefix(prefix : String) : Void  { return untyped __js__("m.route.prefix({0})", prefix); }

	// Convenience method for route attributes
	public static inline function routeAttrs(vnode : Vnode<Dynamic>) : DynamicAccess<String> { return untyped __js__("{0}.attrs", vnode); }

	public static var routeLink(get, null) : Function;
	static inline function get_routeLink() : Function { return untyped __js__("m.route.link"); }
	
	///////////////////////////////////
	
	@:overload(function<T, T2, T3>(url : String) : Promise<T> {})
	@:overload(function<T, T2, T3>(options : XHROptions<T, T2, T3>) : Promise<T> {})
	public static function request<T, T2, T3>(url : String, options : XHROptions<T, T2, T3>) : Promise<T>;

	@:overload(function<T>(url : String) : Promise<T> {})
	@:overload(function<T, T2>(options : JSONPOptions<T, T2>) : Promise<T> {})
	public static function jsonp<T, T2>(url : String, options : JSONPOptions<T, T2>) : Promise<T>;

	public static function parseQueryString(querystring : String) : DynamicAccess<String>;
	public static function buildQueryString(data : {}) : String;
	
	public static function withAttr<T, T2 : Event>(attrName : String, callback : T -> Void) : T2 -> Void;
	
	public static function trust(html : String) : Vnode<Dynamic>;
	
	public static function fragment(attrs : {}, children : Array<Vnodes>) : Vnode<Dynamic>;

	public static function redraw() : Void;
	
	public static function version() : String;
	
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

@:final
class M 
{
	///// Stubs /////
	
	public static function redraw(?forceSync : Bool) {}

	public static function withAttr<T, T2 : Event>(property : String, ?callback : T -> Void) : T2 -> Void {
		return function(e) {}
	}
	
	public static var routeLink(default, null) : Function = null;
	
	///// Rendering /////
	
	public static function m(selector : String, ?attrs : Dynamic, ?children : Dynamic) : Vnode<Dynamic> {
		if (selector == null || !Std.is(selector, String) && Reflect.hasField(selector, "view")) {
			throw "The selector must be either a string or a component.";
		}
		
		if (Std.is(selector, String) && !selectorCache.exists(selector)) {
			var tag : String, classes : Array<String> = [];
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
				var hasAttrs = false, childList : Array<Vnode<Dynamic>> = null, text : String = null;
				
				var className = if (attrs.exists("className") && attrs.get("className") != null && cast(attrs.get("className"), String).length > 0)
					attrs.get("className")
				else if (attrs.exists("class") && attrs.get("class") != null && cast(attrs.get("class"), String).length > 0)
					attrs.get("class")
				else
					null;
				
				for (key in attributes.keys()) attrs.set(key, attributes.get(key));
				
				if (className != null) {
					if (attrs.get("class") != null) {
						attrs.remove("class");
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
				
				var childArray : Array<Vnode<Dynamic>> = Std.is(children, Array) ? cast children : null;
								
				if (childArray != null && childArray.length == 1 && childArray[0] != null && childArray[0].tag == "#") {
					text = Std.string(childArray[0].children);
				}
				else 
					childList = children;
				
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
		
		//trace(arguments); trace(attrs); trace(newChildren);
		
		return if (Std.is(selector, String))
			selectorCache[selector](attrs, vnodeNormalizeChildren(newChildren))
		else {
			vnode(
				selector, 
				Reflect.hasField(attrs, "key") ? Reflect.field(attrs, "key") : null, 
				attrs, vnodeNormalizeChildren(newChildren), null, null
			);
		}
	}
	
	public static function trust(html : String) : Vnode<Dynamic> {
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
	
	static var selectorCache = new Map<String, DynamicAccess<Dynamic> -> Dynamic -> Vnode<Dynamic>>();
	
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
