package com.ludamix.ivy;

typedef IvyOp = Array<Int>;

class Ivy
{
	
	public static inline var EXEC = 0;
	public static inline var IF = 1;
	public static inline var PUSH = 2;
	public static inline var JUMP = 3;
	
	public static inline var CONTINUE = 5;
	public static inline var POP = 6;
	public static inline var YIELD = 7;
	
	public static inline var TIMEOUT = 1000;
	
	// Ivy Interactivity VM
	
	// This VM provides structure for cooperative multitasking:
	//    Besides having a linear program counter, branching, and the ability to yield execution,
	//	  it can "push" a concurrent state. Pushed state is similar to but unlike a subroutine:
	//	  every time the program counter advances, it traverses through pushed states and tests
	//    their logic again. As soon as the logic fails, the states unwind.
	
	// Higher level languages are intended to be written on top of Ivy's model and compiled into its
	// opcode format.
	
	// Ivy uses a "structured opcode" semantics that is easy to debug.
	// To integrate into a project, just create an API table for EXEC, IF, PUSH, etc.
	
	public var variables : Array<Int>;
	public var code : Array<IvyOp>;
	public var stack : Array<Int>;
	public var exec_api : Array<Ivy->Array<Int>->Void>;
	public var if_api : Array<Ivy->Array<Int>->Bool>;
	public var push_api : Array<Ivy->Array<Int>->Bool>;
	public var jump_to : Int;
	public var stackpush : Bool;
	public var last_instruction : Int;
	public var last_status : Int;
	
	public function read(stack_idx : Int)
	{

		var pc = stack[stack_idx];
		var op = code[pc][0];
		var args = code[pc].slice(1);
		stackpush = false;
		last_instruction = op;
		jump_to = pc + 1;
		
		switch(op)
		{
			case EXEC: exec_api[args[0]](this, [for(n in args.slice(1)) variables[n]]);
			case CONTINUE, YIELD, POP: last_status = op;
			case IF: if (!if_api[args[0]](this, [for(n in args.slice(1)) variables[n]])) jump_to++;
			case PUSH: if (push_api[args[0]](this, [for(n in args.slice(2)) variables[n]])) { jump_to = args[1]; stackpush = true; } 
			case JUMP: jump_to = args[0];
		}
		
		if (stackpush) // recurse into next PC
		{
			if (stack_idx < stack.length - 1) // continue existing stack
			{
				read(stack_idx + 1);
			}
			else // push new PC on stack
			{
				stack.push(jump_to);
				read(stack_idx + 1);
			}
		}
		else if (last_status == POP)
		{
			stack.pop();
			stack_idx--;
			if (stack.length == 0)
				stack = [0];
			else
				stack[stack_idx]++;
			last_status = CONTINUE;
		}
		else
		{
			while (stack_idx < stack.length - 1)
				stack.pop();
			pc = jump_to;
			stack[stack_idx] = pc;
		}
		
	}
	
	public function run()
	{
		var time = 0;
		last_status = CONTINUE;
		while (last_status == CONTINUE)
		{
			read(0);
			time++;
			if (time >= TIMEOUT) throw "Ivy timeout";
		}
	}
	
	public function renderOpcode(op : Int)
	{
		switch(op)
		{
			case EXEC: return 'EXEC';
			case IF: return 'IF';
			case PUSH: return 'PUSH';
			case JUMP: return 'JUMP';
			case CONTINUE: return 'CONTINUE';
			case POP: return 'POP';
			case YIELD: return 'YIELD';
			default: return '$op';
		}
	}
	
	public function renderAddress(idx : Int)
	{
		return StringTools.hex(idx, 8) + ': ' + renderOpcode(code[idx][0]) + Std.string(code[idx].slice(1));
	}
	
	public function new(code, variables, exec_api, if_api, push_api)
	{
		this.code = code;
		this.variables = variables;
		this.stack = [0];
		this.exec_api = exec_api;
		this.if_api = if_api;
		this.push_api = push_api;
		this.jump_to = 0;
		this.stackpush = false;
		this.last_instruction = CONTINUE;
		this.last_status = CONTINUE;
	}
	
}