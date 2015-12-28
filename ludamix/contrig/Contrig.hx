package ludamix.contrig;

class Contrig {
	
	/* Gameplay-side controller abstraction. */
	
	public var digital : Map<String, TrigState>;
	public var analog : Map<String, Array<Int>>;	
	
	static inline var INT_MAX : Int = 0x7FFFFFFF;
	static inline var INT_MIN : Int = 0x80000001;
	
	public function new() {
		digital = new Map();
		analog = new Map();
	}
	
	public inline function addDigital(name : String) {
		digital.set(name, TrigState.OFF);
	}
	
	public inline function addAnalog(name : String, axes : Int) {
		analog.set(name, [for (n in 0...axes) 0]);
	}
	
	public inline function trigState(name : String) : TrigState {
		return digital.get(name);
	}
	
	public inline function isTap(name : String) : Bool {
		return digital.get(name).asInt() == TrigState.TAP.asInt();
	}
	
	public inline function isRelease(name : String) : Bool {
		return digital.get(name).asInt() == TrigState.RELEASE.asInt();
	}
	
	public inline function isDown(name : String) : Bool {
		return digital.get(name).asInt() >= TrigState.TAP.asInt();
	}
	
	public inline function isUp(name : String) : Bool {
		return digital.get(name).asInt() <= TrigState.RELEASE.asInt();
	}
	
	public inline function isHold(name : String) : Bool {
		return digital.get(name).asInt() >= TrigState.HOLD.asInt();
	}
	
	public inline function isOff(name : String) : Bool {
		return digital.get(name).asInt() <= TrigState.OFF.asInt();
	}
	
	/* returns the number of frames the button has been down.
	 * returns 0 at moment of tap
	 * returns -1 if not pressed. */
	public inline function downLength(name : String) {
		var v = digital.get(name).asInt();
		if (v >= TrigState.TAP.asInt())
			return v - TrigState.TAP.asInt();
		else
			return -1;
	}
	
	/* returns the number of frames the button has been up.
	 * returns 0 at moment of release
	 * returns -1 if not pressed. */
	public inline function upLength(name : String) {
		var v = digital.get(name).asInt();
		if (v <= TrigState.RELEASE.asInt())
			return TrigState.RELEASE.asInt() - v;
		else
			return -1;
	}
	
	public inline function pump() {
		for (k in digital.keys()) {
			if (isDown(k)) {
				var v = digital.get(k).asInt();
				if (v < INT_MAX)
					digital.set(k, new TrigState(v + 1));
			}
			if (isUp(k)) {
				var v = digital.get(k).asInt();
				if (v > INT_MIN)
					digital.set(k, new TrigState(v - 1));
			}
		}
	}
	
	public inline function setDown(name : String) {
		digital.set(name, TrigState.TAP);
	}
	
	public inline function setUp(name : String) {
		digital.set(name, TrigState.RELEASE);
	}
	
	public inline function setAnalog(name : String, axis : Int, value : Int) {
		analog.get(name)[axis] = value;
	}
	
	public inline function getAnalog(name : String, axis : Int, value : Int) {
		return analog.get(name)[axis];
	}
	
}

