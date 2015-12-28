package ludamix.painter;
import haxe.ds.Vector;

class VectorCanvas {
	
	public var d : Vector<Int>;
	public var w : Int;
	public var h : Int;
	
	public function new() {
	}
	
	public function init(width : Int, height : Int, v : Int) {
		this.w = width; this.h = height;
		this.d = new Vector<Int>(w * h);
		clear(v);
	}
	public function clear(v : Int) {
		for ( i0 in 0...d.length) d[i0] = v;
	}
	public function copy() {
		var r = new VectorCanvas(); 
		r.w = this.w; r.h = this.h;
		r.d = new Vector<Int>(w * h);
		Vector.blit(d, 0, r.d, 0, d.length); return r;
	}
	
	public inline function xIdx(idx : Int) { return idx % w; }
	public inline function yIdx(idx : Int) { return Std.int(idx / w); }
	public inline function getIdx(x : Int, y : Int) { return w*y + x; }
	public inline function rawget(x : Int, y : Int) { return d[w*y + x]; }
	public inline function get(x : Int, y : Int) { if (x >= 0 && x < w && y >= 0 && y < h) return d[w * y + x]; else return d[0]; }
	public inline function setIdx(idx : Int, v : Int) { d[idx] = v; }
	public inline function rawset(x : Int, y : Int, v : Int) { d[w*y + x] = v; }
	public inline function set(x : Int, y : Int, v : Int) { if (x >= 0 && x < w && y >= 0 && y < h) d[w*y + x] = v; }
	public inline function inbounds(x : Int, y : Int) { return (x >= 0 && x < w && y >= 0 && y < h); }
	
	public inline function slice(x : Int, y : Int, w : Int, h : Int) : VectorCanvas {
		if (w < 1 || h < 1) return null;
		var result = new VectorCanvas();
		result.w = w; result.h = w;
		result.d = new Vector<Int>(w * h);		
		for (i0 in 0...h) {
			for (i1 in 0...w) {
				result.set(i1, i0, get(i1 + x, i0 + y));
			}
		}
		return result;
	}
	
	public inline function blit(src : VectorCanvas, x : Int, y : Int, ?w : Int=0, ?h : Int=0) : Void {
		if (w == 0) w = src.w; if (h == 0) h = src.h;
		if (w > src.w) w = src.w; if (h > src.h) h = src.h;
		for (i0 in 0...h) {
			for (i1 in 0...w) {
				set(i1 + x, i0 + y, src.get(i1, i0));
			}
		}
	}
	
	public inline function floodFill(x : Int, y : Int, v : Int) : PaintResult {
		var queue = new Array<Int>();
		var paints = new PaintResult();
		var seed = get(x, y);
		if (seed == v) return paints;
		queue.push(getIdx(x, y));
		while (queue.length > 0) {
			var node = queue.shift();
			var y = yIdx(node); var yi = y * w;
			var wx = xIdx(node);
			var ex = wx;
			while (wx >= 0 && d[wx + yi] == seed) wx -= 1;
			while (ex < w && d[ex + yi] == seed) ex += 1;
			wx += 1;
			for (i0 in wx...ex) {
				paints.push(i0, y, v);
				set(i0, y, v);
				if (y - 1 >= 0 && d[i0 + yi - w] == seed) queue.push(getIdx(i0, y - 1));
				if (y + 1 < h && d[i0 + yi + w] == seed) queue.push(getIdx(i0, y + 1));
			}
		}
		return paints;
	}
	
