package ludamix.bmfont;
import ludamix.bmfont.BMFont.BMFontInfo;

/* Raw data structures and XML parser for the Angelcode BMFont format. */

class BMFont {
	
	public var info : BMFontInfo;
	public var common : BMFontCommon;
	public var page = new Array<BMFontPage>();
	public var char = new Array<BMFontChar>();
	public var kerning = new Array<BMFontKerning>();
	
	public function new() {}
	
	public static function parse(x : Xml) : Array<BMFont> {
		var result = new Array<BMFont>();
		for (f in x.elementsNamed("font")) {
			var nf = new BMFont(); result.push(nf);
			for (n in f.elements()) {
				switch(n.nodeName) {
					case "info": 
						nf.info = BMFontInfo.parse(n);
					case "common":
						nf.common = BMFontCommon.parse(n);
					case "pages":
						for (m in n.elements())
							nf.page.push(BMFontPage.parse(m));
					case "chars":
						for (m in n.elements())
							nf.char.push(BMFontChar.parse(m));
					case "kernings":
						for (m in n.elements())
							nf.kerning.push(BMFontKerning.parse(m));
				}
			}
		}
		return result;
	}
	
	public function toString() {
		return '${info}\n${common}\n${page}\n${char}\n${kerning}';
	}
	
}

class BMFontInfo {
	
	public var face : String;
	public var size : Int;
	public var bold : Int;
	public var italic : Int;
	public var charset : String;
	public var unicode : Int;
	public var stretchH : Int;
	public var smooth : Int;
	public var aa : Int;
	public var padding : Array<Int>;
	public var spacing : Array<Int>;
	public var outline : Int;
	
	public function new() {
		
	}
	
	public static function parse(x : Xml) {
		var result = new BMFontInfo();
		for (n in x.attributes()) {
			switch(n) {
				case "face": result.face = x.get(n);
				case "size": result.size = Std.parseInt(x.get(n));
				case "bold": result.bold = Std.parseInt(x.get(n));
				case "italic": result.italic = Std.parseInt(x.get(n));
				case "charset": result.charset = x.get(n);
				case "unicode": result.unicode = Std.parseInt(x.get(n));
				case "stretchH": result.stretchH = Std.parseInt(x.get(n));
				case "smooth": result.smooth = Std.parseInt(x.get(n));
				case "aa": result.aa = Std.parseInt(x.get(n));
				case "padding": result.padding = [for (v in x.get(n).split(",")) Std.parseInt(v)];
				case "spacing": result.spacing = [for (v in x.get(n).split(",")) Std.parseInt(v)];
				case "outline": result.outline = Std.parseInt(x.get(n));
			}
		}
		return result;
	}
	
	public function toString() {
		return '(info face=$face size=$size bold=$bold italic=$italic charset=$charset ' +
			'unicode=$unicode stretchH=$stretchH smooth=$smooth aa=$aa padding=$padding ' +
			'spacing=$spacing outline=$outline )';
	}
	
}

class BMFontCommon {
	
	public var lineHeight : Int;
	public var base : Int;
	public var scaleW : Int;
	public var scaleH : Int;
	public var pages : Int;
	public var packed : Int;
	public var alphaChnl : Int;
	public var redChnl : Int;
	public var greenChnl : Int;
	public var blueChnl : Int;
	
	public function new() {
		
	}
	
	public static function parse(x : Xml) {
		var result = new BMFontCommon();
		for (n in x.attributes()) {
			switch(n) {
				case "lineHeight": result.lineHeight = Std.parseInt(x.get(n));
				case "base": result.base = Std.parseInt(x.get(n));
				case "scaleW": result.scaleW = Std.parseInt(x.get(n));
				case "scaleH": result.scaleH = Std.parseInt(x.get(n));
				case "pages": result.pages = Std.parseInt(x.get(n));
				case "packed": result.packed = Std.parseInt(x.get(n));
				case "alphaChnl": result.alphaChnl = Std.parseInt(x.get(n));
				case "redChnl": result.redChnl = Std.parseInt(x.get(n));
				case "greenChnl": result.greenChnl = Std.parseInt(x.get(n));
				case "blueChnl": result.blueChnl = Std.parseInt(x.get(n));
			}
		}
		return result;
	}
	
	public function toString() {
		return '(common lineHeight=$lineHeight base=$base scaleW=$scaleW scaleH=$scaleH ' +
			'pages=$pages packed=$packed alphaChnl=$alphaChnl redChnl=$redChnl greenChnl=' +
			'$greenChnl blueChnl=$blueChnl )';
	}
	
}

class BMFontPage {
	
	public var id : Int;
	public var file : String;
	
	public function new() {
		
	}
	
	public static function parse(x : Xml) {
		var result = new BMFontPage();
		for (n in x.attributes()) {
			switch(n) {
				case "id": result.id = Std.parseInt(x.get(n));
				case "file": result.file = x.get(n);
			}
		}
		return result;
	}
	
	public function toString() {
		return '(page id=$id file=$file )';
	}
	
}

class BMFontChar {
	
	public var id : Int;
	public var x : Int;
	public var y : Int;
	public var width : Int;
	public var height : Int;
	public var xoffset : Int;
	public var yoffset : Int;
	public var xadvance : Int;
	public var page : Int;
	public var chnl : Int;
	
	public function new() {
		
	}
	
	public static function parse(x : Xml) {
		var result = new BMFontChar();
		for (n in x.attributes()) {
			switch(n) {
				case "id": result.id = Std.parseInt(x.get(n));
				case "x": result.x = Std.parseInt(x.get(n));
				case "y": result.y = Std.parseInt(x.get(n));
				case "width": result.width = Std.parseInt(x.get(n));
				case "height": result.height = Std.parseInt(x.get(n));
				case "xoffset": result.xoffset = Std.parseInt(x.get(n));
				case "yoffset": result.yoffset = Std.parseInt(x.get(n));
				case "xadvance": result.xadvance = Std.parseInt(x.get(n));
				case "page": result.page = Std.parseInt(x.get(n));
				case "chnl": result.chnl = Std.parseInt(x.get(n));
			}
		}
		return result;
	}
	
	public function toString() {
		return '(char id=$id x=$x y=$y width=$width height=$height xoffset=$xoffset' +
			' yoffset=$yoffset xadvance=$xadvance page=$page chnl=$chnl )';
	}
	
}

class BMFontKerning {
	
	public var first : Int;
	public var second : Int;
	public var amount : Int;
	
	public function new() {
		
	}
	
	public static function parse(x : Xml) {
		var result = new BMFontKerning();
		for (n in x.attributes()) {
			switch(n) {
				case "first": result.first = Std.parseInt(x.get(n));
				case "second": result.second = Std.parseInt(x.get(n));
				case "amount": result.amount = Std.parseInt(x.get(n));
			}
		}
		return result;
	}
	
	public function toString() {
		return '(kerning first=$first second=$second amount=$amount )';
	}
	
}