package mithril;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.ExprTools;
using Lambda;

class ModelBuilder
{
	@macro public static function build() : Array<Field>
	{
		var fields = Context.getBuildFields();

		for (field in fields) switch(field.kind) {
			case FVar(t, e):
				if (Lambda.exists(field.meta, function(m) return m.name == "prop")) {
					field.access.push(Access.ADynamic);
					field.kind = propFunction(t, e);
				}
			case _:
				if (Lambda.exists(field.meta, function(m) return m.name == "prop")) {
					Context.warning("@prop only works with var", field.pos);
				}
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
}

#end