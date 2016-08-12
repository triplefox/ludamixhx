package ludamix;

class StackBool {
	
	public var d : GrowVector1<Bool>;
	public var i = -1;
	
	public function new() {
		d = new GrowVector1<Bool>(1);
		d.set(0, false);
	}
	
	public inline function push() {
		d.push(d.get(i));
		i += 1;
	}
	
	public inline function pop() {
		if (i < 0) throw "StackBool: stack underflow";
		d.l -= 1;
		i -= 1;
	}
	
	public inline function get() {
		return d.get(i); 
	}
	public inline function set(v) {
		if (i < 0) throw "StackBool: nothing on stack";
		d.set(i, v);
	}
	
}

