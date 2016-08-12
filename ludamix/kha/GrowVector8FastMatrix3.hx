package ludamix.kha;

import haxe.ds.Vector;
import kha.math.FastMatrix3;

class GrowVector8FastMatrix3 {

	public var d : Vector<FastMatrix3>;
	public var l : Int = 0;
	public var r : Int = 0;
	public function new(initial_size : Int) {
		d = new Vector<FastMatrix3>(initial_size);
		for (n in 0...initial_size)
			d[n] = FastMatrix3.identity();
	} 
	public inline function push() {
		l += 1;
		if (l * 8 > d.length) {
			var rlen = d.length * 2;
			if (rlen < l * 8) rlen = l * 8;
			var nd = new Vector<FastMatrix3>(rlen);
			for (idx in 0...d.length) {
				nd[idx] = d[idx];
			}
			for (idx in d.length...nd.length)
				nd[idx] = FastMatrix3.identity();
			d = nd;
		}
	}
	public inline function get(i0 : Int, i1 : Int) 
		{ return d[(i0 * 8) + i1]; }
	public inline function size() {
		return l * 8;
	}
	public inline function setidx(i0 : Int, i1 : Int, 
		v00 : kha.FastFloat, v01 : kha.FastFloat, v02 : kha.FastFloat,
		v10 : kha.FastFloat, v11 : kha.FastFloat, v12 : kha.FastFloat,
		v20 : kha.FastFloat, v21 : kha.FastFloat, v22 : kha.FastFloat) {
		var dd = d[i1 + (i0 * 8)];
		dd._00 = v00; dd._01 = v01; dd._02 = v02;
		dd._10 = v10; dd._11 = v11; dd._12 = v12;
		dd._20 = v20; dd._21 = v21; dd._22 = v22;
	}
	public inline function setidx2(i0 : Int, i1 : Int, m : FastMatrix3) {
		var dd = d[i1 + (i0 * 8)];
		dd._00 = m._00; dd._01 = m._01; dd._02 = m._02;
		dd._10 = m._10; dd._11 = m._11; dd._12 = m._12;
		dd._20 = m._20; dd._21 = m._21; dd._22 = m._22;
	}
	public inline function copy(i0 : Int, i1 : Int, j0 : Int, j1 : Int) {
		var iv = d[i1 + (i0 * 8)];
		var jv = d[j1 + (j0 * 8)];
		jv._00 = iv._00; jv._01 = iv._01; jv._02 = iv._02;
		jv._10 = iv._10; jv._11 = iv._11; jv._12 = iv._12;
		jv._20 = iv._20; jv._21 = iv._21; jv._22 = iv._22;
	}
	public inline function resize(rlen : Int) {
		rlen = rlen * 8;
		if (rlen < 8) rlen = 8;
		var l = l * 8;
		if (rlen > l) {
			var nd = new Vector<FastMatrix3>(rlen);
			for (idx in 0...d.length) {
				nd[idx] = d[idx];
			}
			for (idx in d.length...nd.length)
				d[idx] = FastMatrix3.identity();
			d = nd;
		} else if (rlen < l) {
			var nd = new Vector<FastMatrix3>(rlen);
			for (idx in 0...nd.length) {
				nd[idx] = d[idx];
			}
			d = nd;
		}
	}
	public inline function reset() {
		for (n in d) {
			n._00 = 1.;
			n._01 = 0.;
			n._02 = 0.;
			n._10 = 0.;
			n._11 = 1.;
			n._12 = 0.;
			n._20 = 0.;
			n._21 = 0.;
			n._22 = 1.;
		}
		l = 0;
		r = 0;
	}
	public inline function read(i1 : Int) {
		return get(r, i1);
	}
}

