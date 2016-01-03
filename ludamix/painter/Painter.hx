package ludamix.painter;

class Painter {
	
	public var paint : PaintState; /* program state that PaintProgram can retain between frames */
	
	public var result : DrawVector; /* list of points to return to the app this update */
	public var preview : DrawVector; /* list of points to tell the app to preview this update */
	
	public var canvas : DrawCanvas; /* canonical persistent data of the image we're working on */
	
	public var complete : Bool; /* program finished in last update */
	public var sync_canvas : Bool; /* request to sync current canvas state to application */
	
	public inline static function defaultBrushes() : Array <DrawVector> {
		return [DrawVector.fromPairs([[0, 0]], 0xFFFFFFFF), 
			DrawVector.fromPairs([[ -1, 0], [0, -1], [0, 0], [1, 0], [0, 1]], 0xFFFFFFFF),
			DrawVector.fromPairs([[ -1, -1], [ -1, 0], [ -1, 1], [0, -1], [0, 0], [1, 0], [1, -1], [0, 1], [1, 1]], 0xFFFFFFFF),
			];
	}
	
	public inline static function defaultPalette() : Array<Int> {
		return [
			0xFF000000,
			0xFFFF0000,
			0xFF00FF00,	
			0xFF0000FF,	
			0xFFFFFF00,	
			0xFF00FFFF,	
			0xFFFF00FF
		];
	}
	
	public static function pointsToSegments(p0 : Array<Array<Int>>) {
		var r0 = new Array<Array<Int>>();
		var i0 = 0;
		while (i0 < p0.length) {
			var from = p0[i0]; var to = p0[(i0 + 1) % p0.length];
			r0.push([from[0],from[1],to[0],to[1]]);
			i0 += 1;
		}
		return r0;
	}
	
	public static function pointsToSegmentsUnlooped(p0 : Array<Array<Int>>) {
		var r0 = new Array<Array<Int>>();
		var i0 = 0;
		while (i0 < p0.length - 1) {
			var from = p0[i0]; var to = p0[(i0 + 1) % p0.length];
			r0.push([from[0],from[1],to[0],to[1]]);
			i0 += 1;
		}
		return r0;
	}
	
	/* sort two points so that the top left always comes first */
	public static function leftTopRightBottom(x0 : Float, y0 : Float, x1 : Float, y1 : Float) : Array<Float> {
		var l = x0; var r = x1; if (l > x1) { l = x1; r = x0; }
		var t = y0; var b = y1; if (t > y1) { t = y1; b = y0; }
		return [l,t,r,b];
	}
	
	public static inline function distance(x : Float, y : Float) {
		return Math.sqrt((x * x) + (y * y));
	}
	public static inline function distanceSqr(x : Float, y : Float) {
		return ((x * x) + (y * y));
	}
	public static inline function ellipse(x0 : Float, x1 : Float, y0 : Float, y1 : Float) {
		var rx = Math.abs(x0 - x1);
		var ry = Math.abs(y0 - y1);
		var r = distance(rx, ry); /* radius */
		var c = 2 * Math.PI * r; /* circumference */
		
		/* draw one quad with trig, then copy so that pattern is consistent */
		var pts = new Array<Array<Int>>();
		for (i0 in 0...Math.ceil(c/4)) {
			var a = i0 / c * Math.PI * 2; /* angle in radians */
			var y = Math.round((Math.sin(a) * ry));
			var x = Math.round((Math.cos(a) * rx));
			pts.push([x, y]);
		}
		var quad = pts.length;
		for (i0 in 0...quad) { var i1 = quad - i0 - 1; pts.push([-pts[i1][0], pts[i1][1]]); }
		for (i0 in 0...quad) { var i1 = quad - i0 - 1; pts.push([-pts[i0][0], -pts[i0][1]]); }
		for (i0 in 0...quad) { var i1 = quad - i0 - 1; pts.push([pts[i1][0], -pts[i1][1]]); }
		for (t0 in pts) { t0[0] += Std.int(x0); t0[1] += Std.int(y0); }
		return pts;
	}
	
