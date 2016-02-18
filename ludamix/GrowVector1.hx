package ludamix;
import haxe.ds.Vector;

class GrowVector1<T> {
	public var d : Vector<T>;
	public var l : Int = 0;
	public var r : Int = 0;
	public function new(initial_size : Int) {
		d = new Vector<T>(initial_size);
	} 
	public inline function push(v : T) {
		if (l >= d.length) {
			var rlen = d.length * 2;
			if (rlen < 1) rlen = 1;
			var nd = new Vector<T>(rlen);
			for (idx in 0...d.length) {
				nd[idx] = d[idx];
			}
			d = nd;
		}
		d[l] = v;
		l += 1;
	}	
	public inline function get(i : Int) 
		{ return d[i]; }
	public inline function size() {
		return l;
	}
	public inline function set(i : Int, v : T) {
		d[i] = v; 
	}
	public inline function resize(rlen : Int) {
		if (rlen < 1) rlen = 1;
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
	public inline function read() {
		return get(r);
	}
}

