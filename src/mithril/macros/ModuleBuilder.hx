package mithril.macros;

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
			case macro M($a, $b, $c):
				e.expr = (macro mithril.M.m($a, $b, $c)).expr;
				b.iter(replaceM);
				c.iter(replaceM);
			case macro M($a, $b):
				e.expr = (macro mithril.M.m($a, $b)).expr;
				b.iter(replaceM);
			case macro M($a):
				e.expr = (macro mithril.M.m($a)).expr;
			case _:
				e.iter(replaceM);
		}
	}

	private static function injectModule(f : Function) {
		if (f.expr == null) return;
		switch(f.expr.expr) {
			case EBlock(exprs):
				// If an anonymous object is used, don't call it.
				exprs.unshift(macro
					if (mithril.M.controllerModule != this &&
						Type.typeof(mithril.M.controllerModule) != Type.ValueType.TObject)
							return mithril.M.controllerModule.controller()
				);
				exprs.push(macro return this);
			case _:
				f.expr = {expr: EBlock([f.expr]), pos: f.expr.pos};
				injectModule(f);
		}
	}
}
#end