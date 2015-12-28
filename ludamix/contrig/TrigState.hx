package ludamix.contrig;

@:enum
abstract TrigState(Int) {
	var UNKNOWN = 0;
	var OFF = -2;
	var RELEASE = -1;
	var TAP = 1;
	var HOLD = 2;
	public inline function asInt() : Int { return this; }
	public function new(i) { this = i; }
}
 
