package ludamix;
import haxe.Serializer;
import haxe.Unserializer;
import ludamix.QuantizedRect;
import haxe.ds.Vector;

class Grid
{

	public var flat : Vector<Int>;
	public var width : Int;
	public var height : Int;
	
	public var default_tile : Int;
	
	public var tile_width : Int;
	public var tile_height : Int;
	
	public var x : Int;
	public var y : Int;
	
	// conversion functions
	// types are:
	// i - one integer indexing array
	// g - two integers indexing grid column and row
	// u - two integers at unit scale (each tile is tile_width by tile_height)
	// t - tile value
	
	// U - unsafe(uses flat array and doesn't bounds-check before conversion)
	
	// when converting to two-int values, the result is returned in this.x/this.y
	
	/**
	 * Convert 2D index to 1D index
	 */
	public inline function gi(xg : Int, yg : Int) : Int
	{ return yg * width + xg; }
	
	/**
	 * Convert 1D index to 2D index
	 */
	public inline function ig(idx:Int)
	{ this.x = idx % width; this.y = Std.int((idx - x) / width); }
	
	/**
	 * Convert 1D index to unit position
	 */
	public inline function iu(idx:Int)
	{ ig(idx); this.x = this.x * tile_width; this.y = this.y * tile_height; }
	
	/**
	 * Convert 2D unit position to 2D index
	 */
	public inline function ug(x:Int, y:Int)
	{ this.x = Std.int(x / tile_width); this.y = Std.int(y / tile_height); }
	
	/**
	 * Convert 2D index to 2D unit position
	 */
	public inline function gu(x:Int, y:Int)
	{ this.x = x * tile_width; this.y = y * tile_height; }
	
	/**
	 * Convert 2D unit position to 1D index
	 */
	public inline function ui(x:Int, y:Int) : Int
	{ return gi(Std.int(x / tile_width), Std.int(y / tile_height)); }
	
	
	
	/**
	 * Convert 1D index to value at position (unsafe)
	 */
	public inline function itU(idx:Int)
	{ return flat[idx]; }
	
	/**
	 * Convert 1D index to value at position (returns default_tile if out of bounds)
	 */
	public inline function it(idx:Int) : Int
	{ if (idx >= 0 && idx < flat.length) return itU(idx); else return default_tile; }
	
	/**
	 * Convert 2D index to value at position (unsafe)
	 */
	public inline function gtU(x:Int, y:Int) : Int
	{ return itU(gi(x,y)); }
	
	/**
	 * Convert 2D index to value at position (returns default_tile if out of bounds)
	 */
	public inline function gt(x:Int, y:Int) : Int
	{ if (x >= 0 && x < width && y>=0 && y<height) return gtU(x, y); else return default_tile;  }

	/**
	 * Convert 2D pixel value to value at position (unsafe)
	 */
	public inline function utU(x:Int, y:Int) : Int
	{ return itU(ui(x, y)); }
	
	/**
	 * Convert 2D pixel value to value at position (returns default_tile if out of bounds)
	 */
	public inline function ut(x:Int, y:Int) : Int
	{ return it(ui(x, y)); }
	
	
	
	public function new(width : Int, height : Int, tile_width : Int, tile_height : Int, default_tile : Int,
		?populate : Array<Int> = null)
	{
		this.tile_width = tile_width;
		this.tile_height = tile_height;
		
		this.width = width;
		this.height = height;
		
		this.default_tile = default_tile;
		
		var ct = 0;
		if (populate == null)
		{
			flat = Vector.fromArrayCopy([for (ct in 0...height*width) default_tile]);
		}
		else
		{
			flat = Vector.fromArrayCopy(populate);
		}
		
	}
	
	public inline function rotW(x) { return x >= 0 ? x % width : x + width; }	
	public inline function rotH(y) { return y >= 0 ? y % height : y + height; }

	// shift functions do not wrap around.
	// if you want this, store the last row or column shifted and write it at the front.
	
	public function shiftL()
	{
		for (icol in 0...width)
		{
			var x = (width-1) - icol;
			for (y in 0...height)
			{
				setg(rotW(x-1), y, gt(x, y));
			}
		}		
	}
	
	public function shiftR()
	{
		for (x in 0...width)
		{
			for (y in 0...height)
			{
				setg(rotW(x+1), y, gt(x, y));
			}
		}		
	}
	
	public function shiftU()
	{
		for (y in 0...height)
		{
			for (x in 0...width)
			{
				setg(x, rotH(y+1), gt(x, y));
			}
		}		
	}
	
	public function shiftD()
	{
		for (irow in 0...height)
		{
			var y = (height-1) - irow;
			for (x in 0...width)
			{
				setg(x, rotH(y - 1), gt(x, y));
			}
		}		
	}
	
	public inline function tileInBounds(x : Int, y : Int)
	{
		return (x >= 0 && y >= 0 && x < width && y < height);
	}
	
	public inline function unitInBounds(x : Int, y : Int)
	{
		return (x >= 0 && y >= 0 && x < width*tile_width && y < height*tile_height);
	}
	
	public inline function seti(idx : Int, v : Int) 
	{
		flat[idx] = v;
	}
	
	public inline function setu(x : Int, y : Int, v : Int)
	{
		flat[ui(x, y)] = v;
	}
	
	public inline function setg(x : Int, y : Int, v : Int)
	{
		flat[gi(x, y)] = v;
	}

	/* convert an AABB described in tile units into one covering equivalent grid units */
	public inline function uAABBgAABB(x : Int, y : Int, w : Int, h : Int)
	{
		return QuantizedRect.calc(x, y, w, h, tile_width, tile_height);
	}
	
	function hxSerialize(s : Serializer)
	{
		s.serialize(flat);
		s.serialize(width);
		s.serialize(height);
		s.serialize(tile_width);
		s.serialize(tile_height);
		s.serialize(x);
		s.serialize(y);
		s.serialize(default_tile);
	}
	
	function hxUnserialize(s : Unserializer)
	{
		flat = s.unserialize();
		width = s.unserialize();
		height = s.unserialize();
		tile_width = s.unserialize();
		tile_height = s.unserialize();
		x = s.unserialize();
		y = s.unserialize();
		default_tile = s.unserialize();
	}
	
}