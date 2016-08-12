package ludamix.kha;
import ludamix.StackInt8;
import ludamix.StackBool;

class DrawStack {

	public var transform = new FastMatrix3Stack();
	public var scissor = new StackInt8();
	public var scissor_on = new StackBool();
	public var addint = new ludamix.computedstack.ComputedStackAddInt8();
	public var addfloat = new ludamix.computedstack.ComputedStackAddFloat8();
	public var addfloat2 = new ludamix.computedstack.ComputedStackAddFloat8();
	public var mulfloat = new ludamix.computedstack.ComputedStackMulFloat8();
	public var topint = new GrowVector8<Int>(8);
	public var topfloat = new GrowVector8<Float>(8);
	public var topfloat2 = new GrowVector8<Float>(8);
	
	public var i = -1;

	public function new() {}
	
	public inline function push() {
		transform.push();
		scissor.push();
		scissor_on.push();
		addint.push();
		addfloat.push();
		addfloat2.push();
		mulfloat.push();
		topint.push(topint.get(i, 0),topint.get(i, 1),topint.get(i, 2),
			topint.get(i, 3), topint.get(i, 4),topint.get(i, 5),
			topint.get(i, 6),topint.get(i, 7));
		topfloat.push(topfloat.get(i, 0),topfloat.get(i, 1),topfloat.get(i, 2),
			topfloat.get(i, 3), topfloat.get(i, 4),topfloat.get(i, 5),
			topfloat.get(i, 6),topfloat.get(i, 7));
		topfloat2.push(topfloat2.get(i, 0),topfloat2.get(i, 1),topfloat2.get(i, 2),
			topfloat2.get(i, 3), topfloat2.get(i, 4),topfloat2.get(i, 5),
			topfloat2.get(i, 6),topfloat2.get(i, 7));
		i += 1;
	}
	
	public inline function pop() {
		if (i < 0) throw "DrawStack: stack underflow";				
		i -= 1;
		transform.pop();
		scissor.pop();
		scissor_on.pop();
		addint.pop();
		addfloat.pop();
		addfloat2.pop();
		mulfloat.pop();
		topint.l -= 1;
		topfloat.l -= 1;
		topfloat2.l -= 1;
	}
	
	public inline function reset() {
		while (i > -1) pop();
	}
	
}

