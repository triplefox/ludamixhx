package ludamix.ivy;
import ludamix.ivy.Ivy;
import ludamix.ivy.IvyAssembler;
import haxe.ds.Vector;

class IvyTest {
	
	public static function run() {
		
		var fn_exec_return_a = function(ivy : Ivy, args : Array<Int>, lut : Array<Int>) {
			return ivy.variables[args[0]];
		}
		var fn_exec_a_from_b_plus_c = function(ivy : Ivy, args : Array<Int>, lut : Array<Int>) {
			ivy.variables[args[0]] = 
				ivy.variables[args[1]] +
				ivy.variables[args[2]];
			return -1;
		}
		
		var fn_if_a_equals_b = function(ivy : Ivy, args : Array<Int>, lut : Array<Int>) {
			return ivy.variables[args[0]] == ivy.variables[args[1]] ? 1 : 0;
		}
		var fn_if_a_less_b = function(ivy : Ivy, args : Array<Int>, lut : Array<Int>) {
			return ivy.variables[args[0]] < ivy.variables[args[1]] ? 1 : 0;
		}
		var fn_switch = function(ivy : Ivy, args : Array<Int>, lut : Array<Int>) {
			return lut[ivy.variables[args[0]]];
		}
		
		var FN_RETURN_A = 0;
		var FN_A_FROM_B_PLUS_C = 1;		
		var FN_A_EQUALS_B = 2;
		var FN_A_LESS_B = 3;
		var FN_SWITCH = 4;
		
		var api = [fn_exec_return_a, fn_exec_a_from_b_plus_c,
			fn_if_a_equals_b,fn_if_a_less_b,fn_switch];
		
		// test 1: add two numbers, set another number
		
		var code1 = [
			[[Ivy.ASSIGN, FN_A_FROM_B_PLUS_C, -1], [2, 0, 1]],
			[[Ivy.ASSIGN, FN_RETURN_A, 3], [2]]];
		var variables1 = new Vector<Int>(8);
		variables1[0] = 100;
		variables1[1] = 200;
		variables1[2] = 0;
		variables1[3] = 0;
		
		var ivy = new Ivy(
			code1,
			variables1,
			api
		);
		
		ivy.run();
		if (variables1[2] == 300 && variables1[3] == 300)
		{
			trace(true);
		} else {
			trace(false);
			trace(variables1);	
		}
		
		// test 2:
		// set var, 
		// push to the stack an increment loop
		// pop, then set second var
		
		var code2 = [
			[[Ivy.PUSH, FN_A_LESS_B, 3], [0, 1]],
			[[Ivy.ASSIGN, FN_RETURN_A, 3], [0]],
			[[Ivy.YIELD]],
			[[Ivy.ASSIGN, FN_A_FROM_B_PLUS_C, -1], [0, 0, 2]],
			[[Ivy.JUMP, 3]]
		];
		var variables2 = new Vector<Int>(8);
		variables2[0] = 0;
		variables2[1] = 10;
		variables2[2] = 1;
		variables2[3] = 0;
		
		var ivy = new Ivy(
			code2,
			variables2,
			api
		);
		
		ivy.run();
		if (variables2[0] == 10 && variables2[3] == 10)
		{
			trace(true);
		} else {
			trace(false);
			trace(variables2);	
		}
		
		// test 3:
		// if two variables are equal, jump to end
		// otherwise add and jump to beginning
		
		var code3 = [
			[[Ivy.IF, FN_A_EQUALS_B, 3], [0, 1]],
			[[Ivy.ASSIGN, FN_A_FROM_B_PLUS_C, -1], [0, 0, 2]],
			[[Ivy.JUMP, 0]]
		];
		var variables3 = new Vector<Int>(8);
		variables3[0] = 0;
		variables3[1] = 10;
		variables3[2] = 1;
		
		var ivy = new Ivy(
			code3,
			variables3,
			api
		);
		
		ivy.run();
		if (variables3[0] == 10)
		{
			trace(true);
		} else {
			trace(false);
			trace(variables3);	
		}
		
		// assembler tests
		// first, reproduce 1 - 3 in typed assembly form
		
		var t_int = IType({name :"int",access:["int"]});
		var t_float = IType({name :"float",access:["float"]});
		var t_number = IType({name :"number",access:["int","float","number"]});
		var t_string = IType({name :"string",access:["string"]});
		var t_jv = IType({name :"jumpval",access:["jumpval","int"]});
		
		var check = function(a : Array<Array<Array<Int>>>, b : Array<Array<Array<Int>>>) {
			var disp = false;
			if (a.length != b.length)
			{
				trace("mismatched program length");
				disp = true;
			}			
			if (!disp) {
				for (i0 in 0...a.length) {
					if (a[i0].length != b[i0].length) {
						trace('mismatched program length $i0');
						disp = true;
					}
				}
			}
			if (!disp) {
				for (i0 in 0...a.length) {
					for (i1 in 0...a[i0].length) {
						if (a[i0][i1].length != b[i0][i1].length) {
							trace('mismatched program length $i0 $i1');
							disp = true;
						}
					}
				}
			}
			if (!disp) {
				for (i0 in 0...a.length) {
					for (i1 in 0...a[i0].length) {
						for (i2 in 0...a[i0][i1].length)
						if (a[i0][i1][i2] != b[i0][i1][i2]) {
							trace('mismatch, $i0 - $i1 - $i2');
							disp = true;
						}
					}
				}
				if (!disp) {
					for (i0 in 0...b.length) {
						for (i1 in 0...b[i0].length) {						
							for (i2 in 0...b[i0][i1].length)
							if (a[i0][i1][i2] != b[i0][i1][i2]) {
								trace('mismatch, $i0 - $i1 - $i2');
								disp = true;
							}
						}
					}
				}
			}
			if (disp) { 
				trace(a);
				trace(b);
			}
			return !disp;
		}		
		
		// 1.
		trace("1");
		
		var types1 = [
			"100"=>t_int,
			"200"=>t_int,
			"result"=>t_int,
			"result2"=>t_int
		];
		var src1 = [
				{name:"start",code:[
					Assign(FN_A_FROM_B_PLUS_C, 
						{type:[t_int,t_int,t_int], 
							 name:["result", "100", "200"]},
						null, null, "assign_0"),
					Assign(FN_RETURN_A, {type:[t_int], 
							 name:["result"]},
							 null,{type:t_int,name:"result2"},
							 	"assign_1")
				]}
			];
		IvyAssembler.typeCheck(
			src1,
			types1
		);		 
		var cprogram1 = IvyAssembler.compile(
			src1,
			[for (n in types1.keys()) n],
			"start"
		);
		
		trace(check(code1, cprogram1.op));
		
		// 2.
		trace("2");

		var types2 = [
			"a"=>t_int,
			"b"=>t_int,
			"c"=>t_int,
			"d"=>t_int
		];
		var src2 = [
				{name:"start",code:[
					Push(FN_A_LESS_B, {type:[t_int,t_int], 
							 name:["a", "b"]}, null, false, "loop","start_0"),
					Assign(FN_RETURN_A, {type:[t_int], 
							 name:["a"]}, null, {type:t_int,name:"d"},"start_1"),
					Yield("start_2"),
				]},
				{name:"loop",code:[
					Assign(FN_A_FROM_B_PLUS_C, {type:[t_int,t_int,t_int], 
							 name:["a", "a", "c"]}, null, null,"loop_0"),
					Jump("loop","loop_1")
				]}
			]; 
		IvyAssembler.typeCheck(
			src2,
			types2
		);		 
		var cprogram2 = IvyAssembler.compile(
			src2,
			[for (n in types2.keys()) n],
			"start"
		);
		
		trace(check(code2, cprogram2.op));
		
		// 3.
		trace("3");

		var types3 = [
			"a"=>t_int,
			"b"=>t_int,
			"c"=>t_int,
		];		
		var src3 = [
				{name:"start",code:[
					If(FN_A_EQUALS_B, {type:[t_int,t_int], 
							 name:["a", "b"]}, null, false, "end","start_0"),
					Assign(FN_A_FROM_B_PLUS_C, {type:[t_int,t_int,t_int], 
							 name:["a", "a", "c"]}, null, null,"start_1"),
					Jump("start","start_2"),
				]},
				{name:"end",code:[
					
				]}
			];
		IvyAssembler.typeCheck(
			src3,
			types3
		);		 
		var cprogram3 = IvyAssembler.compile(
			src3,
			[for (n in types3.keys()) n],
			"start"
		);
		
		trace(check(code3, cprogram3.op));
		
		// typechecker
		
		// 1. test a simple failure.
		trace("1");
		
		var tsrc1 = [
				{name:"start",code:[
					Assign(FN_A_FROM_B_PLUS_C, {
							type:[t_int,t_int,t_float], 
							 name:["a", "a", "b"]},
							 null, null,"start_0"),
				]},
		];
		var ttypes1 = [
			"a"=>t_int,
			"b"=>t_int
		];
		
		var ok = false;
		try {
			IvyAssembler.typeCheck(tsrc1, ttypes1);
		} catch(d : Dynamic) {ok = true;}
		trace(ok);
		
		// 2. test a failure from other direction.
		trace("2");
		
		var tsrc1 = [
				{name:"start",code:[
					Assign(FN_A_FROM_B_PLUS_C, {
							type:[t_int,t_int,t_int], 
							 name:["a", "a", "b"]},
							 null, null,"start_0"),
				]},
		];
		var ttypes1 = [
			"a"=>t_int,
			"b"=>t_float
		];
		
		var ok = false;
		try {
			IvyAssembler.typeCheck(tsrc1, ttypes1);
		} catch(d : Dynamic) {ok = true;}
		trace(ok);
		
		// 3. test a cast
		trace("3");
		
		var tsrc1 = [
				{name:"start",code:[
					Assign(FN_A_FROM_B_PLUS_C, {
							type:[t_int,t_int,t_number], 
							 name:["a", "a", "b"]},
							 null, null,"start_0"),
				]},
		];
		var ttypes1 = [
			"a"=>t_int,
			"b"=>t_int
		];
		
		IvyAssembler.typeCheck(tsrc1, ttypes1);
		trace(true);
		
		// 4. test a cast from other direction
		
		var tsrc1 = [
				{name:"start",code:[
					Assign(FN_A_FROM_B_PLUS_C, {
							type:[t_int,t_int,t_int], 
							 name:["a", "a", "b"]},
							 null,null,"start_0"),
				]},
		];
		var ttypes1 = [
			"a"=>t_int,
			"b"=>t_number
		];
		
		IvyAssembler.typeCheck(tsrc1, ttypes1);
		trace(true);
		
		// switch test:
		// if a == 1 return jump 0
		// else return jump 1
		// when we use jump 1,
		// set a to 1 and jump back to the start
		
		var tsrc1 = [
				{name:"start",code:[
					Switch(FN_SWITCH, {
							type:[t_int], 
							 name:["a"]},
							 ["add","finish"],{type:t_jv,name:"jv"},
							 "start_0"),
					JumpVar({name:"jv",type:t_jv},"start_1")
				]},
				{name:"add",code:[
					Assign(FN_RETURN_A, {type:[t_int], 
							 name:["b"]}, null, {type:t_int,name:"a"},
							 "add_0"),
					Jump("start","add_1")
				]},
				{name:"finish",code:[
					Yield("finish_0")
				]},
		];
		var ttypes1 = [
			"a"=>t_int,
			"b"=>t_int,
			"jv"=>t_jv
		];
		var variables4 = new Vector<Int>(3);
		variables4[0] = 0;
		variables4[1] = 1;
		variables4[2] = 0;
		
		IvyAssembler.typeCheck(tsrc1, ttypes1);
		trace(true);
		var code4 = IvyAssembler.compile(tsrc1, [for (n in ttypes1.keys()) n], 
			"start");
		
		var ivy = new Ivy(
			code4.op,
			variables4,
			api
		);
		ivy.run();
		if (variables4[0] == 1 && variables4[1] == 1)
		{
			trace(true);
		} else {
			trace(false);
			trace(variables4);	
		}
		
	}
	
}

