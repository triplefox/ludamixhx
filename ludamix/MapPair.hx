package ludamix;

class MapPair {

	public static inline function setiii(m : 
		Map<Int,Map<Int,Int>>, k0 : Int, k1 : Int, v : Int) {
		if (m.exists(k0)) {
			var n = m.get(k0);
			n.set(k1, v);
		} else {
			var n = new Map<Int,Int>();
			m.set(k0, n);
			n.set(k1, v);
		}
	}
	
	public static inline function getiii(m : 
		Map<Int,Map<Int,Int>>, k0 : Int, k1 : Int, missing : Int) {
		if (m.exists(k0)) {
			var n = m.get(k0);
			if (!n.exists(k1)) return missing;
			return n.get(k1);
		} else {
			return missing;
		}
	}

}