package ludamix.computedstack;
import ludamix.GrowVector2;
import haxe.ds.Vector;

class ComputedStackMulFloat2 {
	
	// with "mul" we emit the exponentiation of the stack and push a default
	
	public var d = new GrowVector2<Float>(2);
	
	public var dirty : Bool = true;
	public var computed = new Vector<Float>(2);
	public var default_data = new Vector<Float>(2);
	
	public var i : Int = 0;
	
	public function new() {
	}
	
	public inline function push() {
		d.push(default_data[0],default_data[1]);
		i += 1;
	}
	
	public inline function pop() {
		if (i < 1) throw "ComputedStackMul: stack underflow";
		d.l -= 1;
		i -= 1;
	}
	
	public inline function set(v0, v1) {
		d.set(i, v0, v1); dirty = true;
	}
	public inline function setIdx(idx, v) {
		d.setidx(i, idx, v); dirty = true;
	}
	public inline function recompute() {
		computed[0] = default_data[0];
		computed[1] = default_data[1];
		for (n in 0...i) {
			computed[0] *= d.get(n, 0);
			computed[1] *= d.get(n, 1);
		}
		dirty = false;
	}
	public inline function emit(buf : GrowVector2<Float>) {
		if (dirty) recompute();
		buf.push(computed[0], computed[1]);
	}
	
}
