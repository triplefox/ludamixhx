package ludamix.painter;

import haxe.ds.Vector;

class PaintResult {
	public var data : Vector<Int>;
	public var length : Int;
	public function new() { data = new Vector(3); length = 0; }
	public function clear(?and_buffer = false) {
		length = 0; if (and_buffer) data = new Vector(3);
	}
	public inline function push(x : Int, y : Int, color : Int) {
		/* Double buffer size if needed */
		while (data.length <= length * 3) {
			var nd = new Vector(data.length * 2);
			for (i0 in 0...data.length) { nd[i0] = data[i0]; }
			data = nd;
		}
		/* push */
		data[length * 3] = x;
		data[length * 3 + 1] = y;
		data[length * 3 + 2] = color;
		length += 1;
	}
	public static function fromPairs(pairs : Array<Array<Int>>, color : Int) {
		var pr = new PaintResult();
		for (p in pairs) pr.push(p[0], p[1], color);
		return pr;
	}
	public static function fromTriplets(triplets : Array<Array<Int>>) {
		var pr = new PaintResult();
		for (p in triplets) pr.push(p[0], p[1], p[2]);
		return pr;
	}
	public function copy() : PaintResult {
		var r = new PaintResult(); 
		r.data = new Vector(data.length);
		Vector.blit(data, 0, r.data, 0, r.data.length);
		r.length = length; 
		return r;
	}
	public function toString() : String {
		return Std.string([for (i0 in 0...length) data[i0]]);
	}
	public function stroke(dest : PaintResult, brush : PaintResult, color : Int) {
		for (c0 in 0...length) {
			var xr = data[c0 * 3]; var yr = data[c0 * 3 + 1];
			for (v0 in 0...brush.length)
				dest.push(xr + brush.data[v0*3], yr + brush.data[v0*3 + 1], color);
		}		
	}
	public function fillColor(color : Int) {
		for (c0 in 0...length) {
			data[c0 * 3 + 2] = color;
		}
	}
	public function translate(x : Int, y : Int, c : Int) {
		for (c0 in 0...length) {
			data[c0 * 3] += x;
			data[c0 * 3 + 1] += y;
			data[c0 * 3 + 2] += c;
		}
	}	
	public function getX(idx : Int) {
		return data[idx * 3];
	}	
	public function getY(idx : Int) {
		return data[idx * 3 + 1];
	}	
	public function getColor(idx : Int) {
		return data[idx * 3 + 2];
	}
}
