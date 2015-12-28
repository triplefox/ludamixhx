package ludamix.grassi;

class Grassi {
	
	/* GC-friendly "Graphics Asset Instancing" (grassi) system. */
	
	/* 

		These cells only store positioning data, type, and index of type.
		Additional parameters go in a separate structure using the type/index.
		Grassi essentially exists to do basic renderable entity sorting/positioning.
		
		The Z parameter is indexed from low to high.
		
	*/

	public var unused : Int; /* the number to indicate "clear" status (default -1234) */
	
	public var data : Array<GrassiCell>;
	public var sortdata : Array<GrassiCell>;
	public var aptr : Int; /* allocation ptr */
	
	public function new(size, ?unused = -1234) {
		data = [for (n in 0...size) new GrassiCell(unused)];
		sortdata = [for (n in 0...data.length) data[n]];
		aptr = 0;
		this.unused = unused;
	}
	
	public inline function alloc(type : Int) : Int {
		var timeout = 0;
		while (data[aptr].t != unused && timeout < data.length) {
			aptr = (aptr + 1) % data.length;
			timeout += 1;
		}
		if (timeout >= data.length) throw "grassi alloc: timeout";
		data[aptr].t = type;
		return aptr;
	}
	public inline function free(ptr : Int) {
		data[ptr].t = unused;
	}
	private function compare(a : GrassiCell, b : GrassiCell) : Int {
		return a.z - b.z;
	}
	public inline function sort() {
		sortdata.sort(compare);
	}

}