	/* flood fill that returns a new canvas set to 0 (outside) and 1 (inside). Useful for filling same-color area. */
	public inline function floodMark(x : Int, y : Int) : {canvas:VectorCanvas, paint:PaintResult} {
		var queue = new Array<Int>();
		var paints = new PaintResult();
		var working = new VectorCanvas(); working.init(w, h, 0);
		var seed = get(x, y);
		queue.push(getIdx(x, y));
		while (queue.length > 0) {
			var node = queue.shift();
			var y = yIdx(node); var yi = y * w;
			var wx = xIdx(node);
			var ex = wx;
			while (wx >= 0 && d[wx + yi] == seed && working.d[wx + yi] == 0) wx -= 1;
			while (ex < w && d[ex + yi] == seed && working.d[ex + yi] == 0) ex += 1;
			wx += 1;
			for (i0 in wx...ex) {
				paints.push(i0, y, 1);
				working.set(i0, y, 1);
				if (y - 1 >= 0 && d[i0 + yi - w] == seed && working.d[i0 + yi - w] == 0) queue.push(getIdx(i0, y - 1));
				if (y + 1 < h && d[i0 + yi + w] == seed && working.d[i0 + yi + w] == 0) queue.push(getIdx(i0, y + 1));
			}
		}
		return {canvas:working, paint:paints};
	}
	
	/* version of floodMark that crosses diagonals */
	public inline function floodMark2(x : Int, y : Int) : {canvas:VectorCanvas, paint:PaintResult} {
		var queue = new Array<Int>();
		var paints = new PaintResult();
		var working = new VectorCanvas(); working.init(w, h, 0);
		var seed = get(x, y);
		queue.push(getIdx(x, y));
		while (queue.length > 0) {
			var node = queue.shift();
			var y = yIdx(node); var yi = y * w;
			var wx = xIdx(node);
			var ex = wx;
			while (wx >= 0 && d[wx + yi] == seed && working.d[wx + yi] == 0) wx -= 1;
			while (ex < w && d[ex + yi] == seed && working.d[ex + yi] == 0) ex += 1;
			wx += 1;
			for (i0 in wx...ex) {
				paints.push(i0, y, 1);
				working.set(i0, y, 1);
				var xl = i0 - 1;
				var xr = i0 + 1;
				var tl = xl + yi - w;
				var tr = xr + yi - w;
				var bl = xl + yi + w;
				var br = xr + yi + w;
				if (y - 1 >= 0 && d[i0 + yi - w] == seed && working.d[i0 + yi - w] == 0) queue.push(getIdx(i0, y - 1));
				else {
					if (y - 1 >= 0 && d[tl] == seed && working.d[tl] == 0) queue.push(getIdx(xl, y - 1));
					if (y - 1 >= 0 && d[tr] == seed && working.d[tr] == 0) queue.push(getIdx(xr, y - 1));
				}
				if (y + 1 < h && d[i0 + yi + w] == seed && working.d[i0 + yi + w] == 0) queue.push(getIdx(i0, y + 1));
				else {
					if (y + 1 < h && d[bl] == seed && working.d[bl] == 0) queue.push(getIdx(xl, y + 1));
					if (y + 1 < h && d[br] == seed && working.d[br] == 0) queue.push(getIdx(xr, y + 1));
				}
			}
		}
		return {canvas:working, paint:paints};
	}
	
