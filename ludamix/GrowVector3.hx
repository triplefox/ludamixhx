package ludamix;
import haxe.ds.Vector;

class GrowVector3<T> {
	public var d : Vector<T>;
	public var l : Int = 0;
	public var r : Int = 0;
	public function new(initial_size : Int) {
		d = new Vector<T>(initial_size);
	} 
	public inline function push(v0 : T, v1 : T, v2 : T) {
		if (l * 3 >= d.length) {
			var rlen = d.length * 3;
			if (rlen < 3) rlen = 3; 
			var nd = new Vector<T>(rlen);
			for (idx in 0...d.length) {
				nd[idx] = d[idx];
			}
			d = nd;
		}
		d[l * 3] = v0;
		d[(l * 3) + 1] = v1;
		d[(l * 3) + 2] = v2;
		l += 1;
	}
	public inline function get(i0 : Int, i1 : Int) 
		{ return d[(i0 * 3) + i1]; }
	public inline function size() {
		return l * 3;
	}
	public inline function set(i : Int, v0 : T, v1 : T, v2 : T) {
		d[i * 3] = v0; 
		d[1 + (i * 3)] = v1; 
		d[2 + (i * 3)] = v2; 
	}
	public inline function setidx(i0 : Int, i1 : Int, v : T) {
		d[i1 + (i0 * 3)] = v; 
	}
	public inline function resize(rlen : Int) {
		rlen = rlen * 3;
		if (rlen < 3) rlen = 3;
		var l = l * 3;
		if (rlen > l) {
			var nd = new Vector<T>(rlen);
			for (idx in 0...d.length) {
				nd[idx] = d[idx];
			}
			d = nd;
		} else if (rlen < l) {
			var nd = new Vector<T>(rlen);
			for (idx in 0...nd.length) {
				nd[idx] = d[idx];
			}
			d = nd;
		}
	}
	public inline function read(i1 : Int) {
		return get(r, i1);
	}
}
