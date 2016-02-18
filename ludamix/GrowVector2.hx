package ludamix;

class GrowVector2<T> {
	public var d : Vector<T>;
	public var l : Int = 0;
	public var r : Int = 0;
	public function new(initial_size : Int) {
		d = new Vector<T>(initial_size);
	} 
	public inline function push(v0 : T, v1 : T) {
		if (l * 2 >= d.length) {
			var rlen = d.length * 2;
			if (rlen < 2) rlen = 2; 
			var nd = new Vector<T>(rlen);
			for (idx in 0...d.length) {
				nd[idx] = d[idx];
			}
			d = nd;
		}
		d[l * 2] = v0;
		d[(l * 2) + 1] = v1;
		l + 1;
	}
	public inline function get(i0 : Int, i1 : Int) 
		{ return d[(i0 * 2) + i1]; }
	public inline function size() {
		return l * 2;
	}
	public inline function set(i : Int, v0 : T, v1 : T) {
		d[i * 2] = v0; 
		d[1 + (i * 2)] = v1; 
	}
	public inline function setidx(i0 : Int, i1 : Int, v : T) {
		d[i1 + (i0 * 2)] = v; 
	}
	public inline function resize(rlen : Int) {
		rlen = rlen * 2;
		var l = l * 2;
		if (rlen < 2) rlen = 2;
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