	/* return a new canvas with a flood fill appropriate for Dijkstra shortest-path valuation: value 0 is the destination,
	 * adjacent values count upwards. Walls are -1, unreachable values are -2. "result" allows a canvas to be reused. 
	 * Also returns a paint result (e.g. if animation is desired)
	 * Algorithm looks for "open" area (matching seed value) rather than for "obstacles".
	 * */
	public inline function dijkstraFlood(x : Int, y : Int, ?result : VectorCanvas) : {canvas:VectorCanvas,paint:PaintResult} {
		if (result == null) { result = new VectorCanvas(); result.init(w, h, -2); }
		var queue = new Array<Int>();
		var seed = get(x, y);
		var paint = new PaintResult();
		queue.push(getIdx(x, y));
		result.set(x, y, 0);
		while (queue.length > 0) {
			var node = queue.shift();
			var v = result.d[node];
			var x = xIdx(node); var y = yIdx(node);
			paint.push(x, y, v);
			var tx = x - 1; var ty = y; var ti = getIdx(tx, ty);
			if (inbounds(tx, ty) && result.d[ti] == -2) { (d[ti] == seed) ? { result.d[ti]= v + 1; queue.push(ti); } : { result.d[ti] = -1; } }
			tx = x + 1; ty = y; ti = getIdx(tx, ty); 
			if (inbounds(tx, ty) && result.d[ti] == -2) { (d[ti] == seed) ? { result.d[ti]= v + 1; queue.push(ti); } : { result.d[ti] = -1; } }
			tx = x; ty = y - 1; ti = getIdx(tx, ty); 
			if (inbounds(tx, ty) && result.d[ti] == -2) { (d[ti] == seed) ? { result.d[ti]= v + 1; queue.push(ti); } : { result.d[ti] = -1; } }
			tx = x; ty = y + 1; ti = getIdx(tx, ty); 
			if (inbounds(tx, ty) && result.d[ti] == -2) { (d[ti] == seed) ? { result.d[ti]= v + 1; queue.push(ti); } : { result.d[ti] = -1; } }
		}
		return {canvas:result, paint:paint};
	}

	/* given a canvas generated by(or similar to) dijsktraFlood(), produce a PaintResult describing the nodes taken to
	 * reach the destination at value 0. Steps in the four cardinal directions. Does not wrap around. */
	public inline function dijkstraPath4(x0 : Int, y0 : Int) : PaintResult {
		var x = x0;
		var y = y0;
		var result = new PaintResult();
		var v = get(x0, y0);
		if (v == -1 || v == -2) return result;
		while (v != 0) {
			var tx0 = x - 1; var ty0 = y; var tv0 = get(tx0, ty0); if (!inbounds(tx0, ty0) || tv0 == -1 || tv0 == -2) tv0 = v + 1;
			var tx1 = x + 1; var ty1 = y; var tv1 = get(tx1, ty1); if (!inbounds(tx1, ty1) || tv1 == -1 || tv1 == -2) tv1 = v + 1;
			var tx2 = x; var ty2 = y - 1; var tv2 = get(tx2, ty2); if (!inbounds(tx2, ty2) || tv2 == -1 || tv2 == -2) tv2 = v + 1;
			var tx3 = x; var ty3 = y + 1; var tv3 = get(tx3, ty3); if (!inbounds(tx3, ty3) || tv3 == -1 || tv3 == -2) tv3 = v + 1;
			if (tv0 < v && tv0 <= tv1 && tv0 <= tv2 && tv0 <= tv3) { result.push(x,y,v); x = tx0; y = ty0; v = tv0; }
			else if (tv1 < v && tv1 <= tv0 && tv1 <= tv2 && tv1 <= tv3) { result.push(x,y,v); x = tx1; y = ty1; v = tv1; }
			else if (tv2 < v && tv2 <= tv1 && tv2 <= tv0 && tv2 <= tv3) { result.push(x,y,v); x = tx2; y = ty2; v = tv2; }
			else if (tv3 < v && tv3 <= tv1 && tv3 <= tv2 && tv3 <= tv0) { result.push(x, y, v); x = tx3; y = ty3; v = tv3; }
			else {break;}
		}
		result.push(x, y, v); return result;
	}
	
