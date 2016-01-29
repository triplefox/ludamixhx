package ludamix.log;

import haxe.ds.Vector;

class Log {
	
	// the log format works with groups of 4 Ints:
	// [frame, type, value0, value1]
	// when strings are needed, they go into log_strings
	// and are referenced to minimize repeats.
    // No assumptions are made about data types. Do that in your application.
	
	public var strings = new Array<String>();
	public var stringmap = new Map<String,Int>();
	public var data = new Vector<Int>(256);
	public var position : Int = 0;
	
	public function new() {
	}
	
	/* add a string to the DB */
	public function addString(v : String) : Int {
		if (stringmap.exists(v))
			return stringmap.get(v);
		else
		{
			var k = strings.length;
			strings.push(v);
			stringmap.set(v, k);
			return k;
		}
	}
	
	/* raw logging function */
	public function log(frame : Int, type : Int, v0 : Int, v1 : Int) {
		var idx = position * 4;
		if (idx + 4 > data.length) { // double size
			var cpy = new Vector(data.length * 2);
			for (n in 0...data.length)
				cpy[n] = data[n];
			data = cpy;
		}
		
		data[idx] = frame;
		data[idx + 1] = type;
		data[idx + 2] = v0;
		data[idx + 3] = v1;
		
		position += 1;
        return position - 1;
	}

	/* did the same event repeat, discounting frame time? */	
	public inline function isRepeat(position : Int) {
		if (position <= 0) return false;
		return (type(position) == type(position-1) && 
			v0(position) == v0(position-1) && 
			v1(position) == v1(position-1));
	}
	
	/* find all times between [start,duration) */
	public inline function findTimeRange(start : Int, duration : Int) {
		var result = new Array<Int>();
		for (i in 0...position) {
			var t = time(i);
			if (start >= t && start + duration < t) {
				result.push(i);
			}
		}
		return result;
	}
	
	/* find all types equal to t */
	public inline function findType(t : Int) {
		var result = new Array<Int>();
		for (i in 0...position) {
			var t1 = type(i);
			if (t == t1) {
				result.push(i);
			}
		}
		return result;
	}
	
	/* return structure of events at position */
	
	public inline function time(position : Int) {
		return data[(position) * 4];
	}
	public inline function type(position : Int) {
		return data[(position) * 4 + 1];
	}
	public inline function v0(position : Int) {
		return data[(position) * 4 + 2];
	}
	public inline function v1(position : Int) {
		return data[(position) * 4 + 3];
	}
	public inline function v0s(position : Int) {
		return strings[v0(position)];
	}
	public inline function v1s(position : Int) {
		return strings[v1(position)];
	}

    /* stringify event data */

    public inline function renderTime(position : Int) : String {
        return '${time(position)}';
    }
    public inline function renderType(position : Int) : String {
        return '${type(position)}';
    }
    public inline function renderv0(position : Int) : String {
        return '${v0(position)}';
    }
    public inline function renderv1(position : Int) : String {
        return '${v1(position)}';
    }
    public inline function renderv0s(position : Int) : String {
        return '${v0s(position)}';
    }
    public inline function renderv1s(position : Int) : String {
        return '${v1s(position)}';
    }
	
}