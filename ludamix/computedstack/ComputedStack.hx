package ludamix.computedstack;
import ludamix.GrowVector8;
import haxe.ds.Vector;

class ComputedStack {
	
	// with "add" we emit the sum of the stack and push a default
	// with "top" we emit the topmost value and push the topmost value
	// with "mul" we emit the exponentiation of the stack and push a default
	
	public var addint = new GrowVector8<Int>(8);
	public var addint2 = new GrowVector8<Int>(8);
	public var topint = new GrowVector8<Int>(8);
	public var topint2 = new GrowVector8<Int>(8);
	public var addfloat = new GrowVector8<Float>(8);
	public var mulfloat = new GrowVector8<Float>(8);
	public var topfloat = new GrowVector8<Float>(8);
	public var topstring = new GrowVector8<String>(8);
	
	public var addint_dirty : Bool = true;
	public var computed_addint = new Vector<Int>(8);
	public var addint2_dirty : Bool = true;
	public var computed_addint2 = new Vector<Int>(8);
	public var addfloat_dirty : Bool = true;
	public var computed_addfloat = new Vector<Float>(8);
	public var mulfloat_dirty : Bool = true;
	public var computed_mulfloat = new Vector<Float>(8);
	
	public var default_addint = new Vector<Int>(8);
	public var default_addint2 = new Vector<Int>(8);
	public var default_addfloat = new Vector<Float>(8);
	public var default_mulfloat = new Vector<Float>(8);
	
	public var i : Int = 0;
	
	public function new() {
	}
	
	public inline function push() {
		addint.push(default_addint[0], default_addint[1], default_addint[2], default_addint[3],
			default_addint[4], default_addint[5], default_addint[6], default_addint[7]);
		addint2.push(default_addint2[0], default_addint2[1], default_addint2[2], default_addint2[3],
			default_addint2[4], default_addint2[5], default_addint2[6], default_addint2[7]);
		topint.push(topint.get(i,0), topint.get(i,1), topint.get(i,2), topint.get(i,3),
			topint.get(i,4), topint.get(i,5), topint.get(i,6), topint.get(i,7));
		topint2.push(topint2.get(i,0), topint2.get(i,1), topint2.get(i,2), topint2.get(i,3),
			topint2.get(i,4), topint2.get(i,5), topint2.get(i,6), topint2.get(i,7));
		addfloat.push(default_addfloat[0],default_addfloat[1],default_addfloat[2],default_addfloat[3],
			default_addfloat[4], default_addfloat[5], default_addfloat[6], default_addfloat[7]);
		mulfloat.push(default_mulfloat[0],default_mulfloat[1],default_mulfloat[2],default_mulfloat[3],
			default_mulfloat[4], default_mulfloat[5], default_mulfloat[6], default_mulfloat[7]);
		topfloat.push(topfloat.get(i,0),topfloat.get(i,1),topfloat.get(i,2),topfloat.get(i,3),
			topfloat.get(i,4), topfloat.get(i,5), topfloat.get(i,6), topfloat.get(i,7));
		topstring.push(topstring.get(i,0),topstring.get(i,1),topstring.get(i,2),topstring.get(i,3),
			topstring.get(i,4), topstring.get(i,5), topstring.get(i,6), topstring.get(i,7));
		i += 1;
	}
	
	public inline function pop() {
		if (i < 1) throw "ComputedStack: stack underflow";
		addint.l -= 1;
		addint2.l -= 1;
		topint.l -= 1;
		topint2.l -= 1;
		addfloat.l -= 1;
		mulfloat.l -= 1;
		topfloat.l -= 1;
		topstring.l -= 1;
		i -= 1;
	}
	
