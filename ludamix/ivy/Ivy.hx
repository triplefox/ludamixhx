package ludamix.ivy;
import haxe.ds.Vector;

typedef IvyOp = Array<Array<Int>>;

class Ivy
{
	
	public static inline var ASSIGN = 0;
	public static inline var IF = 1;
	public static inline var PUSH = 2;
	public static inline var JUMP = 3;
	public static inline var JUMPVAR = 4;
	
	public static inline var CONTINUE = 10;
	public static inline var POP = 11;
	public static inline var YIELD = 12;
	
	public static inline var TIMEOUT = 1000;	
	public static inline var MAX_MONITOR = 100;
	
	// Ivy Interactivity VM
	
	// This VM provides structure for cooperative multitasking:
	//    Besides having a linear program counter, branching, and the ability to yield execution,
	//	  it can "push" a concurrent state. Pushed state is similar to but unlike a subroutine:
	//	  every time the program counter advances, it traverses through pushed states and tests
	//    their logic again. As soon as the logic fails, the states unwind.
	
	// Higher level languages are intended to be written on top of Ivy's model and compiled into its
	// opcode format.
	
	// To integrate into a project, just create an API call array:
	// The four arguments to each call are the interpeter instance,
	// variables referenced, a look-up table of static data,
	// and a variable assignment result(if assignment is used, otherwise -1).
	
	public var variables : Vector<Int>;
	public var code : Array<IvyOp>;
	public var stack : Array<Int>;
	public var api_calls : Array<Ivy->Array<Int>->Array<Int>->Int>;
	public var jump_to : Int;
	public var stackpush : Bool;
	public var last_instruction : Int;
	public var last_status : Int;
	
	public var debug_monitor : Map<Int, Array<{pc:Int, v:Int}>>; // log of when a var changes and where
	public var debug_monitor_var : Array<Int>; // variables to monitor 
	public var debug_breakpoint_pc : Array<Int>; // break on counter stepping into
	public var debug_breakpoint_monitor : Array<Int>; // break on var change
	
	public function read(stack_idx : Int)
	{
		var pc = stack[stack_idx];
		if (pc >= code.length) {
			last_status = YIELD;
		} else {
			var pcdata = code[pc];
			var op = pcdata[0];
			stackpush = false;
			last_instruction = op[0];
			jump_to = pc + 1;
			
			switch(op[0])
			{
				case CONTINUE, YIELD, POP: last_status = op[0];
				case IF: 
					if (op[1] < 0) {
						if (api_calls[-1 - op[1]](this, pcdata[1], pcdata[2])==0) jump_to = op[2];
					} else {
						if (api_calls[op[1]](this, pcdata[1], pcdata[2])!=0) jump_to = op[2];
					}
				case PUSH: 
					if (op[1] < 0) {
						if (api_calls[-1 - op[1]](this, pcdata[1], pcdata[2])==0) { jump_to = op[2]; stackpush = true; } 						
					} else {
						if (api_calls[op[1]](this, pcdata[1], pcdata[2])!=0) { jump_to = op[2]; stackpush = true; }
					}
				case JUMP: 
					jump_to = op[1];
				case JUMPVAR: 
					jump_to = variables[op[1]];
				case ASSIGN:
					if (op[2] >= 0)
						variables[op[2]] = api_calls[op[1]](this, pcdata[1], pcdata[2]);
					else
						api_calls[op[1]](this, pcdata[1], pcdata[2]);
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
	}
	
	public function run()
	{
		var time = 0;
		last_status = CONTINUE;
		while (last_status == CONTINUE)
		{
			read(0);
			time++;
			if (time >= TIMEOUT) throw 'Ivy timeout: $stack $variables';
		}
	}
	
	public function trace(count : Int)
	{
		var time = 0;
		last_status = CONTINUE;
		var result = new Array<Array<Array<Int>>>();
		for (n in debug_monitor_var) {
			if (!debug_monitor.exists(n)) {
				// first assignment
				debug_monitor.set(n, [{v:variables[n],pc:stack[stack.length - 1]}]);
			}
		}		
		while (last_status == CONTINUE)
		{
			read(0);
			result.push([stack.copy(), variables.toArray()]); // record entire stack and all variables for this frame
			time++;
			// init debug infos
			var do_break = false;
			// break on enter program location
			for (n in debug_breakpoint_pc) {
				for (s in stack) {
					if (s == n)
						do_break = true;
				}
			}
			// update debug infos
			if (debug_monitor_var != null) {
				if (last_instruction == ASSIGN) {
					for (n in debug_monitor_var) {
						var monitor = debug_monitor.get(n); 
						if (code[stack[stack.length - 1]][0][2] == n) {
							// explicit assignment 
							monitor.push({v:variables[n],pc:stack[stack.length - 1]});
							for (m in debug_breakpoint_monitor) {
								if (n==m)
									do_break = true;
							}
						}
						else if (monitor[monitor.length - 1].v != variables[n]){
							// capture differences created by external APIs
							monitor.push({v:variables[n],pc:stack[stack.length - 1]});
							for (m in debug_breakpoint_monitor) {
								if (n==m)
									do_break = true;
							}
						}
						// limit quantity of monitor traces
						if (monitor.length >= MAX_MONITOR) monitor.shift();
					}
				}
			}
			if (count > 0 && time >= count) return result;
			if (time >= TIMEOUT) throw 'Ivy timeout: $stack $variables';
			if (do_break) return result;
		}
		return result;
	}
	
	public static function renderOpcode(op : Int)
	{
		switch(op)
		{
			case IF: return 'IF';
			case PUSH: return 'PUSH';
			case JUMP: return 'JUMP';
			case JUMPVAR: return 'JUMPVAR';
			case ASSIGN: return 'ASSIGN';
			case CONTINUE: return 'CONTINUE';
			case POP: return 'POP';
			case YIELD: return 'YIELD';
			default: return '$op';
		}
	}
	
	public static function renderOpcodeProgram(op : IvyOp) {
		return renderOpcode(op[0][0])+" "+op[0].slice(1).join(",");
	}
	
	public static function renderArguments(op : IvyOp) {
		if (op.length > 1)
			return " args [" + op[1].join(",") + "]";
		else
			return "";
	}
	
	public static function renderLut(op : IvyOp) {
		if (op.length > 2)
			return " lut [" + op[2].join(",") + "]";
		else
			return "";
	}
	
	public static function renderAddress(code : Array<IvyOp>, idx : Int)
	{
		return StringTools.lpad(Std.string(idx), "0", 6) + ': ' + 
			renderOpcodeProgram(code[idx]) + 
			renderArguments(code[idx]) +
			renderLut(code[idx]);
	}
	
	public function new(code, variables, api_calls, use_debug = false)
	{
		this.code = code;
		this.variables = variables;
		this.stack = [0];
		this.api_calls = api_calls;
		this.jump_to = 0;
		this.stackpush = false;
		this.last_instruction = CONTINUE;
		this.last_status = CONTINUE;
		if (use_debug) {
			debug_monitor = new Map();
			debug_monitor_var = new Array();
			debug_breakpoint_pc = new Array();
			debug_breakpoint_monitor = new Array();
		}
	}
	
}