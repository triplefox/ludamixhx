package ludamix.proframe;

class Proframe {
	
	/* Frame Profiler: logs timing diffs over the course of a frame. */
	
	public var times : Map<String, Int>; // all times logged
	public var lt : Int; // last logged
	public var tot : Int; // total
	public var unit : String; // timing unit
	
	public function new(times : Array<String>, unit : String) {
		this.times = new Map();
		for (n in times) this.times.set(n, 0);
		this.unit = unit;
		this.tot = 0;
	}
	
	public inline function start(t) {
		if (tot == -1) throw 'proframe tried to start frame without ending it';
		lt = t;
		for (n in times.keys()) this.times.set(n, 0);
		tot = -1;
	}
	
	public inline function log(n, t) {
		if (!this.times.exists(n)) throw 'unknown proframe name $n';
		if (tot != -1) throw 'proframe tried to log $n without starting frame';
		this.times.set(n, t - lt);
		lt = t;
	}
	
	public inline function skip(t) {
		if (tot != -1) throw 'proframe tried to skip without starting frame';
		lt = t;
	}
	
	public inline function end(t) {
		if (tot != -1) throw 'proframe ended without starting frame';
		tot = t - lt;
		for (n in this.times.keys()) {
			var v = this.times.get(n);
			tot += v;
		}
	}
	
	public function report() : Array<String> {
		if (tot == -1) throw 'proframe tried to report mid-frame';
		var result = new Array<String>();
		for (n in this.times.keys()) {
			var v = this.times.get(n);
			result.push('${n}: ${v} ${unit}');
		}
		result.push('total: ${tot} ${unit}');
		return result;
	}
	
}

