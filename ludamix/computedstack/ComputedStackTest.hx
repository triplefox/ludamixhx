package ludamix.computedstack;
import haxe.ds.Vector;
import ludamix.computedstack.*;
import ludamix.GrowVector1;

class ComputedStackTest {
	
	public static function run() {
		
		trace(csaf1());
		trace(csai1());
		trace(csmf1());
		trace(csaf2());
		trace(csai2());
		trace(csmf2());
		trace(csaf3());
		trace(csai3());
		trace(csmf3());
		trace(csaf4());
		trace(csai4());
		trace(csmf4());
		trace(csaf8());
		trace(csai8());
		trace(csmf8());
		
	}
	
	public static function csaf1() {
		
		var result = new GrowVector1<Float>(1);
		var cs = new ComputedStackAddFloat1();
		cs.default_data = 100.;
		cs.push();
		cs.set(200.);
		cs.push();
		cs.emit(result);
		cs.push();
		cs.set(50.);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		return [result.get(0) == 300., cs.i == 0, result.get(1) == 350., result.get(2) == 200.];
		
	}
	
	public static function csai1() {
		
		var result = new GrowVector1<Int>(1);
		var cs = new ComputedStackAddInt1();
		cs.default_data = 100;
		cs.push();
		cs.set(200);
		cs.push();
		cs.emit(result);
		cs.push();
		cs.set(50);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		return [result.get(0) == 300, cs.i == 0, result.get(1) == 350, result.get(2) == 200];
		
	}
	
	public static function csmf1() {
		
		var result = new GrowVector1<Float>(1);
		var cs = new ComputedStackMulFloat1();
		cs.default_data = 1.;
		cs.push();
		cs.push();
		cs.set(2.);
		cs.emit(result);
		cs.push();
		cs.set(2.);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		return [result.get(0) == 2., result.get(1) == 4., cs.i == 0, result.get(2) == 1.];
		
	}
	
