package ludamix.ivy;
import ludamix.ivy.Ivy;

enum IvyLabelOp {
	Assign(api : Int, args : IvySignature, data : Array<Int>, assign : IvyAssign, debugname : String);
	Switch(api : Int, args : IvySignature, jump : Array<String>, assign : IvyAssign, debugname : String);
	If(api : Int, args : IvySignature, data : Array<Int>, inverse : Bool, jump : String, debugname : String);
	Push(api : Int, args : IvySignature, data : Array<Int>, inverse : Bool, jump : String, debugname : String);
	Jump(jump : String, debugname : String);
	JumpVar(jump : IvyAssign, debugname : String);
	Continue(debugname : String);
	Pop(debugname : String);
	Yield(debugname : String);
	Computed(op : IvyOp, original : IvyLabelOp);
}

enum IvyType {
	IDynamic;
	IType(d : IvyTypeDef);
}
typedef IvyTypeDef = {
	name : String,
	access : Array<String>
};
typedef IvyAssign = {
	type : IvyType, name : String
};
typedef IvySignature = {
	type : Array<IvyType>, name : Array<String>
};

typedef IvyLabel = { name : String, code : Array<IvyLabelOp> };
typedef IvyOrder = { begin : Int, label : IvyLabel };
typedef IvyDebug = { label : String, position : Int, code:IvyLabelOp };
typedef IvyDebugApi = { name:String, lut_parser:Array<Int>->String };

class IvyAssembler
{

	public static function renderIvySignature(sig : IvySignature) : String {
		return sig.name.join(",");
	}
	public static function renderIvyAssign(asn : IvyAssign) : String {
		if (asn == null) return '(Void)';
		else
			return asn.name;
	}
	
	public static function renderDebugApi(api, lut, ivy_debug_api) {
		var dbg = ivy_debug_api[api];
		if (lut != null && dbg.lut_parser != null)
			return {name:dbg.name, lut:'${dbg.lut_parser(lut)}'};
		else
			return {name:dbg.name, lut:Std.string(lut)};
	}

	public static function renderDebugOpcode(op : IvyLabelOp, ivy_debug_api : Array<IvyDebugApi>) : String {
		switch(op) {
			case Assign(api, args, data, assign, debugname):
				var dbg = renderDebugApi(api, data, ivy_debug_api);
				var arg_render = "";
				if (args.name.length > 0)
					arg_render = '${renderIvySignature(args)}->';
				var lut_render = "";
				if (dbg.lut != null)
					lut_render = '${dbg.lut}->';
				return '<$debugname> Assign: ${dbg.name} $arg_render$lut_render${renderIvyAssign(assign)}';
			case Switch(api, args, jump, assign, debugname):
				var dbg = renderDebugApi(api, null, ivy_debug_api);
				var arg_render = "";
				if (args.name.length > 0)
					arg_render = '${renderIvySignature(args)}->';
				return '<$debugname> Switch: ${dbg.name} $arg_render${jump}->${renderIvyAssign(assign)}';
			case If(api, args, data, inverse, jump, debugname):
				var dbg = renderDebugApi(api, data, ivy_debug_api);
				var arg_render = "";
				if (args.name.length > 0)
					arg_render = '${renderIvySignature(args)}->';
				var lut_render = ".";
				if (dbg.lut != null)
					lut_render = '${dbg.lut}.';
				return '<$debugname> If: ${dbg.name} $arg_render$lut_render $inverse to $jump';
			case Push(api, args, data, inverse, jump, debugname):
				var dbg = renderDebugApi(api, data, ivy_debug_api);
				var arg_render = "";
				if (args.name.length > 0)
					arg_render = '${renderIvySignature(args)}->';
				var lut_render = ".";
				if (dbg.lut != null)
					lut_render = '${dbg.lut}.';
				return '<$debugname> Push: ${dbg.name} $arg_render$lut_render $inverse to $jump';
			case Jump(jump, debugname):
				return '<$debugname> Jump: $jump';
			case JumpVar(jump, debugname):
				return '<$debugname> JumpVar: ${renderIvyAssign(jump)}';
			case Continue(debugname):
				return '<$debugname> Continue';
			case Pop(debugname):
				return '<$debugname> Pop';
			case Yield(debugname):
				return '<$debugname> Yield';
			case Computed(op, original):
				return renderDebugOpcode(original, ivy_debug_api);
		}
	}

