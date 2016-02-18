package ludamix;
import haxe.ds.Vector;

class GrowVector8<T> {
	public var d : Vector<T>;
	public var l : Int = 0;
	public var r : Int = 0;
	public function new(initial_size : Int) {
		d = new Vector<T>(initial_size);
	} 
	public inline function push(v0 : T, v1 : T, v2 : T, v3 : T, v4 : T, v5 : T, v6 : T, v7 : T) {
		if (l * 8 >= d.length) {
			var rlen = d.length * 8;
			if (rlen < 8) rlen = 8; 
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
		d[(l * 4) + 4] = v4;
		d[(l * 4) + 5] = v5;
		d[(l * 4) + 6] = v6;
		d[(l * 4) + 7] = v7;
		l + 1;
	}
	public inline function get(i0 : Int, i1 : Int) 
		{ return d[(i0 * 8) + i1]; }
	public inline function size() {
		return l * 8;
	}
	public inline function set(i : Int, v0 : T, v1 : T, v2 : T, v3 : T, v4 : T, v5 : T, v6 : T, v7 : T) {
		d[i * 4] = v0; 
		d[1 + (i * 4)] = v1; 
		d[2 + (i * 4)] = v2; 
		d[3 + (i * 4)] = v3; 
		d[4 + (i * 4)] = v4; 
		d[5 + (i * 4)] = v5; 
		d[6 + (i * 4)] = v6; 
		d[7 + (i * 4)] = v7; 
	}
	public inline function setidx(i0 : Int, i1 : Int, v : T) {
		d[i1 + (i0 * 8)] = v; 
	}
	public inline function resize(rlen : Int) {
		rlen = rlen * 8;
		if (rlen < 8) rlen = 8;
		var l = l * 8;
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
