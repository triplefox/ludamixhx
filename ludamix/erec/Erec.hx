package ludamix.erec;
import haxe.ds.Vector;

class Erec {

	/* GC-friendly "Entity Rectangle" (erec) system. */
	
	/* memory layout: 
		 T * Type (unused = dead)
		 X * X position
		 Y * Y position
		 W * Width
		 H * Height
		 CS * Collision-send
		 CR * Collision-recieve
		 O * Owner (e.g. entity ID)
	*/
	
	public var unused : Int; /* the number to indicate "clear" status (default -1234) */
	
	public var data : Vector<Int>;
	public var aptr : Int; /* allocation ptr */
	
	public var aT : Int;
	public var aX : Int;
	public var aY : Int;
	public var aW : Int;
	public var aH : Int;
	public var aCS : Int;
	public var aCR : Int;
	public var aO : Int;
	
	public var bT : Int;
	public var bX : Int;
	public var bY : Int;
	public var bW : Int;
	public var bH : Int;
	public var bCS : Int;
	public var bCR : Int;
	public var bO : Int;
	
	public function new(size, ?unused = -1234) {
		data = new Vector(size * 8);
		for (n in 0...data.length) data[n] = unused;
		aptr = 0;
		this.unused = unused;
		clear();
	}
	
	public inline function alloc(type : Int) : Int {
		var timeout = 0;
		while (data[aptr] != unused && timeout < data.length) {
			aptr = (aptr + 8) % data.length;
			timeout += 1;
		}
		if (timeout >= data.length) throw "erec alloc: timeout";
		data[aptr] = type;
		for (i in 0...7) {
			data[aptr+i+1] = unused;
		}
		return aptr;
	}
	public inline function free(ptr : Int) {
		for (i in 0...8) {
			data[ptr+i] = unused;
		}
	}

	/* call this to improve your debugging experience. */
	public function clear() {
		clearA();
		clearB();
	}
	public function clearA() {
		aT = unused;
		aX = unused;
		aY = unused;
		aW = unused;
		aH = unused;
		aCS = unused;
		aCR = unused;
		aO = unused;
	}
	public function clearB() {
		bT = unused;
		bX = unused;
		bY = unused;
		bW = unused;
		bH = unused;
		bCS = unused;
		bCR = unused;
		bO = unused;
	}
	
	/* store the pointer into the A rectangle */
	public inline function loadA(ptr) { 
		aT = data[ptr];
		aX = data[ptr+1];
		aY = data[ptr+2];
		aW = data[ptr+3];
		aH = data[ptr+4];
		aCS = data[ptr+5];
		aCR = data[ptr+6];
		aO = data[ptr+7];
	}
	/* store the pointer into the B rectangle */
	public inline function loadB(ptr) { 
		bT = data[ptr];
		bX = data[ptr+1];
		bY = data[ptr+2];
		bW = data[ptr+3];
		bH = data[ptr+4];
		bCS = data[ptr+5];
		bCR = data[ptr+6];
		bO = data[ptr+7];
	}
	/* store the pointer with the A rectangle */
	public inline function storeA(ptr) {
		data[ptr] = aT;
		data[ptr+1] = aX;
		data[ptr+2] = aY;
		data[ptr+3] = aW;
		data[ptr+4] = aH;
		data[ptr+5] = aCS;
		data[ptr+6] = aCR;
		data[ptr+7] = aO;
	}
	/* store the pointer with the B rectangle */
	public inline function storeB(ptr) {
		data[ptr] = bT;
		data[ptr+1] = bX;
		data[ptr+2] = bY;
		data[ptr+3] = bW;
		data[ptr+4] = bH;
		data[ptr+5] = bCS;
		data[ptr+6] = bCR;
		data[ptr+7] = bO;
	}
	/* swap the loaded rectangles */
	public inline function swap() {
		var t = aT; aT = bT; bT = t;
		var t = aX; aX = bX; bX = t;
		var t = aY; aY = bY; bY = t;
		var t = aW; aW = bW; bW = t;
		var t = aH; aH = bH; bH = t;
		var t = aCS; aCS = bCS; bCS = t;
		var t = aCR; aCR = bCR; bCR = t;
		var t = aO; aO = bO; bO = t;
	}
	public inline function ASendB() : Bool {
		return (aCS & bCR != 0);
	}
	public inline function BSendA() : Bool {
		return (bCS & aCR != 0);
	}
	
