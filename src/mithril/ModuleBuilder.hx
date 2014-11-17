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
		var outputFields : Array<Field> = [];

		for(field in fields) switch(field.kind) {
			case FFun(f):
				if (field.name == "controller" && field.access.exists(function(a) return a == Access.APublic))
					injectModule(f);
			case _:
		}

		return fields;
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