	public inline static function defaultPrograms() : Array<PaintProgram> {
		return [
			function(p0 : Painter, s0 : PaintState) { /* freehand */
				if (s0.button[0]) {
					p0.drawLine(p0.result, Std.int(p0.paint.x), Std.int(p0.paint.y), 
						Std.int(s0.x), Std.int(s0.y), p0.paint.color);
					p0.paint.x = s0.x; p0.paint.y = s0.y;
				}
				return !s0.button[0];
			},
			function(p0 : Painter, s0 : PaintState) : Bool { /* marching squares with hole detect */
				if (!s0.button[0]) {
					var sx = Std.int(s0.x); var sy = Std.int(s0.y);
					// flood original
					var pass1 = p0.canvas.floodMark(sx, sy);
					var shape_is_exterior = p0.canvas.isExterior(sx, sy);
					var shapeidx = pass1.canvas.getFirstSeed(1);
					// get islands
					var pass2 = pass1.canvas.getIslands();
					// detect the top-left of each island, ignoring the exterior
					var island_tl = new Array<Int>();
					for (island in pass2.paints) {
						var seed = island.getColor(0);
						island_tl.push(pass2.canvas.getFirstSeed(seed));
					}
					
					var island_tl_2 : Array<Int> = // remove the exterior shape(s)
						[for (n in island_tl) if (!p0.canvas.isExterior(p0.canvas.xIdx(n),p0.canvas.yIdx(n))) n];
					if (shape_is_exterior) // oops, add the shape again
					{
						island_tl_2.push(shapeidx);
					}
					
					// marching squares per island
					for (i0 in island_tl_2) {
						var ms = pass2.canvas.marchingSquares(p0.canvas.xIdx(i0), p0.canvas.yIdx(i0));
						var msf = [for (n in ms) [n[0] + 0., n[1] + 0.]]; /* int->float */
						msf = ramerDouglasPeucker(msf, 0.5); /* simplify vector */
						ms = [for (n in msf) [Std.int(n[0]), Std.int(n[1])]]; /* float->int */
						for (c0 in pointsToSegmentsUnlooped(ms)) {
							p0.drawLine(p0.result, c0[0], c0[1], c0[2], c0[3], p0.paint.color);
						}
					}
				}
				return !s0.button[0];
			},
			function(p0 : Painter, s0 : PaintState) { /* islands test */
				var target : DrawVector;
				if (!s0.button[0]) {
					var islands = p0.canvas.getIslands();
					trace(islands.paints.length);
					p0.canvas.blit(islands.canvas, 0, 0);
					p0.canvas.remapMonochrome(0xF);
					p0.sync_canvas = true;
				}
				return !s0.button[0];
			},			
			function(p0 : Painter, s0 : PaintState) { /* line */
				var target : DrawVector;
				if (s0.button[0]) target = p0.preview; else target = p0.result;
				p0.preview.clear();
				p0.drawLine(target, Std.int(p0.paint.x), Std.int(p0.paint.y), 
					Std.int(s0.x), Std.int(s0.y), p0.paint.color);
				return !s0.button[0];
			},			
			function(p0 : Painter, s0 : PaintState) { /* rectangle */
				var target : DrawVector;
				if (s0.button[0]) target = p0.preview; else target = p0.result;
				var x0 = Std.int(p0.paint.x);
				var x1 = Std.int(s0.x);
				var y0 = Std.int(p0.paint.y);
				var y1 = Std.int(s0.y);
				p0.preview.clear();
				for (c0 in pointsToSegments([[x0, y0], [x0, y1], [x1, y1], [x1, y0]])) {
					p0.drawLine(target, c0[0], c0[1], c0[2], c0[3], p0.paint.color);
				}
				return !s0.button[0];
			},
			function(p0 : Painter, s0 : PaintState) { /* circle */
				var target : DrawVector;
				if (s0.button[0]) target = p0.preview; else target = p0.result;
				p0.preview.clear();
				var r = distance(s0.x - p0.paint.x, s0.y - p0.paint.y); /* unify the x/y differentials */
				for (c0 in pointsToSegments(ellipse(p0.paint.x, p0.paint.x + r, p0.paint.y, p0.paint.y + r))) {
					p0.drawLine(target, c0[0], c0[1], c0[2], c0[3], p0.paint.color);
				}
				return !s0.button[0];
			},
			function(p0 : Painter, s0 : PaintState) { /* ellipse */
				var target : DrawVector;
				if (s0.button[0]) target = p0.preview; else target = p0.result;
				p0.preview.clear();
				for (c0 in pointsToSegments(ellipse(p0.paint.x, s0.x, p0.paint.y, s0.y))) {
					p0.drawLine(target, c0[0], c0[1], c0[2], c0[3], p0.paint.color);
				}
				return !s0.button[0];
			},
			function(p0 : Painter, s0 : PaintState) : Bool { /* flood fill */
				if (!s0.button[0]) {
					p0.canvas.floodFill(Std.int(s0.x), Std.int(s0.y), p0.paint.color);
					p0.sync_canvas = true;
				}
				return !s0.button[0];
			},
			function(p0 : Painter, s0 : PaintState) : Bool { /* flood mark */
				if (!s0.button[0]) {
					p0.canvas.setPaintsColor(p0.canvas.floodMark(Std.int(s0.x), Std.int(s0.y)).paint, 0xFFFF00FF);
					p0.sync_canvas = true;
				}
				return !s0.button[0];
			},
			function(p0 : Painter, s0 : PaintState) : Bool { /* dijkstra flood */
				if (!s0.button[0]) {
					var df = p0.canvas.dijkstraFlood(Std.int(s0.x), Std.int(s0.y));
					df.canvas.remapMonochrome(0x11);
					p0.canvas.blit(df.canvas, 0, 0);
					p0.sync_canvas = true;
				}
				return !s0.button[0];
			},
			function(p0 : Painter, s0 : PaintState) : Bool { /* dijkstra path */
				var target : DrawVector;
				p0.preview.clear();
				if (s0.button[0]) {
					p0.drawLine(p0.preview, Std.int(p0.paint.x), Std.int(p0.paint.y), 
						Std.int(s0.x), Std.int(s0.y), p0.paint.color);
				} else {
					var df = p0.canvas.dijkstraFlood(Std.int(s0.x), Std.int(s0.y));
					var midx = p0.paint.x + (s0.x - p0.paint.x) / 2;
					var midy = p0.paint.y + (s0.y - p0.paint.y) / 2;
					var dp = df.canvas.dijkstraNaturalPath4(Std.int(p0.paint.x), Std.int(p0.paint.y), Std.int(midx), Std.int(midy));
					dp.stroke(p0.result, p0.paint.brush, p0.paint.color);
				}
				return !s0.button[0];
			},
			function(p0 : Painter, s0 : PaintState) : Bool { /* marching squares contour */
				if (!s0.button[0]) {
					var ms = p0.canvas.marchingSquares(Std.int(s0.x), Std.int(s0.y));
					var msf = [for (n in ms) [n[0] + 0., n[1] + 0.]]; /* int->float */
					msf = ramerDouglasPeucker(msf, 0.5); /* simplify vector */
					ms = [for (n in msf) [Std.int(n[0]), Std.int(n[1])]]; /* float->int */
					for (c0 in pointsToSegmentsUnlooped(ms)) {
						p0.drawLine(p0.result, c0[0], c0[1], c0[2], c0[3], p0.paint.color);
					}
				}
				return !s0.button[0];
			},
		];
	}
	
