package ludamix.painter;

class PaintState {
	
	/* coordinates */
	public var x : Float;
	public var y : Float;
	
	public var brush : DrawVector; /* brush data to stroke with */
	public var program : PaintProgram; /* tool program to run */
	public var color : Int; /* which color to draw with(if using a single color) */
	public var button : Array<Bool>; /* tool button state */
	public var tooldata : Dynamic; /* for holding custom state in a tool. Implement copy() to auto-copy it. */
	
	public function new() { }

	public function clear() {
		x = 0; y = 0; brush = null; program = null; color = 0; button = [for (i0 in 0...128) false]; tooldata = null; 
	}
	
	/* copy everything */
	public function copy() : PaintState {
		var ps = new PaintState();
		ps.x = x; ps.y = y; 
		ps.brush = brush.copy();
		ps.program = program;
		ps.color = color;
		ps.button = button.copy();
		if (tooldata != null && Reflect.hasField(tooldata, "copy")) ps.tooldata = tooldata.copy();
		return ps;
	}
	
}