	public static function renderDebugInfo(dbg : IvyDebug, ivy_debug_api : Array<IvyDebugApi>) : String {
		
		var base = StringTools.lpad(Std.string(dbg.position),"0",6)+
			': ';
		return base+renderDebugOpcode(dbg.code, ivy_debug_api)+' [${dbg.label}]';
	}

	public static function matchType(a : IvyType, b : IvyType) {
		switch(a) {
			case IDynamic: return true;
			case IType(defa):
				switch(b) {
					case IDynamic: return true;
					case IType(defb):
						for (n in defa.access) {
							for (m in defb.access) {
								if (n == m)
									return true;
							}
						}
						for (n in defb.access) {
							for (m in defa.access) {
								if (n == m)
									return true;
							}
						}
				}
		}
		return false;
	}
	
	public static function checkSignature(args : IvySignature, 
		variables : Map<String, IvyType>) {
		
		if (args.type.length != args.name.length)
			throw "mismatched signature length: "+args;
		for (idx in 0...args.type.length) {
			switch(args.type[idx]) {
				case IDynamic:
				case IType(def0):
					var name = def0.name;
					var varidx = args.name[idx];
					switch(variables.get(varidx)) {
						case IDynamic:
						case IType(def1):
							var ok = false;
							// logical OR the two types
							for (n in def1.access) {
								if (def0.name == n) {
									ok = true;
									break;
								}
							}
							if (!ok) {
								for (n in def0.access) {
									if (def1.name == n) {
										ok = true;
										break;
									}
								}
							}
							if (!ok) 
								throw 'argument $idx, type mismatch: ${def0.name} v. ${def1.name} (slot $varidx)';
						default:
							throw 'variable ${args.name[idx]}:${args.type[idx]} accessed but not declared';
					}
			}
		}
	}
	
	public static function typeCheck(codes : Array<IvyLabel>,
		variables : Map<String, IvyType>) {
		
		// given a set of codes,
		// a map of types and acceptable casts for those types,
		// and the type declaration of each variable slot,
		// verify that the type signatures match.
		
		for (label in codes) {
			for (c in label.code) {
				switch(c)
				{
					case If(api, args, lut, inverse, jump, debugname):
						checkSignature(args, variables);
					case Push(api, args, lut, inverse, jump, debugname):
						checkSignature(args, variables);
					case Jump(jump, debugname):
					case JumpVar(jump, debugname):
						checkSignature(
							{type : [jump.type], name : [jump.name]}, variables);
					case Assign(api, args, lut, assign, debugname):
						checkSignature(args, variables);
						if (assign != null)
							checkSignature({type:[assign.type],name:[assign.name]}, 
							variables);
					case Switch(api, args, jump, assign, debugname):
						checkSignature(args, variables);
						if (assign != null)
							checkSignature({type:[assign.type],name:[assign.name]}, 
							variables);
						for (jl in jump)
						{
							var ok = false;
							for (c in codes) {
								if (c.name == jl) {
									ok = true; break;
								}
							}
							if (!ok)
								throw 'unknown jump label $jl';
						}
					case Continue(debugname):
					case Pop(debugname):
					case Yield(debugname):
					default:
						throw "error, unexpected " + c;
				}
			}
		}
		
	}
	
	private static function varoffsets(args : IvySignature, varlut : Map<String, Int>) {
		var result = new Array<Int>();
		for (n in args.name) {
			if (!varlut.exists(n))
				throw 'unknown variable name $n';
			result.push(varlut.get(n));
		}
		return result;
	} 
	
