package com.ludamix.ivy;
import com.ludamix.ivy.Ivy;

enum IvyLabelOp {
	Exec(api : Int, args : Array<Int>);
	If(api : Int, args : Array<Int>);
	Jump(jump : String);
	IfJump(api : Int, args : Array<Int>, jump : String);
	Push(api : Int, jump : String, args : Array<Int>);
	ExecPush(api1 : Int, args1 : Array<Int>, api2 : Int, jump : String, args2 : Array<Int>);
	Continue;
	Pop;
	Yield;
	Computed(op : IvyOp);
}

typedef IvyLabel = { name : String, code : Array<IvyLabelOp> };
typedef IvyOrder = { begin : Int, label : IvyLabel };

// i need to add the variable and type definitions to this
// also... the compiled program does need to verify the types at runtime.
// at this stage, the only thing it can verify is whether types in runcodes
// match.

// I also need to add a test module for the new assembler.
// This can be done in FD or something.

// tomorrow's work: add the type system stuff, add the tests
// then the day after is building a compiler from behavior tree data.
// once we do that we can go back and piece things together again in Simulation.

class IvyAssembler
{
	
	public static function compile(codes : Array<IvyLabel>, first : String) : Array<IvyOp>
	{
		
		var labels = new Map<String, IvyOrder>();
		var order = new Array<IvyOrder>();
		
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
						case Exec(api, args):
							result.push(Computed([Ivy.EXEC, api].concat(args)));
						case If(api, args):
							result.push(Computed([Ivy.IF, api].concat(args)));
						case Jump(jump):
							result.push(Jump(jump));
						case IfJump(api, args, jump):
							result.push(Computed([Ivy.IF, api].concat(args)));
							result.push(Jump(jump));
						case Push(api, jump, args):
							result.push(Push(api, jump, args));
						case ExecPush(api1, args1, api2, jump, args2):
							result.push(Computed([Ivy.EXEC, api1].concat(args1)));
							result.push(Push(api2, jump, args2));
						case Continue:
							result.push(Computed([Ivy.CONTINUE]));
						case Pop:
							result.push(Computed([Ivy.POP]));
						case Yield:
							result.push(Computed([Ivy.YIELD]));
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
						case Jump(jump):
							result.push([Ivy.JUMP, labels.get(jump).begin]);
						case Push(api, jump, args):
							result.push([Ivy.PUSH, api, labels.get(jump).begin].concat(args));
						case Computed(data):
							result.push(data);
						default:
							throw "error, unexpected " + lop;
					}
				}
			}
			
			return result;
		}
		
	}
	
}