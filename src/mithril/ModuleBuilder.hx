package mithril;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.ExprTools;
using Lambda;

class ModuleBuilder
{
	@macro public static function build() : Array<Field>
	{
		var fields = Context.getBuildFields();

		for(field in fields) switch(field.kind) {
			case FFun(f):
				f.expr.iter(replaceM);
				if (field.name == "controller") injectModule(f);
			case _:
		}

		return fields;
	}

	private static function replaceM(e : Expr) {
		switch(e) {
			case macro m($a, $b, $c):
				e.expr = (macro M.m($a, $b, $c)).expr;
				b.iter(replaceM);
				c.iter(replaceM);
			case macro m($a, $b):
				e.expr = (macro M.m($a, $b)).expr;
				b.iter(replaceM);
			case macro m($a):
				e.expr = (macro M.m($a)).expr;
			case _:
				e.iter(replaceM);
		}
	}

	private static function injectModule(f : Function) {
		if (f.expr == null) return;
		switch(f.expr.expr) {
			case EBlock(exprs):
				exprs.unshift(macro {
					if (mithril.M.modules.first() != this) {
						mithril.M.modules.first().controller();
						return M.modules.pop();
					}
				});
				exprs.push(macro return this);
			case _:
				f.expr = {expr: EBlock([f.expr]), pos: f.expr.pos};
				injectModule(f);
		}
	}
}
#end