package mithril;

using Lambda;

import haxe.Constraints.Function;

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

private abstract Either3<T1, T2, T3>(Dynamic)
from T1 from T2 from T3 to T1 to T2 to T3 {}

private abstract Either4<T1, T2, T3, T4>(Dynamic)
from T1 from T2 from T3 from T4 to T1 to T2 to T3 to T4 {}

///// Interfaces /////

@:autoBuild(mithril.macros.ModuleBuilder.build()) interface Mithril {}

///// Typedefs /////

typedef Component = {};

typedef VNode<T> = {
	var state : T;
	var attrs : Dynamic<String>;
	#if js
	var dom : Null<Element>;
	#else
	var dom : Null<Dynamic>;
	#end
}

private typedef BasicType = Either4<Bool, Float, Int, String>;

typedef VirtualElementObject = {
	var tag : Dynamic;
	var key : Null<String>;	
	var attrs : Null<Dynamic>;
	var children : Null<Array<VirtualElementObject>>;
	var text : Null<String>;
};

typedef VirtualElement = Either<VirtualElementObject, Array<VirtualElementObject>>;

typedef ViewOutput = Either3<VirtualElement, BasicType, Array<BasicType>>;

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

#if (js && !no_extern_mithril)
@:final @:native("m")
extern class M
{
	@:overload(function(selector : Either<String, Component>) : VirtualElement {})
	@:overload(function(selector : Either<String, Component>, attributes : Dynamic) : VirtualElement {})
	public static function m(selector : Either<String, Component>, attributes : Dynamic, children : Dynamic) : VirtualElement;

	public static function mount(element : Element, component : Component) : Void;

	public static function withAttr<T, T2 : Event>(property : String, ?callback : T -> Void) : T2 -> Void;

	public static function route(rootElement : Element, defaultRoute : String, routes : {}) : Void;
	public static inline function routePrefix(prefix : String) : Void  { return untyped __js__("m.route.prefix({0})", prefix); }
	public static inline function routeGet() : String  { return untyped __js__("m.route.get()", prefix); }
	public static inline function routeSet(route : String, ?data : {}, ?options : {}) : Void  { return untyped __js__("m.route.set({0}, {1}, {2})", route, data, options); }

	public static var routeLink(get, null) : Function;
	static inline function get_routeLink() : Function { return untyped __js__("m.route.link"); }

	@:overload(function<T, T2>(options : JSONPOptions<T, T2>) : Promise<T> {})
	public static function request<T, T2, T3, T4>(options : XHROptions<T, T2, T3, T4>) : Promise<T>;

	public static function trust(html : String) : String;

	public static function fragment(attrs : {}, children : Array<VirtualElement>) : VirtualElement;

	@:overload(function(rootElement : Element, children : Dynamic) : Void {})
	public static function render(rootElement : Element, children : Dynamic, forceRecreation : Bool) : Void;

	public static function redraw() : Void;

	public static function deps(window : Dynamic) : Dynamic;

	///// Properties that uses function properties /////

	public static inline function buildQueryString(data : Dynamic) : String { return untyped __js__("m.route.buildQueryString({0})", data); }
	public static inline function parseQueryString(querystring : String) : Dynamic { return untyped __js__("m.route.parseQueryString({0})", querystring); }

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
			if (typeof module !== 'undefined' && module.exports) m.request = function(xhrOptions) { return m.deferred().promise; };
		})")(__varName);
	}
}
#else

class M 
{
	///// Stubs /////
	
	public static function redraw(?forceSync : Bool) {}

	public static function withAttr<T, T2 : Event>(property : String, ?callback : T -> Void) : T2 -> Void {
		return function(e) {}
	}
	
	///// Rendering /////
	
	public static function m(tag : String, ?attrs : Dynamic, ?children : Dynamic) : VirtualElement {

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
