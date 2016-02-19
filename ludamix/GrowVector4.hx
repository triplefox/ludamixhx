package ludamix;
import haxe.ds.Vector;

class GrowVector4<T> {
	public var d : Vector<T>;
	public var l : Int = 0;
	public var r : Int = 0;
	public function new(initial_size : Int) {
		d = new Vector<T>(initial_size);
	} 
	public inline function push(v0 : T, v1 : T, v2 : T, v3 : T) {
		if (l * 4 >= d.length) {
			var rlen = d.length * 4;
			if (rlen < 4) rlen = 4; 
			var nd = new Vector<T>(rlen);
			for (idx in 0...d.length) {
				nd[idx] = d[idx];
			}
			d = nd;
		}
		d[l * 4] = v0;
		d[(l * 4) + 1] = v1;
		d[(l * 4) + 2] = v2;
		d[(l * 4) + 3] = v3;
		l += 1;
	}
	public inline function get(i0 : Int, i1 : Int) 
		{ return d[(i0 * 4) + i1]; }
	public inline function size() {
		return l * 4;
	}
	public inline function set(i : Int, v0 : T, v1 : T, v2 : T, v3 : T) {
		d[i * 4] = v0; 
		d[1 + (i * 4)] = v1; 
		d[2 + (i * 4)] = v2; 
		d[3 + (i * 4)] = v3; 
	}
	public inline function setidx(i0 : Int, i1 : Int, v : T) {
		d[i1 + (i0 * 4)] = v; 
	}
	public inline function resize(rlen : Int) {
		rlen = rlen * 4;
		if (rlen < 4) rlen = 4;
		var l = l * 4;
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
