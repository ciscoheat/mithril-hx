package ;

import mithril.M;
import mithril.MithrilNodeRender;
using StringTools;

class HtmlRendering implements Mithril
{
	static function main() {
		var render = new MithrilNodeRender();

		trace(render.render([
			m('h1', "Hello world"),
			m('.test', {style: {color: 'red'}}, "Server-side Mithril")
		]));
	}
}