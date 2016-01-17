package ludamix;

/* FSM-driven parser for DJB's Netstring format:
 * <length of data in ascii>:<data>,
 * Examples:
 * 0:,
 * 5:hello,
 **/
class NetString {
	
	public var accum : StringBuf;
	public var state : Int;
	public var len : Null<Int>;
	
	public static inline var STATE_SIZE = 0;
	public static inline var STATE_BODY = 1;
	
	public function new() {
		accum = new StringBuf();
		state = STATE_SIZE;
		len = -1;
	}
	
	public function add(chr : Int) : String {
		var COLON = ":".charCodeAt(0);
		var COMMA = ",".charCodeAt(0);
		var result : String = null;
		switch(state) {
			case STATE_SIZE:
				if (chr != COLON)
					accum.addChar(chr);
				else
				{
					len = Std.parseInt(accum.toString());
					accum = new StringBuf();
					if (len == null)
					{ // reset
						state = STATE_SIZE;
						len = -1;
					}
					else
						state = STATE_BODY;
				}
			case STATE_BODY:
				if (len == 0 && chr == COMMA) {
					len = -1;
					result = accum.toString();
					accum = new StringBuf();
					state = STATE_SIZE;
				} else if (len > 0) {
					accum.addChar(chr);
					len -= 1;
				} else { // reset
					state = STATE_SIZE;
					len = -1;
				}
		}
		return result;
	}
	
	public static function getAll(s : String) : Array<String> {
		var result = new Array<String>();
		var i = 0; 
		var ns = new NetString();
		while (i < s.length) {
			var r = ns.add(s.charCodeAt(i));
			if (r != null)
				result.push(r);
			i += 1;
		}
		return result;
	}
	
	public static function make(s : String) {
		return '${s.length}:$s,';
	}
	
	#if debug
	public static function test() {
		for (n in 0...100) {
			var rnd = "";
			for (i in 0...32) {
				rnd += String.fromCharCode(Std.int(Math.random() * 256));
			}
			if (NetString.getAll(NetString.make(rnd))[0] != rnd)
				throw "assertion failed: netstring implementation is bad: $rnd";
		}
	}
	#end
	
}