	/* as dijkstraPath4, but with a distance heuristic against cx/cy applied to bias the path shape */
	public inline function dijkstraNaturalPath4(x0 : Int, y0 : Int, cx : Int, cy : Int) : PaintResult {
		var x = x0;
		var y = y0;
		var result = new PaintResult();
		var v = get(x0, y0);
		var pref = [[0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0]];
		if (v == -1 || v == -2) return result;
		var tx = 0; var ty = 0; var tv = 0;
		while (v != 0) {
			tx = x - 1; ty = y; tv = get(tx, ty); if (!inbounds(tx, ty) || tv == -1 || tv == -2) tv = v + 1;
			pref[0][0] = tx; pref[0][1] = ty; pref[0][2] = Std.int(Painter.distanceSqr(tx - cx, ty - cy)); pref[0][3] = tv;
			tx = x + 1; ty = y; tv = get(tx, ty); if (!inbounds(tx, ty) || tv == -1 || tv == -2) tv = v + 1;
			pref[1][0] = tx; pref[1][1] = ty; pref[1][2] = Std.int(Painter.distanceSqr(tx - cx, ty - cy)); pref[1][3] = tv;
			tx = x; ty = y - 1; tv = get(tx, ty); if (!inbounds(tx, ty) || tv == -1 || tv == -2) tv = v + 1;
			pref[2][0] = tx; pref[2][1] = ty; pref[2][2] = Std.int(Painter.distanceSqr(tx - cx, ty - cy)); pref[2][3] = tv;
			tx = x; ty = y + 1; tv = get(tx, ty); if (!inbounds(tx, ty) || tv == -1 || tv == -2) tv = v + 1;
			pref[3][0] = tx; pref[3][1] = ty; pref[3][2] = Std.int(Painter.distanceSqr(tx - cx, ty - cy)); pref[3][3] = tv;
			pref.sort(function(a, b) { 
				if (a[3] < b[3]) { return -1; } 
				else if (a[3] > b[3]) { return 1; }
				else { return a[2] - b[2]; }
			} );
			tv = pref[0][3]; tx = pref[0][0]; ty = pref[0][1];
			if (tv < v) { result.push(x,y,v); x = tx; y = ty; v = tv; }
			else {break;}
		}
		result.push(x, y, v); return result;
	}
	
	/* return the contour of the area matching the seed point. Note that the result is visually offset because it represents
	 * a position in between the original pixels: subtract 0.5 for the "most exact" representation. */
	public function marchingSquares(xs : Int, ys : Int):Array<Array<Int>> {
		var contour = [];
		var seed = get(xs, ys);
		// move the starting point as far top-left as possible
		while (xs > 0 && get(xs - 1, ys) == seed) xs -= 1;
		while (ys > 0 && get(xs, ys - 1) == seed) ys -= 1;
		// pX and pY are the coordinates of the starting point;
		var pX = xs;
		var pY = ys;
		// stepX and stepY can be -1, 0 or 1 and represent the step in pixels to reach
		// next contour point
		// we also need to save the previous step, that's why we use prevX and prevY
		var stepX:Int=0; var stepY:Int=0; var prevX:Int=0; var prevY:Int=0;
		while (true) {
			// the core of the script is getting the 2x2 square value of each pixel
			var squareValue = getSquareValue(pX, pY, seed);
			if (squareValue == 0) throw "whoa I'm lost out in a blank area";
			switch (squareValue) {
					/* going UP with these cases:
					
					+---+---+   +---+---+   +---+---+
					| 1 |   |   | 1 |   |   | 1 |   |
					+---+---+   +---+---+   +---+---+
					|   |   |   | 4 |   |   | 4 | 8 |
					+---+---+   +---+---+  +---+---+
					
					*/
				case 1,5,13 :
					stepX=0;
					stepY=-1;
					/* going DOWN with these cases:
					
					+---+---+   +---+---+   +---+---+
					|   |   |   |   | 2 |   | 1 | 2 |
					+---+---+   +---+---+   +---+---+
					|   | 8 |   |   | 8 |   |   | 8 |
					+---+---+   +---+---+  +---+---+
					
					*/
				case 8,10,11 :
					stepX=0;
					stepY=1;
					/* going LEFT with these cases:
					
					+---+---+   +---+---+   +---+---+
					|   |   |   |   |   |   |   | 2 |
					+---+---+   +---+---+   +---+---+
					| 4 |   |   | 4 | 8 |   | 4 | 8 |
					+---+---+   +---+---+  +---+---+
					
					*/
				case 4,12,14 :
					stepX=-1;
					stepY=0;
					/* going RIGHT with these cases:
					
					+---+---+   +---+---+   +---+---+
					|   | 2 |   | 1 | 2 |   | 1 | 2 |
					+---+---+   +---+---+   +---+---+
					|   |   |   |   |   |   | 4 |   |
					+---+---+   +---+---+  +---+---+
					
					*/
				case 2,3,7 :
					stepX=1;
					stepY=0;
				case 6 :
					/* special saddle point case 1:
					
					+---+---+ 
					|   | 2 | 
					+---+---+
					| 4 |   |
					+---+---+
					
					going LEFT if coming from UP
					else going RIGHT 
					
					*/
					if (prevX==0&&prevY==-1) {
						stepX=-1;
						stepY=0;
					}
					else {
						stepX=1;
						stepY=0;
					}
				case 9 :
					/* special saddle point case 2:
					
					+---+---+ 
					| 1 |   | 
					+---+---+
					|   | 8 |
					+---+---+
					
					going UP if coming from RIGHT
					else going DOWN 
					
					*/
					if (prevX==1&&prevY==0) {
						stepX=0;
						stepY=-1;
					}
					else {
						stepX=0;
						stepY=1;
					}
			}
			// moving onto next point
			pX+=stepX;
			pY+=stepY;
			// saving contour point
			contour.push([pX, pY, squareValue]);
			prevX = stepX;
			prevY = stepY;
			// if we returned to the first point visited, the loop has finished;
			if (pX == xs && pY == ys) return contour;	
		}
	}
 
