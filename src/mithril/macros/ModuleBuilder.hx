package mithril.macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.ExprTools;
using Lambda;
using StringTools;

class ModuleBuilder
{
	static var viewField : Function;

	static var componentMethods = ['view', 'oninit', 'oncreate', 'onbeforeupdate', 'onupdate', 'onbeforeremove', 'onremove'];

	@macro public static function build() : Array<Field> {
		var c : ClassType = Context.getLocalClass().get();
		if (c.meta.has(":MithrilModuleProcessed")) return null;
		c.meta.add(":MithrilModuleProcessed",[],c.pos);

		var fields = Context.getBuildFields();

		for(field in fields) switch(field.kind) {
			case FFun(f) if(f.expr != null):

				// Set viewField if current field is the view function.
				// Then it will automatically return its content.
				viewField = if(field.name == "view") f else null;

				replaceMwithFullNamespace(f.expr);
				returnLastMExpr(f);
				
				if (!componentMethods.has(field.name)) continue;

				// Keep the field
				field.meta.push({
					pos: Context.currentPos(),
					params: null,
					name: ':keep'
				});

				// Add a vnode argument to parameterless component methods
				// since it's used to 
				if(f.args.length == 0) f.args.push({
					value: null,
					type: TPath({
						name: 'M',
						pack: ['mithril'],
						params: [TPType(Context.toComplexType(Context.getLocalType()))],
						sub: 'VNode'
					}),
					opt: true,
					name: "vnode"
				});

				injectCurrentModule(field.name, f);

				#if (haxe_ver < 3.3)
				if(f.ret == null) {
					// Return Dynamic so multi-type arrays can be used in view without casting
					f.ret = macro : Dynamic;
				}
				#end
				
			case _:
		}

		return fields;
	}

	/**
	 * The reference to 'this' is conceptually incorrect with Haxe classes when entering a component method.
	 * Therefore it is changed if vnode.tag (first argument is vnode) is a Haxe object.
	 * __class__ is used to detect whether that is true.
	*/
	private static function injectCurrentModule(name : String, f : Function) {
		switch(f.expr.expr) {
			case EBlock(exprs):
				exprs.unshift(macro
					// Needs to be untyped to avoid clashing with macros that modify return (particularly HaxeContracts)
					untyped __js__('if(arguments.length > 0 && arguments[0].tag.__class__ && arguments[0].tag != this) 
						return arguments[0].tag.$name.apply(arguments[0].tag, arguments)')
				);
			case _:
				f.expr = {expr: EBlock([f.expr]), pos: f.expr.pos};
				injectCurrentModule(name, f);
		}
	}	

	private static function replaceMwithFullNamespace(e : Expr) {
		// Autocompletion for m()
		if (Context.defined("display")) switch e.expr {
			case EDisplay(e2, isCall):
				switch(e2) {
					case macro m:
						e2.expr = (macro mithril.M.m).expr;
						return;
					case _:
				}
			case _:
		}

		switch(e) {
			case macro M($a, $b, $c), macro m($a, $b, $c):
				e.iter(replaceMwithFullNamespace);
				e.expr = (macro mithril.M.m($a, $b, $c)).expr;
			case macro M($a, $b), macro m($a, $b):
				e.iter(replaceMwithFullNamespace);
				e.expr = (macro mithril.M.m($a, $b)).expr;
			case macro M($a), macro m($a):
				e.expr = (macro mithril.M.m($a)).expr;
			case _:
				e.iter(replaceMwithFullNamespace);
		}

		switch(e.expr) {
			case EFunction(_, f): returnLastMExpr(f);
			case _:
		}
	}

	/**
	 * Return the last m() call automatically, or an array with m() calls.
	 * Returns null if no expr exists.
	 */
	private static function returnLastMExpr(f : Function) {
		switch(f.expr.expr) {
			case EBlock(exprs):
				if (exprs.length > 0)
					returnMOrArrayMExpr(exprs[exprs.length - 1], f);
			case _:
				returnMOrArrayMExpr(f.expr, f);
		}
	}

	/**
	 * Add return to m() calls, or an Array with m() calls.
	 */
	private static function returnMOrArrayMExpr(e : Expr, f : Function) {
		switch(e.expr) {
			case EReturn(_):
			case EArrayDecl(values):
				if(values.length > 0 && f != viewField) 
					checkForM(values[0], e);
				else if(f == viewField)
					injectReturn(e);
			case _:
				if(f != viewField) checkForM(e, e);
				else injectReturn(e);
		}
	}

	/**
	 * Check if e is a m() call, then add return to inject
	 */
	private static function checkForM(e : Expr, inject : Expr) {
		switch(e) {
			case macro mithril.M.m($a, $b, $c):
			case macro mithril.M.m($a, $b):
			case macro mithril.M.m($a):
			case _: return;
		}

		injectReturn(inject);
	}

	private static function injectReturn(e : Expr) {
		e.expr = EReturn({expr: e.expr, pos: e.pos});
	}
}
#end
