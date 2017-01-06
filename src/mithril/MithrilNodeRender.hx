package mithril;

import haxe.Constraints.Function;
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
		this.indentMode = this.indent.length > 0;
	}

	public function render(view : VirtualElement) : String {
		return _render(view, 0).trim();
	}
	
	function _render(view : VirtualElement, indentDepth : Int) : String {
		if(view == null) return "";

		if(Std.is(view, String))
			return escape(cast view);

		if(Std.is(view, Int) || Std.is(view, Float) || Std.is(view, Bool))
			return Std.string(view);

		if(Std.is(view, Array))
			return cast(view, Array<Dynamic>).map(_render.bind(_, indentDepth)).join('');

		// view must be a VNode now.
		var el : VNode<Dynamic> = cast view;

		if (Reflect.hasField(el, "$trusted")) {
			// If created on server, the value is in el.tag, otherwise it's a String.
			return Std.is(el, String) ? (cast el) : el.tag;
		}

		var children = createChildrenContent(el, indentDepth + 1);
		
		var currentIndent = indentMode ? "".lpad(this.indent, indentDepth * this.indent.length) : "";

		if(children.length == 0 && voidTags.indexOf(el.tag.toLowerCase()) >= 0) {
			return '$currentIndent<${el.tag}${createAttrString(el.attrs)}>$newLine$currentIndent';
		}
		
		var indentChild = indentMode && children.ltrim().startsWith("<");
		
		if (indentChild) children = newLine + children + currentIndent;
		var startIndent = indentChild ? currentIndent : "";

		return '$startIndent<${el.tag}${createAttrString(el.attrs)}>$children</${el.tag}>$newLine';
	}

	inline function createChildrenContent(el : VNode<Dynamic>, newIndentDepth : Int) : String {
		if(el.children == null || !Std.is(el.children, Array)) return '';
		return _render(el.children, newIndentDepth);
	}

	function createAttrString(attrs : Dynamic) {
		if(attrs == null) return '';

		return Reflect.fields(attrs).map(function(name) {
			var value = Reflect.field(attrs, name);
			if (value == null) return ' ' + (name == 'className' ? 'class' : name);
			
			if(Reflect.isFunction(value)) return '';
			if(Std.is(value, Bool)) return cast(value, Bool) ? ' ' + name : '';

			if(name == 'style') {
				var styles = value;
				if(Std.is(styles, String)) return ' style="' + escape(styles) + '"';

				return ' style="' + Reflect.fields(styles).map(function(property) {
					return camelToDash(property).toLowerCase() + ':' + 
						   escape(Reflect.field(styles, property));
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
