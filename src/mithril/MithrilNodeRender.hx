package mithril;

import mithril.M.ViewOutput;
import mithril.M.VirtualElement;

/**
 * Haxe port of https://github.com/StephanHoyer/mithril-node-render
 */
class MithrilNodeRender
{
	static var voidTags : EReg = ~/^(AREA|BASE|BR|COL|COMMAND|EMBED|HR|IMG|INPUT|KEYGEN|LINK|META|PARAM|SOURCE|TRACK|WBR)$/;
	static var voidTagsArray = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 
								'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr'];

	public function new() {}

	public function render(view : ViewOutput) : String {
		if(view == null) 
			return "";

		if(Std.is(view, String))
			return StringTools.htmlEscape(view, true);

		if(Std.is(view, Int) || Std.is(view, Float) || Std.is(view, Bool))
			return Std.string(view);

		if(Std.is(view, Array)) 
			return cast(view, Array<Dynamic>).map(render).join('');

		if(Reflect.hasField(view, "$trusted")) 
			return Std.string(view);

		// view must be a VirtualElement now.
		var el : VirtualElement = cast view;

		var children = createChildrenContent(el);
		if(children.length == 0 && voidTagsArray.indexOf(el.tag) >= 0) {
			return '<' + el.tag + createAttrString(el.attrs) + '>';
		}

		return [
			'<', el.tag, createAttrString(el.attrs), '>',
			children,
			'</', el.tag, '>'
		].join('');
	}

	inline function createChildrenContent(el : VirtualElement) : String {
		if(el.children == null || !Std.is(el.children, Array)) return '';
		return render(cast el.children);
	}

	function createAttrString(attrs : Dynamic) {
		if(attrs == null || Reflect.fields(attrs).length == 0) return '';

		return Reflect.fields(attrs).map(function(name) {
			var value = Reflect.field(attrs, name);
			if(Reflect.isFunction(value)) return '';

			if(name == 'style') {
				return ' style="' + Reflect.fields(value).map(function(property) {
					return [camelToDash(property).toLowerCase(), Reflect.field(value, property)].join(':');
				}).join(';') + '"';
			}
			return ' ' + (name == 'className' ? 'class' : name) + '="' + value + '"';
		}).join('');
	}

	inline function camelToDash(str : String) {
		str = (~/\W+/g).replace(str, '-');
		return (~/([a-z\d])([A-Z])/g).replace(str, '$1-$2');		
	}
}