	public static function csaf2() {
		
		var ss = 2;
		var result = new GrowVector2<Float>(1);
		var cs = new ComputedStackAddFloat2();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 100.+i]);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 200. + i);
		cs.push();
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 50. + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == 200. + n + 100. + n);
			test.push(cs.i == 0);
			test.push(result.get(1,n) == 200. + n + 100. + n + 50. + n);
			test.push(result.get(2,n) == 200. + n);
		}
		return test;
		
	}
	
	public static function csai2() {
		
		var ss = 2;
		var result = new GrowVector2<Int>(1);
		var cs = new ComputedStackAddInt2();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 100+i]);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 200 + i);
		cs.push();
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 50 + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == 200 + n + 100 + n);
			test.push(cs.i == 0);
			test.push(result.get(1,n) == 200 + n + 100 + n + 50 + n);
			test.push(result.get(2,n) == 200 + n);
		}
		return test;
		
	}
	
	public static function csmf2() {
		
		var ss = 2;		
		var result = new GrowVector2<Float>(2);
		var cs = new ComputedStackMulFloat2();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 1. + i]);
		cs.push();
		cs.push();
		for (i in 0...ss) cs.setidx(i, 2. + i);
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 2. + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == (1. + n) * (2. + n));
			test.push(result.get(1,n) == (1. + n) * (2. + n) * (2. + n));
			test.push(cs.i == 0);
			test.push(result.get(2,n) == (1. + n));
		}
		return test;
		
	}
	
	public static function csaf3() {
		
		var ss = 3;
		var result = new GrowVector3<Float>(1);
		var cs = new ComputedStackAddFloat3();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 100.+i]);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 200. + i);
		cs.push();
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 50. + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == 200. + n + 100. + n);
			test.push(cs.i == 0);
			test.push(result.get(1,n) == 200. + n + 100. + n + 50. + n);
			test.push(result.get(2,n) == 200. + n);
		}
		return test;
		
	}
	
	public static function csai3() {
		
		var ss = 3;
		var result = new GrowVector3<Int>(1);
		var cs = new ComputedStackAddInt3();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 100+i]);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 200 + i);
		cs.push();
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 50 + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == 200 + n + 100 + n);
			test.push(cs.i == 0);
			test.push(result.get(1,n) == 200 + n + 100 + n + 50 + n);
			test.push(result.get(2,n) == 200 + n);
		}
		return test;
		
	}
	
	public static function csmf3() {
		
		var ss = 2;		
		var result = new GrowVector3<Float>(2);
		var cs = new ComputedStackMulFloat3();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 1. + i]);
		cs.push();
		cs.push();
		for (i in 0...ss) cs.setidx(i, 2. + i);
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 2. + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == (1. + n) * (2. + n));
			test.push(result.get(1,n) == (1. + n) * (2. + n) * (2. + n));
			test.push(cs.i == 0);
			test.push(result.get(2,n) == (1. + n));
		}
		return test;
		
	}
	
	public static function csaf4() {
		
		var ss = 4;
		var result = new GrowVector4<Float>(1);
		var cs = new ComputedStackAddFloat4();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 100.+i]);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 200. + i);
		cs.push();
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 50. + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == 200. + n + 100. + n);
			test.push(cs.i == 0);
			test.push(result.get(1,n) == 200. + n + 100. + n + 50. + n);
			test.push(result.get(2,n) == 200. + n);
		}
		return test;
		
	}
	
	public static function csai4() {
		
		var ss = 4;
		var result = new GrowVector4<Int>(1);
		var cs = new ComputedStackAddInt4();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 100+i]);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 200 + i);
		cs.push();
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 50 + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == 200 + n + 100 + n);
			test.push(cs.i == 0);
			test.push(result.get(1,n) == 200 + n + 100 + n + 50 + n);
			test.push(result.get(2,n) == 200 + n);
		}
		return test;
		
	}
	
	public static function csmf4() {
		
		var ss = 2;		
		var result = new GrowVector4<Float>(2);
		var cs = new ComputedStackMulFloat4();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 1. + i]);
		cs.push();
		cs.push();
		for (i in 0...ss) cs.setidx(i, 2. + i);
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 2. + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == (1. + n) * (2. + n));
			test.push(result.get(1,n) == (1. + n) * (2. + n) * (2. + n));
			test.push(cs.i == 0);
			test.push(result.get(2,n) == (1. + n));
		}
		return test;
		
	}
	
	public static function csaf8() {
		
		var ss = 8;
		var result = new GrowVector8<Float>(1);
		var cs = new ComputedStackAddFloat8();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 100.+i]);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 200. + i);
		cs.push();
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 50. + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == 200. + n + 100. + n);
			test.push(cs.i == 0);
			test.push(result.get(1,n) == 200. + n + 100. + n + 50. + n);
			test.push(result.get(2,n) == 200. + n);
		}
		return test;
		
	}
	
	public static function csai8() {
		
		var ss = 8;
		var result = new GrowVector8<Int>(1);
		var cs = new ComputedStackAddInt8();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 100+i]);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 200 + i);
		cs.push();
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 50 + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == 200 + n + 100 + n);
			test.push(cs.i == 0);
			test.push(result.get(1,n) == 200 + n + 100 + n + 50 + n);
			test.push(result.get(2,n) == 200 + n);
		}
		return test;
		
	}
	
	public static function csmf8() {
		
		var ss = 8;
		var result = new GrowVector8<Float>(2);
		var cs = new ComputedStackMulFloat8();
		cs.default_data = Vector.fromArrayCopy([for (i in 0...ss) 1. + i]);
		cs.push();
		cs.push();
		for (i in 0...ss) cs.setidx(i, 2. + i);
		cs.emit(result);
		cs.push();
		for (i in 0...ss) cs.setidx(i, 2. + i);
		cs.emit(result);
		cs.pop();
		cs.pop();
		cs.emit(result);
		var test = new Array<Bool>();
		for (n in 0...ss) {
			test.push(result.get(0,n) == (1. + n) * (2. + n));
			test.push(result.get(1,n) == (1. + n) * (2. + n) * (2. + n));
			test.push(cs.i == 0);
			test.push(result.get(2,n) == (1. + n));
		}
		return test;
		
	}
	
}