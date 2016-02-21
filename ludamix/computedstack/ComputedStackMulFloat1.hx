package ludamix.computedstack;
import ludamix.GrowVector1;
import haxe.ds.Vector;

class ComputedStackMulFloat1 {
	
	// with "mul" we emit the exponentiation of the stack and push a default
	
	public var d = new GrowVector1<Float>(1);
	
	public var dirty : Bool = true;
	public var computed = 0.;
	public var default_data = 0.;
	
	public var i : Int = 0;
	
	public function new() {
	}
	
	public inline function push() {
		d.push(default_data);
		i += 1;
	}
	
	public inline function pop() {
		if (i < 1) throw "ComputedStackMul: stack underflow";
		d.l -= 1;
		i -= 1;
	}
	
	public inline function set(v0) {
		d.set(i, v0); dirty = true;
	}
	public inline function recompute() {
		computed = default_data;
		for (n in 0...i) {
			computed *= d.get(n, 0);
		}
		dirty = false;
	}
	public inline function emit(buf : GrowVector1<Float>) {
		if (dirty) recompute();
		buf.push(computed);
	}
	
}
