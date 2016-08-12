package ludamix;

class StackInt8 {
	
	public var d : GrowVector8<Int>;
	public var i = -1;
	
	public function new() {
		d = new GrowVector8<Int>(8);
		d.set(0,0,0,0,0,0,0,0,0);
	}
	
	public inline function push() {
		d.push(d.get(i,0),d.get(i,1),d.get(i,2),d.get(i,3),
		d.get(i,4),d.get(i,5),d.get(i,6),d.get(i,7));
		i += 1;
	}
	
	public inline function pop() {
		if (i < 0) throw "StackInt8: stack underflow";
		d.l -= 1;
		i -= 1;
	}
	
	public inline function get(idx) {
		return d.get(i, idx); 
	}
	public inline function set(idx, v) {
		if (i < 0) throw "StackInt8: nothing on stack";
		d.setidx(i, idx, v);
	}
	
}

