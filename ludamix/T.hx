package ludamix;
import haxe.ds.Vector;

class T /*toolbox*/
{
	
	public static inline var TAU = 6.28318530718;
	
	public static inline function lerpF(r0 : Float, r1 : Float, z : Float) : Float { return (r0 + (r1 - r0) * z); }
	public static inline function lerpI(r0 : Int, r1 : Int, z : Float) : Int { return Std.int(r0 + (r1 - r0) * z); }
	
	public static inline function lscale(l0 : Float, h0 : Float, l1 : Float, h1 : Float, z0 : Float) : Float
	/* map a variable z0 from a linear interpolation of [l0, h0] into an interpolation of [l1,h1]. */
	{
		return (/*offset0*/(z0 - l0) * /*scale*/((/*d0*/h1 - l1)/(/*d1*/h0 - l0)) + l1/*offset1*/);
	}
	
	public static inline function rdiff /*rotational diff between [0,lim)*/ (r0 : Float, r1 : Float, lim : Float)
	{
		r0 = r0 % lim; r1 = r1 % lim;
		var d0 = (r1 - r0);
		var d1 = ((r1 - (r0 + lim)));
		var d2 = (((r1 + lim) - r0));
		var ad0 = Math.abs(d0); var ad1 = Math.abs(d1); var ad2 = Math.abs(d2);
		if (ad0 < ad1)
		{ 
			if (ad0 < ad2)
				return d0;
			else
				return d2;
		}
		else
		{
			if (ad1 < ad2)
				return d1;
			else
				return d2;
		}
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
	
}