	public inline function intersect() : Bool {
		return !(
			aX + aW - 1 < bX ||
			aY + aH - 1 < bY ||
			aX > bX + bW - 1 ||
			aY > bY + bH - 1
		);
	}
	public inline function intersectPoint(x : Int, y : Int) : Bool {
		return !(
			aX + aW - 1 < x ||
			aY + aH - 1 < y ||
			aX > x - 1 ||
			aY > y - 1
		);
	}
	public inline function intersectX() : Bool {
		return !(
			aX + aW - 1 < bX ||
			aX > bX + bW - 1
		);
	}
	public inline function intersectY() : Bool {
		return !(
			aY + aH - 1 < bY ||
			aY > bY + bH - 1
		);
	}
	
	/* set A to the union of A and B */
	public inline function union() {
		var left = aX < bX ? aX : bX;
		var right = aX + aW - 1 < bX + bW - 1 ? aX + aW - 1: bX + bW - 1;
		var top = aY < bY ? aY : bY;
		var bottom = aY + aH - 1 < bY + bH - 1 ? aY + aH - 1 : bY + bH - 1;
		aX = left;
		aY = top;
		aW = right - left;
		aH = bottom - top;
	}
	
	/* set A to the union of A and the given point */
	public inline function unionPoint(x : Int, y : Int) {
		var left = aX < x ? aX : y;
		var right = aX + aW - 1 < x - 1 ? aX + aW - 1: x - 1;
		var top = aY < y ? aY : y;
		var bottom = aY + aH - 1 < y - 1 ? aY + aH - 1 : y - 1;
		aX = left;
		aY = top;
		aW = right - left;
		aH = bottom - top;
	}
	
	/* set A to the pushout of A against B's left side */
	public inline function pushoutLeft() {
		aX = bX - aW;
	}
	/* set A to the pushout of A against B's top side */
	public inline function pushoutTop() {
		aY = bY - aH;
	}
	/* set A to the pushout of A against B's right side */
	public inline function pushoutRight() {
		aX = bX + bW;
	}
	/* set A to the pushout of A against B's bottom side */
	public inline function pushoutBottom() {
		aY = bY + bH;
	}
	
	/* sort comparison: by liveness, then by X */
	private function compareX(a : Int, b : Int) {
		if (data[a] == unused) return 1;
		else if (data[b] == unused) return -1; 
		else return data[a + 1] - data[b + 1];
	}
	/* sort comparison: by liveness, then by Y */
	private function compareY(a : Int, b : Int) {
		if (data[a] == unused) return 1;
		else if (data[b] == unused) return -1; 
		else return data[a + 2] - data[b + 2];
	}
	
	/* given an Array<Int> of erec handles,
	 * and a result Array<Int> of match pairs, 
	 * sort the erecs by X position,
	 * find all the colliding rectangles
	 * and return the number of matches. */
	public function collideAllX(ptrsort : Array<Int>, result : Array<Int>) : Int {
		ptrsort.sort(compareX);
		var ri = 0;
		for (i0 in 0...(ptrsort.length - 1)) {
			loadA(ptrsort[i0]);
			var i1 = i0 + 1;
			while (i1 < ptrsort.length) {
				loadB(ptrsort[i1]);
				if (intersectX()) {
					if (intersectY()) {
						if (result.length < ri) { result.push(i0); }
							else { result[ri] = ptrsort[i0]; }
						if (result.length < ri + 1) { result.push(i1); }
							else { result[ri + 1] = ptrsort[i1]; }
						ri += 2;
					}
				} else break;
				i1 += 1;
			}
		}
		return ri >> 1;
	}
	
	/* given an Array<Int> of erec handles,
	 * and a result Array<Int> of match pairs, 
	 * sort the erecs by Y position,
	 * find all the colliding rectangles
	 * and return the number of matches. */
	public function collideAllY(ptrsort : Array<Int>, result : Array<Int>) : Int {
		ptrsort.sort(compareY);
		var ri = 0;
		for (i0 in 0...(ptrsort.length - 1)) {
			loadA(ptrsort[i0]);
			var i1 = i0 + 1;
			while (i1 < ptrsort.length) {
				loadB(ptrsort[i1]);
				if (intersectY()) {
					if (intersectX()) {
						if (result.length < ri) { result.push(i0); }
							else { result[ri] = ptrsort[i0]; }
						if (result.length < ri + 1) { result.push(i1); }
							else { result[ri + 1] = ptrsort[i1]; }
						ri += 2;
					}
				} else break;
				i1 += 1;
			}
		}
		return ri >> 1;
	}
	
}


