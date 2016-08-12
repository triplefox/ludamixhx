package ludamix.kha;

class FastMatrix3Stack {
	
	public var d : GrowVector8FastMatrix3;
	public var i = -1;
	
	public function new() {
		d = new GrowVector8FastMatrix3(8);		
	}
	
	public inline function push() {
		d.push();
		if (i > -1) {
			for (j in 0...8) {
				var mtx = d.get(i, j);
				d.setidx(i+1, j, 
					mtx._00, mtx._01, mtx._02,
					mtx._10, mtx._11, mtx._12,
					mtx._20, mtx._21, mtx._22
				);
			}
		}
		i += 1;
	}
	
	public inline function pop() {
		if (i < 0) throw "FastMatrix3Stack: stack underflow";
		d.l -= 1;
		i -= 1;
	}
	
	public inline function get(idx) {
		return d.get(i, idx); 
	}
	public inline function set(idx, v) {
		if (i < 0) throw "FastMatrix3Stack: nothing on stack";
		d.setidx(i, idx, v._00, v._01, v._02, 
				v._10, v._11, v._12, 
				v._20, v._21, v._22);
	}
	
}

