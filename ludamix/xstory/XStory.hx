package ludamix.xstory;
import haxe.ds.Vector;

@:enum
abstract XStoryOp(Int) {
	var RUNSTEP = 0;
	var RUNWAIT = 1;
	var WAIT = 2;
	var WAITSTEP = 3;
	var POP = 4;
	var PUSH = 5;
	var CJUMP = 6;
	var RJUMP = 7;
	var CIF = 8;
	var RIF = 9;
	var WAITIF = 10;
	var GSET = 11;
	var LSET = 12;
	public function new(i) { this = i; }
	public function asInt() : Int { return this; }
}

class XStory {
	
	/* cooperative multitasking state machine for "Extendable Story" and "AI" type uses. */
	
	public var programs : Array<{name:String,locals:Int,local_default:Int,code:Array<Array<Int>>}>;	
	public var stack : Array<Array<Int>>;
	public var globals : Vector<Int>;
	public var runcode : Array<XStory->Int->Array<Int>->Void>;
	public var ifcode : Array<XStory->Int->Array<Int>->Bool>;
	public var last_error : String;
	public var timeout : Int;
	
	public function new() {
		programs = [];
		stack = [];
		globals = null;
		runcode = null;
		timeout = 1000;
	}
	
	public function start(program : Int, step : Int) : String {
		stack = [[program, step]];
		if (programs.length <= program || programs[program] == null)
			return error(-1, 'invalid program $program');
		for (n in 0...programs[program].locals) 
			stack[0].push(programs[program].local_default);
		return null;
	}
	
	public function error(si : Int, msg : String) : String {
		last_error = '$msg (Stack index $si)';
		return last_error;
	}
	
	public function validate() {
		for (p in programs) {
			for (i in 0...p.code.length) {
				var instruction = p.code[i];
				if (instruction.length < 1) throw "empty instruction #$i in program ${p.name}";
				else switch(new XStoryOp(instruction[0])) {
					case RUNSTEP:
						if (instruction.length < 2)
							throw '${p.name}: RUNSTEP at $i has too few parameters (expected 2)';
						if (runcode.length <= instruction[1] || runcode[instruction[1]] == null)
							throw '${p.name}: RUNSTEP at $i maps to invalid runcode ${instruction[1]}';
					case RUNWAIT:
						if (instruction.length < 2)
							throw '${p.name}: RUNWAIT at $i has too few parameters (expected 2)';
						if (runcode.length <= instruction[1] || runcode[instruction[1]] == null)
							throw '${p.name}: RUNWAIT at $i maps to invalid runcode ${instruction[1]}';
					case WAIT:
					case WAITSTEP:
					case POP:
						if (instruction.length < 2)
							throw '${p.name}: POP at $i has too few parameters (expected 2)';
					case PUSH:
						if (instruction.length < 3)
							throw '${p.name}: PUSH at $i has too few parameters (expected 3)';
					case CJUMP:
						if (instruction.length < 2)
							throw '${p.name}: CJUMP at $i has too few parameters (expected 2)';
					case RJUMP:		
						if (instruction.length < 2)
							throw '${p.name}: RJUMP at $i has too few parameters (expected 2)';
					case CIF:
						if (instruction.length < 3)
							throw '${p.name}: CIF at $i has too few parameters (expected 3)';
						if (ifcode.length <= instruction[1] || ifcode[instruction[1]] == null)
							throw '${p.name}: CIF at $i maps to invalid ifcode ${instruction[1]}';
					case RIF:
						if (instruction.length < 3)
							throw '${p.name}: RIF at $i has too few parameters (expected 3)';
						if (ifcode.length <= instruction[1] || ifcode[instruction[1]] == null)
							throw '${p.name}: RIF at $i maps to invalid ifcode ${instruction[1]}';
					case WAITIF:
						if (instruction.length < 2)
							throw '${p.name}: WAITIF at $i has too few parameters (expected 2)';
						if (ifcode.length <= instruction[1] || ifcode[instruction[1]] == null)
							throw '${p.name}: WAITIF at $i maps to invalid ifcode ${instruction[1]}';
					case GSET:
						if (instruction.length < 3)
							throw '${p.name}: GSET at $i has too few parameters (expected 3)';
					case LSET:
						if (instruction.length < 3)
							throw '${p.name}: LSET at $i has too few parameters (expected 3)';
					default:
						throw '${p.name}: invalid instruction $instruction';
				}
			}
		}
	}
	
	public function run() : String {
		var si = 0; // stack index
		var time = 0;
		
		while (si < stack.length && si >= 0) { // run step
			time += 1;
			if (time > timeout) return error(si, 'timeout');
			var state = stack[si];
			var programi = state[0];
			if (programs.length <= programi || programs[programi] == null)
				return error(si, 'invalid program $programi');
			var counter = state[1];
			var program = programs[programi];
			if (counter >= program.code.length)
				return error(si, 'invalid position $counter in program ${program.name}');
			var instruction = program.code[counter];
			switch(new XStoryOp(instruction[0])) {
				case RUNSTEP:
					runcode[instruction[1]](this, si, instruction);
					counter += 1;
				case RUNWAIT:
 					runcode[instruction[1]](this, si, instruction);
					si += 1;
				case WAIT:
					if (instruction.length > 1) {
						state[instruction[1]] -= 1;
						if (state[instruction[1]] < 0)
							counter += 1;
						else
							si += 1;
					}
					else 
						si += 1;
				case WAITSTEP:
					counter += 1;
					si += 1;
				case POP:
					var c = instruction[1];
					while (stack.length > si + 1) // unwind above
						stack.pop();
					while (stack.length > 0 && c > 0) { // unwind below
						si -= 1;
						c -= 1;
						stack.pop();
					}
					if (stack.length > si && stack.length > 0)
					{
						state = stack[si];
						counter = stack[si][1] + 1;
					}
				case PUSH:
					var nprogram = instruction[1];
					var ns = [nprogram, instruction[2]];
					if (programs.length <= nprogram || programs[nprogram] == null)
						return error(si, 
							'invalid pushed program $nprogram at position ' +
							'$counter in program ${program.name}');
					var npinst = programs[nprogram];
					for (n in 0...npinst.locals) ns.push(npinst.local_default);
					stack.push(ns);
					counter += 1;
				case CJUMP:
					counter = instruction[1];
				case RJUMP:		
					counter += instruction[1];
				case CIF:
					if (!ifcode[instruction[1]](this, si, instruction)) {
						counter = instruction[2];
					} else counter += 1;
				case RIF:
					if (!ifcode[instruction[1]](this, si, instruction)) {
						counter += instruction[2];
					} else counter += 1;
				case WAITIF:
					if (!ifcode[instruction[1]](this, si, instruction)) {
						counter += 1;
					} else si += 1;
				case GSET:
					globals[instruction[1]] = instruction[2];
					counter += 1;
				case LSET:
					state[instruction[1]] = instruction[2];
					counter += 1;
				default:
					return error(si, 'invalid instruction $instruction');
			}
			state[1] = counter;
		}
		
		return null;		
	}
	
}

