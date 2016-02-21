package ludamix.computedstack;
import ludamix.GrowVector8;
import haxe.ds.Vector;

class ComputedStackAddInt8 {
	
	// with "add" we emit the sum of the stack and push a default
	
	public var d = new GrowVector8<Int>(8);
	
	public var dirty : Bool = true;
	public var computed = new Vector<Int>(8);
	public var default_data = new Vector<Int>(8);
	
	public var i : Int = 0;
	
	public function new() {
	}
	
	public inline function push() {
		d.push(default_data[0], default_data[1], default_data[2], default_data[3],
			default_data[4], default_data[5], default_data[6], default_data[7]);
		i += 1;
	}
	
	public inline function pop() {
		if (i < 1) throw "ComputedStackAdd: stack underflow";
		d.l -= 1;
		i -= 1;
	}
	
	public inline function set(v0, v1, v2, v3, v4, v5, v6, v7) {
		d.set(i, v0, v1, v2, v3, v4, v5, v6, v7); dirty = true;
	}
	public inline function setIdx(idx, v) {
		d.setidx(i, idx, v); dirty = true;
	}
	public inline function recompute() {
		computed[0] = default_data[0];
		computed[1] = default_data[1];
		computed[2] = default_data[2];
		computed[3] = default_data[3];
		computed[4] = default_data[4];
		computed[5] = default_data[5];
		computed[6] = default_data[6];
		computed[7] = default_data[7];
		for (n in 0...i) {
			computed[0] += d.get(n, 0);
			computed[1] += d.get(n, 1);
			computed[2] += d.get(n, 2);
			computed[3] += d.get(n, 3);
			computed[4] += d.get(n, 4);
			computed[5] += d.get(n, 5);
			computed[6] += d.get(n, 6);
			computed[7] += d.get(n, 7);
		}
		dirty = false;
	}
	public inline function emit(buf : GrowVector8<Int>) {
		if (dirty) recompute();
		buf.push(computed[0], computed[1], computed[2],
			computed[3], computed[4], computed[5],
			computed[6], computed[7]);		
	}
	
}
