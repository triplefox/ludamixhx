package ludamix;

import ludamix.CircularVector1;
import ludamix.CircularVector2;

class CircularVectorTest {
	
	public static function run() {
		for (startv in 0...4) {
			var test = new Array<Bool>();
			var cv = new CircularVector1<Int>(2);
			cv.setStartIndex(startv);
			test.push(cv.endIndex() == (startv) % cv.indexCapacity());
			cv.push(0);
			test.push(cv.endIndex() == (startv + 1) % cv.indexCapacity());
			cv.push(1);
			test.push(cv.endIndex() == (startv) % cv.indexCapacity());
			test.push(cv.full());
			test.push(cv.startIndex() == (startv) % cv.indexCapacity());
			test.push(cv.shift() == 0);
			test.push(cv.startIndex() == (startv + 1) % cv.indexCapacity());
			test.push(cv.shift() == 1);
			test.push(cv.startIndex() == (startv + 2) % cv.indexCapacity());
			test.push(cv.startIndex() == (startv) % cv.indexCapacity());
			test.push(cv.empty());
			trace('CircularVector1: start $startv: $test');
			for (n in test) if (n == false) throw "test failed"; 
		}
		for (startv in 0...4) {
			var test = new Array<Bool>();
			var cv = new CircularVector2<Int>(2);
			cv.setStartIndex(startv);
			test.push(cv.endIndex() == (startv) % cv.indexCapacity());
			cv.push(0,1);
			test.push(cv.endIndex() == (startv + 1) % cv.indexCapacity());
			cv.push(2,3);
			test.push(cv.endIndex() == (startv) % cv.indexCapacity());
			test.push(cv.full());
			test.push(cv.startIndex() == (startv) % cv.indexCapacity());
			cv.shift(); test.push(cv.r0 == 0 && cv.r1 == 1);
			test.push(cv.startIndex() == (startv + 1) % cv.indexCapacity());
			cv.shift(); test.push(cv.r0 == 2 && cv.r1 == 3);
			test.push(cv.startIndex() == (startv + 2) % cv.indexCapacity());
			test.push(cv.startIndex() == (startv) % cv.indexCapacity());
			test.push(cv.empty());
			trace('CircularVector2: start $startv: $test');
			for (n in test) if (n == false) throw "test failed"; 
		}
	}
	
}

