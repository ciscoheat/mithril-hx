package ;

import buddy.*;
import mithril.M;
import mithril.M.m;
import mithril.MithrilNodeRender;

using StringTools;
using buddy.Should;

class HtmlRendering implements Buddy<[HtmlRendering]> extends BuddySuite
{
	public function new() {
		var render = new MithrilNodeRender().render;
		var view : VirtualElement;
		//var webshop = new webshop.Webshop();
		//var view = webshop.view();
		
		describe("MithrilNodeRender", {
			it("should render basic mithril m() calls to html", {
				view = m("h1", "Welcome!");
				render(view).should.be("<h1>Welcome!</h1>");
				
				view = [
					m('h1', "Hello world"),
					m('.test', {style: {color: 'red'}}, "Server-side Mithril")
				];
				render(view).should.be('<h1>Hello world</h1><div class="test" style="color:red">Server-side Mithril</div>');
			});
		});		
	}
	
	///////////////////////////////////////////////////////////////
	
	static function dump(v : VirtualElement, depth = 0) {
		if (Std.is(v, Array)) {
			var arr : Array<VirtualElement> = cast v;
			for (v2 in arr) dump(v2, depth);
		} else {
			var v2 : VirtualElementObject = cast v;
			var indent = StringTools.lpad("", "  ", depth);
			Sys.println(v2.tag);
			//Sys.println(indent + v.tag + " " + v.attrs);
			//Sys.println(v.children);
			dump(v2.children, depth + 1);
		}
	}	
}