	/* get the first matching index of this seed, running left-right, top-bottom */
	public function getFirstSeed(seed : Int):Int {
		for (i0 in 0...d.length) {
			if (d[i0] == seed) { return i0; }
		}
		return -1;
	}
	
	/* get the first non-matching index of this seed */
	public function getFirstNotSeed(seed : Int):Int {
		for (i0 in 0...d.length) {
			if (d[i0] != seed) { return i0; }
		}
		return -1;
	}
	
	/* walk a spiral pattern until the first point (not, if not is true) matching the seed is found. 
	 * Useful for getting the exterior of an object. */
	public function getInwardSpiralSeed(seed : Int, not : Bool) {
		/* this is a very simple implementation that just uses a second canvas. */
		var marking = new VectorCanvas(); marking.init(w, h, 0);
		var x = 0;
		var y = 0;
		var step = 0;
		if (get(x, y) != seed) return getIdx(x, y);
		while (marking.get(x, y) == 0 && step >= 0) {
			marking.set(x, y, 1);
			if (x + 1 < w && marking.get(x + 1, y) == 0) { x += 1; }			
			else if (y + 1 < h && marking.get(x, y + 1) == 0) { y += 1; }			
			else if (x - 1 >= 0 && marking.get(x - 1, y) == 0) { x -= 1; } 			
			else if (y - 1 >= 0 && marking.get(x, y - 1) == 0) { y -= 1; }
			if (not && (get(x, y) != seed)) return getIdx(x, y);
			else if (!not && (get(x, y) == seed)) return getIdx(x, y);
		}
		return -1;
	}
	
	/* find the rectangle inside the defined area that is not like the seed point */
	public function getInnerRectBounds(rX:Int, rY:Int, rW:Int, rH:Int, seed:Int) {
		var lX = rX+rW; var lY = rY+rH;
		var hX = rX; var hY = rY;
		var bound = false;
		for (y0 in 0...rH) {
			for (x0 in 0...rW) {
				var x1 = x0 + rX;
				var y1 = y0 + rY;
				if (get(x1, y1) != seed) {
					lX = lX < x1 ? lX : x1;
					hX = hX > x1 ? hX : x1;
					lY = lY < y1 ? lY : y1;
					hY = hY > y1 ? hY : y1;
					bound = true;
				}
			}
		}
		if (bound)
			return [lX, lY, hX - lX, hY - lY];
		else
			return [rX, rY, rW, rH];
	}

