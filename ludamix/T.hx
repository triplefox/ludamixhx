package ludamix;
import haxe.ds.Vector;

class T /*toolbox*/
{
	
	public static inline var TAU = 6.28318530718;
	public static inline var EPSILON = 0.0000001;
	
	public static inline function lerpF(r0 : Float, r1 : Float, z : Float) : Float { return (r0 + (r1 - r0) * z); }
	public static inline function lerpI(r0 : Int, r1 : Int, z : Float) : Int { return Std.int(r0 + (r1 - r0) * z); }
	
	public static inline function lscale(l0 : Float, h0 : Float, l1 : Float, h1 : Float, z0 : Float) : Float
	/* map a variable z0 from a linear interpolation of [l0, h0] into an interpolation of [l1,h1]. */
	{
		return (/*offset0*/(z0 - l0) * /*scale*/((/*d0*/h1 - l1)/(/*d1*/h0 - l0)) + l1/*offset1*/);
	}
	
	// difference functions: returns signed values
	public static inline function rdiff /*rotational diff between [0,lim)*/ (r0 : Float, r1 : Float, lim : Float)
	{
		var left = modf(r1);
		var right = left + lim;
		r0 = modf(r0);
		if (r0 < left) r0 += lim;
		var d0 = r0 - left;
		var d1 = right - r0;
		return (d0 < d1) ? -d0 : d1;
	}
	public static inline function diffRad /* nearest difference in radians */ (r0 : Float, r1 : Float) {
		return rdiff(r0, r1, TAU);
	}	
	public static inline function diffDeg /* nearest difference in degrees */ (r0 : Float, r1 : Float) {
		return rdiff(r0, r1, 360.);
	}
	
	public static inline function rlerp /*rotational lerp between [0,lim)*/ (r0 : Float, r1 : Float, lim : Float, z : Float)
	{
		return (r0 + rdiff(r0, r1, lim) * z) % lim;
	}
	
	public static inline function lerpRad /* interpolate in radians between [0,tau) */ (r0 : Float, r1 : Float, z : Float) {
		return rlerp(r0, r1, TAU, z);
	}	
	public static inline function lerpDeg /* interpolate in degrees between [0,360) */ (r0 : Float, r1 : Float, z : Float) {
		return rlerp(r0, r1, 360., z);
	}
	
	/* radian/degree angle conversions */
	public static inline function rad2deg(r : Float) : Float { return (r / (TAU)) * 360; }
	public static inline function deg2rad(d : Float) : Float { return (d / 360) * (TAU); }
	
	public static inline function sample<T>(a : Vector<T>, z : Float) /*nearest interpolation of z on a in [0,1]*/ { return a[Math.round(z * (a.length-1))]; }
	public static inline function lsample<T>(a : Vector<Float>, z : Float) /*linear interpolation of z on a in [0,1]*/
	{ var k = z * (a.length - 1); var i = Std.int(k); (i>=a.length-1) ? return a[i] : return lerpF(a[i], a[i + 1], k - i); }
	
	public static inline function trunc /* truncate float to the amount rounded by the divisor */ (a : Float, div : Float) { return Math.round(a * div) / div; }
	
	public static inline function clamp(l : Float, h : Float, v : Float) { return Math.min(h, Math.max(l, v)); }

	public static inline function aabbf(x0 : Float,y0 : Float,
		w0 : Float,h0 : Float,x1 : Float,y1 : Float,w1 : Float,h1 : Float):Bool {
		return (!(
			x0 + w0 - EPSILON < x1 ||
			y0 + h0 - EPSILON < y1 ||
			x0 > x1 + w1 - EPSILON ||
			y0 > y1 + h1 - EPSILON) );
	}

	public static inline function aabbi(x0 : Int,y0 : Int,
		w0 : Int,h0 : Int,x1 : Int,y1 : Int,w1 : Int,h1 : Int):Bool {
		return (!(
			x0 + w0 - 1 < x1 ||
			y0 + h0 - 1 < y1 ||
			x0 > x1 + w1 - 1 ||
			y0 > y1 + h1 - 1) );
	}
	
	/* modulus that "circular" wraps to negative values */
	public static inline function modf(a : Float, b : Float) : Float
	{ return (b+(a % b)) % b; }
	public static inline function modi(a : Int, b : Int) : Int {
	{ return (b+(a % b)) % b; }
	
}
