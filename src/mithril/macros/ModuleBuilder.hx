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
		var c = Context.getLocalClass().get();
		if (c.meta.has(":ModuleProcessed")) return null;
		c.meta.add(":ModuleProcessed",[],c.pos);

		var fields = Context.getBuildFields();

		var propWarning = function(f : Field) {
			if (Lambda.exists(f.meta, function(m) return m.name == "prop")) {
				Context.warning("@prop only works with var", f.pos);
			}
		}

		for(field in fields) switch(field.kind) {
			case FFun(f):
				f.expr.iter(replaceM);
				if (field.name == "controller") injectModule(f);
				// TODO: Auto-add optional parameter to view() if it doesn't exist
				propWarning(field);
			case FVar(t, e):
				var prop = field.meta.find(function(m) return m.name == "prop");
				if (prop != null) {
					field.meta.remove(prop);
					field.access.push(Access.ADynamic);
					field.kind = propFunction(t, e);
				}
			case _:
				propWarning(field);
		}

		return fields;
	}

	/**
	 * Change: @prop public var description : String;
	 * To:     public dynamic function description(?v : String) : String return v;
	 */
	static private function propFunction(t : Null<ComplexType>, e : Expr) : FieldType {
		var f = {
			ret: t,
			params: null,
			expr: macro return v,
			args: [{
				value: null,
				type: t,
				opt: true,
				name: "v"
			}]
		}

		return FFun(f);
	}

	private static function replaceM(e : Expr) {
		// Autocompletion for m()
		if (Context.defined("display")) {
			switch(e.expr) {
				case ECall(e, params):
					for (p in params) {
						switch(p.expr) {
							case EDisplay(e2, isCall):
								switch(e2) {
									case macro m:
										e2.expr = (macro mithril.M.m).expr;
									case _:
								}
							case _:
						}
					}
				case _:
			}
		}

		switch(e) {
			case macro M($a, $b, $c), macro m($a, $b, $c):
				e.iter(replaceM);
				e.expr = (macro mithril.M.m($a, $b, $c)).expr;
			case macro M($a, $b), macro m($a, $b):
				e.iter(replaceM);
				e.expr = (macro mithril.M.m($a, $b)).expr;
			case macro M($a), macro m($a):
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
					if (mithril.M.__cm != this &&
						Type.typeof(mithril.M.__cm) != Type.ValueType.TObject)
							return mithril.M.__cm.controller()
				);
				exprs.push(macro return this);
			case _:
				f.expr = {expr: EBlock([f.expr]), pos: f.expr.pos};
				injectModule(f);
		}
	}
}
#end