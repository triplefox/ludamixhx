package ludamix;

class QuantizedRect
{

	/**
	 * Returns a rectangle with area quantized to cover a less precise scale(e.g. unit scale to tile scale).
	 */
	public static inline function calc(
		ux : Int,
		uy : Int,
		uw : Int,
		uh : Int,
		tile_width : Int, 
		tile_height : Int
		)
	{
		var tx = Std.int(ux / tile_width);
		var ty = Std.int(uy / tile_height);
		var tr = (ux + uw) / tile_width;  var tw = Math.ceil(tr) - tx;
		var tb = (uy + uh) / tile_height; var th = Math.ceil(tb) - ty;	
		return [tx,ty,tw,th];
	}

}