	public inline function setAddInt(v0, v1, v2, v3, v4, v5, v6, v7) {
		addint.set(i, v0, v1, v2, v3, v4, v5, v6, v7); addint_dirty = true;
	}
	public inline function setAddIntIdx(idx, v) {
		addint.setidx(i, idx, v); addint_dirty = true;
	}
	public inline function setAddInt2(v0, v1, v2, v3, v4, v5, v6, v7) {
		addint2.set(i, v0, v1, v2, v3, v4, v5, v6, v7); addint2_dirty = true;
	}
	public inline function setAddInt2Idx(idx, v) {
		addint2.setidx(i, idx, v); addint2_dirty = true;
	}
	public inline function setTopInt(v0, v1, v2, v3, v4, v5, v6, v7) {
		topint.set(i, v0, v1, v2, v3, v4, v5, v6, v7);
	}
	public inline function setTopIntIdx(idx, v) {
		topint.setidx(i, idx, v);
	}
	public inline function setTopInt2(v0, v1, v2, v3, v4, v5, v6, v7) {
		topint2.set(i, v0, v1, v2, v3, v4, v5, v6, v7);
	}
	public inline function setTopInt2Idx(idx, v) {
		topint2.setidx(i, idx, v);
	}
	public inline function setAddFloat(v0, v1, v2, v3, v4, v5, v6, v7) {
		addfloat.set(i, v0, v1, v2, v3, v4, v5, v6, v7); addfloat_dirty = true;
	}
	public inline function setAddFloatIdx(idx, v) {
		addfloat.setidx(i, idx, v); addfloat_dirty = true;
	}
	public inline function setMulFloat(v0, v1, v2, v3, v4, v5, v6, v7) {
		mulfloat.set(i, v0, v1, v2, v3, v4, v5, v6, v7); mulfloat_dirty = true;
	}
	public inline function setMulFloatIdx(idx, v) {
		mulfloat.setidx(i, idx, v); mulfloat_dirty = true;
	}
	public inline function setTopFloat(v0, v1, v2, v3, v4, v5, v6, v7) {
		topfloat.set(i, v0, v1, v2, v3, v4, v5, v6, v7);
	}
	public inline function setTopFloatIdx(idx, v) {
		topfloat.setidx(i, idx, v);
	}
	public inline function recomputeAddInt() {
		computed_addint[0] = default_addint[0];
		computed_addint[1] = default_addint[1];
		computed_addint[2] = default_addint[2];
		computed_addint[3] = default_addint[3];
		computed_addint[4] = default_addint[4];
		computed_addint[5] = default_addint[5];
		computed_addint[6] = default_addint[6];
		computed_addint[7] = default_addint[7];
		for (n in 0...i) {
			computed_addint[0] += addint.get(n, 0);
			computed_addint[1] += addint.get(n, 1);
			computed_addint[2] += addint.get(n, 2);
			computed_addint[3] += addint.get(n, 3);
			computed_addint[4] += addint.get(n, 4);
			computed_addint[5] += addint.get(n, 5);
			computed_addint[6] += addint.get(n, 6);
			computed_addint[7] += addint.get(n, 7);
		}
		addint_dirty = false;
	}
	public inline function recomputeAddInt2() {
		computed_addint2[0] = default_addint2[0];
		computed_addint2[1] = default_addint2[1];
		computed_addint2[2] = default_addint2[2];
		computed_addint2[3] = default_addint2[3];
		computed_addint2[4] = default_addint2[4];
		computed_addint2[5] = default_addint2[5];
		computed_addint2[6] = default_addint2[6];
		computed_addint2[7] = default_addint2[7];
		for (n in 0...i) {
			computed_addint2[0] += addint2.get(n, 0);
			computed_addint2[1] += addint2.get(n, 1);
			computed_addint2[2] += addint2.get(n, 2);
			computed_addint2[3] += addint2.get(n, 3);
			computed_addint2[4] += addint2.get(n, 4);
			computed_addint2[5] += addint2.get(n, 5);
			computed_addint2[6] += addint2.get(n, 6);
			computed_addint2[7] += addint2.get(n, 7);
		}
		addint2_dirty = false;
	}
	public inline function recomputeAddFloat() {
		computed_addfloat[0] = default_addfloat[0];
		computed_addfloat[1] = default_addfloat[1];
		computed_addfloat[2] = default_addfloat[2];
		computed_addfloat[3] = default_addfloat[3];
		computed_addfloat[4] = default_addfloat[4];
		computed_addfloat[5] = default_addfloat[5];
		computed_addfloat[6] = default_addfloat[6];
		computed_addfloat[7] = default_addfloat[7];
		for (n in 0...i) {
			computed_addfloat[0] += addfloat.get(n, 0);
			computed_addfloat[1] += addfloat.get(n, 1);
			computed_addfloat[2] += addfloat.get(n, 2);
			computed_addfloat[3] += addfloat.get(n, 3);
			computed_addfloat[4] += addfloat.get(n, 4);
			computed_addfloat[5] += addfloat.get(n, 5);
			computed_addfloat[6] += addfloat.get(n, 6);
			computed_addfloat[7] += addfloat.get(n, 7);
		}
		addfloat_dirty = false;
	}
	public inline function recomputeMulFloat() {
		computed_mulfloat[0] = default_mulfloat[0];
		computed_mulfloat[1] = default_mulfloat[1];
		computed_mulfloat[2] = default_mulfloat[2];
		computed_mulfloat[3] = default_mulfloat[3];
		computed_mulfloat[4] = default_mulfloat[4];
		computed_mulfloat[5] = default_mulfloat[5];
		computed_mulfloat[6] = default_mulfloat[6];
		computed_mulfloat[7] = default_mulfloat[7];
		for (n in 0...i) {
			computed_mulfloat[0] += mulfloat.get(n, 0);
			computed_mulfloat[1] += mulfloat.get(n, 1);
			computed_mulfloat[2] += mulfloat.get(n, 2);
			computed_mulfloat[3] += mulfloat.get(n, 3);
			computed_mulfloat[4] += mulfloat.get(n, 4);
			computed_mulfloat[5] += mulfloat.get(n, 5);
			computed_mulfloat[6] += mulfloat.get(n, 6);
			computed_mulfloat[7] += mulfloat.get(n, 7);
		}
		mulfloat_dirty = false;
	}
	public inline function emitAddInt(buf : GrowVector8<Int>) {
		if (addint_dirty) recomputeAddInt();
		buf.push(computed_addint[0], computed_addint[1], computed_addint[2],
			computed_addint[3], computed_addint[4], computed_addint[5],
			computed_addint[6], computed_addint[7]);		
	}
	public inline function emitAddInt2(buf : GrowVector8<Int>) {
		if (addint2_dirty) recomputeAddInt2();
		buf.push(computed_addint2[0], computed_addint2[1], computed_addint2[2],
			computed_addint2[3], computed_addint2[4], computed_addint2[5],
			computed_addint2[6], computed_addint2[7]);		
	}
	public inline function emitAddFloat(buf : GrowVector8<Float>) {
		if (addfloat_dirty) recomputeAddFloat();
		buf.push(computed_addfloat[0], computed_addfloat[1], computed_addfloat[2],
			computed_addfloat[3], computed_addfloat[4], computed_addfloat[5],
			computed_addfloat[6], computed_addfloat[7]);
	}
	public inline function emitMulFloat(buf : GrowVector8<Float>) {
		if (mulfloat_dirty) recomputeMulFloat();
		buf.push(computed_mulfloat[0], computed_mulfloat[1], computed_mulfloat[2],
			computed_mulfloat[3], computed_mulfloat[4], computed_mulfloat[5],
			computed_mulfloat[6], computed_mulfloat[7]);
	}
	public inline function topAddInt(idx) {
		return addint.get(i, idx);
	}
	public inline function topAddInt2(idx) {
		return addint2.get(i, idx);
	}
	public inline function topTopInt(idx) {
		return topint.get(i, idx);
	}
	public inline function topTopInt2(idx) {
		return topint2.get(i, idx);
	}
	public inline function topAddFloat(idx) {
		return addfloat.get(i, idx);
	}
	public inline function topMulFloat(idx) {
		return mulfloat.get(i, idx);
	}
	public inline function topTopFloat(idx) {
		return topfloat.get(i, idx);
	}
	public inline function topTopString(idx) {
		return topstring.get(i, idx);
	}
	
}