	public static function compile(codes : Array<IvyLabel>, 
		variables : Array<String>,
		first : String) : {op:Array<IvyOp>,debug:Map<Int,IvyDebug>}
	{
		
		/*for (c in codes) {
			trace(c);
		}*/
		
		var debugi = new Map<Int, IvyDebug>(); // mapping of output lines to input lines
		var labels = new Map<String, IvyOrder>();
		var order = new Array<IvyOrder>();
		var varlut = new Map<String, Int>();
		{
			var i = 0;
			for (v in variables) {
				varlut.set(v, i);
				i += 1;
			}
		}
		
		for (c in codes)
		{
			if (labels.exists(c.name))
				throw "duplicate label declaration: " + c.name;
			else
			{
				var ol = { begin: -1, label:c };
				labels.set(c.name, ol );
				if (c.name == first) order.insert(0, ol);
				else order.push(ol);
			}
		}
		
		// 1. Compute and expand everything
		
		{
			for (l in labels)
			{
				var result = new Array<IvyLabelOp>();
				var z = l.label.code;
				for (lop in z)
				{
					switch(lop)
					{
						case Jump(jump, debugname):
							result.push(Jump(jump, debugname));
						case JumpVar(jump, debugname):
							result.push(JumpVar(jump, debugname));
						case If(api, args, data, inverse, jump, debugname):
							result.push(If(api, args, data, inverse, jump, debugname));
						case Push(api, args, data, inverse, jump, debugname):
							result.push(Push(api, args, data, inverse, jump, debugname));
						case Assign(api, args, lut, assignment, debugname):
							var r : Array<Array<Int>>;
							if (assignment == null)
								r = (([[Ivy.ASSIGN, api, 
								-1], varoffsets(args, varlut)]));
							else
								r = (([[Ivy.ASSIGN, api, 
								varlut.get(assignment.name)], varoffsets(args, varlut)]));
							if (lut != null)
								r.push(lut);
							result.push(Computed(r, lop));
						case Switch(api, args, jump, assignment, debugname):
							result.push(Switch(api,args,jump,assignment,debugname));
						case Continue(debugname):
							result.push(Computed([[Ivy.CONTINUE]], lop));
						case Pop(debugname):
							result.push(Computed([[Ivy.POP]], lop));
						case Yield(debugname):
							result.push(Computed([[Ivy.YIELD]], lop));
						default:
							throw "error, unexpected " + lop;
					}
				}
				l.label.code = result;
			}
		}
		
		// 2. Calculate offsets
		{
			var count = 0;
			for (l in order)
			{
				l.begin = count;
				if (l.label.code != null)
					count += l.label.code.length;
			}
		}
		
		// 3. Emit computed jumps
		{
			var result = new Array<IvyOp>();
			for (l in order)
			{
				var z = l.label.code;
				for (lop in z)
				{
					switch(lop)
					{
						case Jump(jump, debugname):
							debugi.set(result.length, {label:l.label.name, position:result.length, code:lop});
							if (!labels.exists(jump)) throw 'missing label $jump called from ${l.label.name}';
							result.push([[Ivy.JUMP, labels.get(jump).begin]]);
						case JumpVar(jump, debugname):
							debugi.set(result.length, {label:l.label.name, position:result.length, code:lop});
							result.push([[Ivy.JUMPVAR, varlut.get(jump.name)]]);
						case If(api, args, data, inverse, jump, debugname):
							debugi.set(result.length, {label:l.label.name, position:result.length, code:lop});
							if (!labels.exists(jump)) throw 'missing label $jump called from ${l.label.name}';
							var ra : Array<Array<Int>>;
							if (!inverse)
								ra = ([[Ivy.IF, api, labels.get(jump).begin],varoffsets(args, varlut)]);
							else
								ra = ([[Ivy.IF, -(api+1), labels.get(jump).begin],varoffsets(args, varlut)]);
							if (data != null)
								ra.push(data);
							result.push(ra);
						case Push(api, args, data, inverse, jump, debugname):
							debugi.set(result.length, {label:l.label.name, position:result.length, code:lop});
							if (!labels.exists(jump)) throw 'missing label $jump called from ${l.label.name}';
							var ra : Array<Array<Int>>;
							if (!inverse)
								ra = ([[Ivy.PUSH, api, labels.get(jump).begin],varoffsets(args, varlut)]);
							else
								ra = ([[Ivy.PUSH, -(api+1), labels.get(jump).begin],varoffsets(args, varlut)]);
							if (data != null)
								ra.push(data);
							result.push(ra);
						case Switch(api, args, jump, assignment, debugname):
							debugi.set(result.length, {label:l.label.name, position:result.length, code:lop});
							for (n in jump) {if (!labels.exists(n)) throw 'missing label $n called from ${l.label.name}';}
							if (assignment != null)
								result.push([[Ivy.ASSIGN, api, 
								varlut.get(assignment.name)],varoffsets(args, varlut),
									[for (n in jump) labels.get(n).begin]]);
							else
								result.push([[Ivy.ASSIGN, api, 
								-1],varoffsets(args, varlut),
									[for (n in jump) labels.get(n).begin]]);
						case Computed(data, original):
							debugi.set(result.length, {label:l.label.name, position:result.length, code:original});
							result.push(data);
						default:
							throw "error, unexpected " + lop;
					}
				}
			}
			
			return {op:result,debug:debugi};
		}
		
	}
	
}