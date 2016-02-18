package ludamix.computedstack;

class ComputedStackOperation {
	public var t : ComputedStackOpcode;
	public var i : Int; // (index)
	public var v : Int; // (int value)
	public var f : Float; // (float value)
	public var s : String; // (string value)
	public function new() {
		
	}
}

enum ComputedStackOpcode {
	PushStack;
	PopStack;	
	SetAddInt; // i, v
	SetAddInt2; // i, v
	SetTopInt; // i, v
	SetTopInt2; // i, v
	SetAddFloat; // i, f
	SetMulFloat; // i, f
	SetTopFloat; // i, f
	SetString; // i, s
	DefaultAddInt; // i, v
	DefaultAddInt2; // i, v
	DefaultAddFloat; // i, f
	DefaultMulFloat; // i, f
	Emit; // i (protocol)
}

