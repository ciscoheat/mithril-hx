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
			it("should render basic types to html", {
				view = m("h1", "Welcome!");
				render(view).should.be("<h1>Welcome!</h1>");

				view = m("div", null);
				render(view).should.be("<div></div>");

				view = m("h1", 123);
				render(view).should.be("<h1>123</h1>");

				view = m("h2", true);
				render(view).should.be("<h2>true</h2>");
				
				view = m("div", false);
				render(view).should.be("<div>false</div>");
			});
			
			it("should render css styles properly", {
				view = [
					m('h1', "Hello world"),
					m('.test', {style: {color: 'red', backgroundColor: 'blue'}}, "Server-side Mithril")
				];
				render(view).should.be('<h1>Hello world</h1><div class="test" style="color:red;background-color:blue">Server-side Mithril</div>');
			});
			
			it("should render tags with attributes properly", {
				view = m(".foo");
				render(view).should.be('<div class="foo"></div>');
				
				view = m("[title=bar]");
				render(view).should.be('<div title="bar"></div>');

				view = m("[empty]", "ok");
				render(view).should.be('<div empty>ok</div>');

				view = m("[title='foo foo']", "ok");
				render(view).should.be('<div title="foo foo">ok</div>');

				view = m("p[title=\"bar bar\"]");
				render(view).should.be('<p title="bar bar"></p>');
			});
			
			it("should render self-closing tags properly", {
				view = m("hr");
				render(view).should.be('<hr>');
				
				view = m("meta[name=keywords][content='A test']");
				render(view).should.be('<meta name="keywords" content="A test">');
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