	/* RDP vector outline simplification */
	public static function ramerDouglasPeucker(v:Array<Array<Float>>,epsilon:Float):Array<Array<Float>> {
		var firstPoint=v[0];
		var lastPoint=v[v.length-1];
		if (v.length<3) {
			return v;
		}
		var index=-1;
		var dist=0.;
		for (i in 1...v.length-1) {
			var cDist=findPerpendicularDistance(v[i],firstPoint,lastPoint);
			if (cDist>dist) {
				dist=cDist;
				index=i;
			}
		}
		if (dist>epsilon) {
			var l1 = v.slice(0,index+1);
			var l2 = v.slice(index);
			var r1 = ramerDouglasPeucker(l1,epsilon);
			var r2 = ramerDouglasPeucker(l2,epsilon);
			var rs = r1.slice(0,r1.length-1).concat(r2);
			return rs;
		}
		else {
			return [firstPoint,lastPoint];
		}
		return null;
	}

	public static inline function findPerpendicularDistance(p:Array<Float>, p1:Array<Float>,p2:Array<Float>) {
		var result : Float;
		var slope : Float;
		var intercept : Float;
		if (p1[0]==p2[0]) {
			result=Math.abs(p[0]-p1[0]);
		}
		else {
			slope = (p2[1] - p1[1]) / (p2[0] - p1[0]);
			intercept=p1[1]-(slope*p1[0]);
			result = Math.abs(slope * p[0] - p[1] + intercept) / Math.sqrt(Math.pow(slope, 2) + 1);
		}
		return result;
	}
		
	public function new() {
		
		paint = null;
		result = new DrawVector();
		preview = new DrawVector();
		complete = false;
		sync_canvas = false;
		
	}
	
	public function drawLine(result : DrawVector, x0 : Int, y0 : Int, x1 : Int, y1 : Int, color : UInt) {
		var dist = Math.ceil(Math.max(Math.abs(x1 - x0), Math.abs(y1 - y0))); /* diagonal distance (rounded up) */
		if (dist < 1) dist = 1;
		for (i0 in 0...dist) { /* draw interpolated dots along diagonal */
			var xr = x0 + Math.round(i0 / dist * (x1 - x0));				
			var yr = y0 + Math.round(i0 / dist * (y1 - y0));
			for (v0 in 0...paint.brush.length)
				result.push(xr + paint.brush.data[v0*3], yr + paint.brush.data[v0*3 + 1], color);
		}
		/* draw last dot */
		for (v0 in 0...paint.brush.length) 
			result.push(x1 + paint.brush.data[v0*3], y1 + paint.brush.data[v0*3 + 1], color);
	}
	
	public function update(state : PaintState) : Void {
		result.clear();
		complete = false;
		sync_canvas = false;
		if (state.button[0]) {
			if (paint == null) {
				paint = state.copy();
			}
		}
		if (paint != null) {
			if (paint.program(this, state)) {
				complete = true;
				paint = null;
				preview.clear();
			}
		}
		state.clear();
	}
	
	public function copy() {
		var rp = new Painter();
		rp.canvas = canvas.copy();
		rp.paint = paint.copy();
		rp.preview = preview.copy();
		rp.result = result.copy();
		rp.complete = complete;
		rp.sync_canvas = sync_canvas;
		return rp;
	}
	
}