	public function getSquareValue(pX:Int,pY:Int,seed:Int):Int {
		/*
		
		checking the 2x2 pixel grid, assigning these values to each pixel, if equal to seed value
		
		+---+---+
		| 1 | 2 |
		+---+---+
		| 4 | 8 | <- current pixel (pX,pY)
		+---+---+
		
		*/
		var squareValue=0;
		// checking upper left pixel
		if (inbounds(pX-1,pY-1) && rawget(pX-1,pY-1)==seed) {
			squareValue+=1;
		}
		// checking upper pixel
		if (inbounds(pX,pY-1) && rawget(pX,pY-1)==seed) {
			squareValue+=2;
		}
		// checking left pixel
		if (inbounds(pX-1,pY) && rawget(pX-1,pY)==seed) {
			squareValue+=4;
		}
		// checking the pixel itself
		if (inbounds(pX,pY) && rawget(pX,pY)==seed) {
			squareValue+=8;
		}
		return squareValue;
	}	
	
	/* given a canvas of positively indexed colors, output a new canvas where each island of connected color is marked,
	 * starting from 1 at top left and counting upwards(2, 3...). */
	public function getIslands() {
		var result = new VectorCanvas(); result.init(w, h, 0);
		var isle = 1;
		var paints = new Array<PaintResult>();
		for (i0 in 0...result.d.length) {
			if (result.d[i0] == 0) {
				var paint = floodMark(xIdx(i0), yIdx(i0)).paint;
				paint.fillColor(isle);
				result.setPaints(paint);
				paints.push(paint);
				isle += 1;
			}
		}
		return {canvas:result,paints:paints};
	}
	
	/* getIslands using diagonal floodMark */
	public function getIslands2() {
		var result = new VectorCanvas(); result.init(w, h, 0);
		var isle = 1;
		var paints = new Array<PaintResult>();
		for (i0 in 0...result.d.length) {
			if (result.d[i0] == 0) {
				var paint = floodMark2(xIdx(i0), yIdx(i0)).paint;
				paint.fillColor(isle);
				result.setPaints(paint);
				paints.push(paint);
				isle += 1;
			}
		}
		return {canvas:result,paints:paints};
	}
	
	/* Detect whether this contiguous shape touches the edge of the canvas.
	   if it's at canvas edge, it's exterior. */
	public function isExterior(x0 : Int, y0 : Int) {
		var mark = floodMark(x0, y0);
		for (i0 in 0...mark.paint.length) {
			var x = mark.paint.getX(i0);
			var y = mark.paint.getY(i0);
			if (x == 0 || x == w - 1 || y == 0 || y == h - 1) return true;
		}
		return false;
	}
	
	/* remap the colors from 0, 1, 2, 3... to 
	 * a visible monochrome spectrum at the given interval
	 * */
	public function remapMonochrome(mult : Int) {
		for (i0 in 0...d.length) {
			var m = Std.int(d[i0] * mult) & 0xFF;
			d[i0] = 0xFF000000 | m | (m << 8) | (m << 16);
		}
	}
	
	/* flip the sign of the colors. */
	public function remapNegate() {
		for (i0 in 0...d.length) {
			d[i0] = -d[i0];
		}
	}
	
	/* return a map of (color, # of instances). */
	public function colorCount() {
		var result = new Map<Int,Int>();
		for (c in d) {
			if (result.exists(c)) result.set(c, result.get(c) + 1);
			else result.set(c, 1);
		}
		return result;
	}
	
	/* set the data from a PaintResult */
	public function setPaints(pr : PaintResult) {
		for (i0 in 0...pr.length) {
			var i = i0 * 3;
			var x = pr.data[i];
			var y = pr.data[i + 1];
			var c = pr.data[i + 2];
			set(x, y, c);
		}
	}
	
	public function setPaintsColor(pr : PaintResult, c : Int) {
		for (i0 in 0...pr.length) {
			var i = i0 * 3;
			var x = pr.data[i];
			var y = pr.data[i + 1];
			set(x, y, c);
		}
	}
	
}