package mithril;

import mithril.M.ViewOutput;
import mithril.M.VirtualElement;

/**
 * Haxe port of https://github.com/StephanHoyer/mithril-node-render
 */
class MithrilNodeRender
{
	static var voidTags = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 
						   'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 
						   'track', 'wbr'];

	public function new() {}

	public function render(view : ViewOutput) : String {
		if(view == null) 
			return "";

		if(Std.is(view, String))
			return escape(view);

		if(Std.is(view, Int) || Std.is(view, Float) || Std.is(view, Bool))
			return Std.string(view);

		if(Std.is(view, Array)) 
			return cast(view, Array<Dynamic>).map(render).join('');

		if(Reflect.hasField(view, "$trusted")) 
			return Std.string(view);

		// view must be a VirtualElement now.
		var el : VirtualElement = cast view;

		var children = createChildrenContent(el);
		if(children.length == 0 && voidTags.indexOf(el.tag.toLowerCase()) >= 0) {
			return '<${el.tag}${createAttrString(el.attrs)}>';
		}

		return '<${el.tag}${createAttrString(el.attrs)}>$children</${el.tag}>';
	}

	inline function createChildrenContent(el : VirtualElement) : String {
		if(el.children == null || !Std.is(el.children, Array)) return '';
		return render(cast el.children);
	}

	function createAttrString(attrs : Dynamic) {
		if(attrs == null) return '';

		return Reflect.fields(attrs).map(function(name) {
			var value = Reflect.field(attrs, name);
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

	inline function escape(s : String) {
		return StringTools.htmlEscape(s, true);
	}

	inline function camelToDash(str : String) {
		str = (~/\W+/g).replace(str, '-');
		return (~/([a-z\d])([A-Z])/g).replace(str, '$1-$2');		
	}
}
