package ludamix.pixelbound;

import haxe.Json;

/* Parses raw Pixelbound JSON data. */

class BoundsData {
	public var images : Array<BoundsImage>;
	public var palette : Array<Array<Int>>;
	
	public function new(data : String)
	{
		var jd = Json.parse(data);
		this.palette = jd.palette;
		this.images = [];
		for (img in cast(jd.images,Array<Dynamic>)) {
			var rimg = new BoundsImage();
			rimg.names = img.names;
			rimg.rects = img.rects;
			rimg.image_relative = img.image_relative;
			rimg.image_absolute = img.image_absolute;
			rimg.updateCache();
			this.images.push(rimg);
		}
	}
}

class BoundsImage {
	public var names : Array<String>;
	public var rects : Array<Array<Int>>;
	public var names_map : Map<String, Int>;
	public var image_relative : String;
	public var image_absolute : String;
	public function new() {
		
	}
	public function updateCache() {
		names_map = new Map();
		for (i0 in 0...names.length) {
			names_map.set(names[i0], i0);
		}
	}
	public inline function nameToRect(name : String, ?offset : Int=0) {
		return rects[names_map.get(name)+offset];
	}	
}

