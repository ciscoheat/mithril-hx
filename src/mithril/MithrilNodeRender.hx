package mithril;

import mithril.M;

using StringTools;

/**
 * Haxe port of https://github.com/StephanHoyer/mithril-node-render
 */
class MithrilNodeRender
{
	static var voidTags = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 
						   'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 
						   'track', 'wbr'];

	var indent : String;
	var newLine : String;
	var indentMode : Bool;

	public function new(?indent : String, ?newLine : String) {
		this.indent = indent == null ? "" : indent;
		this.newLine = newLine == null ? (this.indent.length > 0 ? "\n" : "") : newLine;
	}

	public function render(view : Vnodes) : String {
		return _render(view, 0).trim();
	}
	
	function _render(view : Dynamic, indentDepth : Int) : String {
		if(view == null) return "";

		if(Std.is(view, String))
			return escape(cast view);

		if(Std.is(view, Int) || Std.is(view, Float) || Std.is(view, Bool))
			return Std.string(view);

		if(Std.is(view, Array)) {
			var output = [for(v in cast(view, Array<Dynamic>)) _render(v, indentDepth)].join(newLine);
			return if(output.indexOf("<") >= 0) newLine + output + newLine;
			else output;
		}

		// view must be a Vnode now.
		var el : Vnode<Dynamic> = cast view;
		
		// Test for trusted html
		if (el.tag == "<") {
			return cast el.state;
		}

		// Test for components
		if(Std.is(el.tag, Mithril)) {
			var c : Component1 = cast el.tag;
			return _render(c.view(), indentDepth);
		}

		var children = if(el.children == null || !Std.is(el.children, Array)) {
			el.text;
		}
		else {
			_render(el.children, indentDepth + 1);
		}

		if(children.length == 0 && voidTags.indexOf(el.tag.toLowerCase()) >= 0) {
			return '<${el.tag}${createAttrString(el.attrs)}>';
		}
		
		return '<${el.tag}${createAttrString(el.attrs)}>$children</${el.tag}>';
	}

	function createAttrString(attrs : Dynamic) {
		if (attrs == null) return '';
		
		return Reflect.fields(attrs).map(function(name) {
			// Needed a typehint to Dynamic for java to treat most values as not strings.
			var value : Dynamic = Reflect.field(attrs, name);
			if (value == null) return ' ' + (name == 'className' ? 'class' : name);
			
			//trace("------"); trace(name); trace(value); 
			//trace(Type.typeof(value));
			
			if(Reflect.isFunction(value)) return '';
			if(Std.is(value, Bool)) return cast(value, Bool) ? ' ' + name : '';

			if(name == 'style') {
				var styles : Dynamic = value;
				if (Std.is(styles, String)) return ' style="' + escape(styles) + '"';
				
				return ' style="' + Reflect.fields(styles).map(function(property) {
					// Same here for java as above
					var value : Dynamic = Reflect.field(styles, property);
					return camelToDash(property).toLowerCase() + ':' + escape(value);
				}).join(';') + '"';
			}
			return ' ' + (name == 'className' ? 'class' : name) + '="' + escape(value) + '"';
		}).join('');
	}

	inline function escape(s : String) return StringTools.htmlEscape(s, true);

	inline function camelToDash(str : String) {
		str = (~/\W+/g).replace(str, '-');
		return (~/([a-z\d])([A-Z])/g).replace(str, '$1-$2');		
	}
}
