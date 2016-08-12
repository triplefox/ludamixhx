package ludamix.bmfont;
import haxe.ds.Vector;
import ludamix.bmfont.BMFont;
using ludamix.MapPair;

class BMFontRenderPage<T> {
	
	public var data : BMFontPage; 
	public var image : T; 
	
	public function new(data) {this.data = data;}
	
}

class BMFontRenderable<T> {
	
	public var page : Array<BMFontRenderPage<T>>;
	public var font : BMFont;
	public var kerning : Map<Int, Map<Int,Int>>;
	public var char : Map<Int, BMFontChar>;	
	
	public function new(font : BMFont, 
		pagemap : Map<String, BMFontRenderPage<T>>) {
		this.font = font;
		this.page = [for (p in font.page) pagemap.get(p.file)];
		this.kerning = new Map();
		for (k in font.kerning) {
			this.kerning.setiii(k.first, k.second, k.amount);
		}
		this.char = new Map();
		for (c in font.char) {
			this.char.set(c.id, c);
		}
	}
	
}

/* Holds a state buffer for writing with a BMFont. */
class BMFontWriter<T> {
	
	public var MAX_CHARS = 2048; // 72 bytes per character

	public function new(?max_chars = 2048) {
		writing = false;
		this.MAX_CHARS = max_chars;
		buf = new Vector(MAX_CHARS*8);
		pg = new Vector(MAX_CHARS);
		fn = new Vector(MAX_CHARS);
	}
	
	// internal variables
	public var writing : Bool; // am writing?
	public var font : Array<BMFontRenderable<T>>;
	public var last_chr : Int; // last char written
	public var ox : Float; // origin (cursor) x
	public var oy : Float; // origin (cursor) y
	public var bx : Float; // begin x
	public var by : Float; // begin y
	
	// read variables
	public var buf : Vector<Float>; // variable vector
	public var pg : Vector<Int>; // page (per char)
	public var fn : Vector<Int>; // font (per char)
	public var curfn : Int; // current font
	public var left : Float; // extent left
	public var top : Float; // extent top
	public var right : Float; // extent right
	public var bottom : Float; // extent bottom
	public var len : Int; // number of chars written
	public var lines : Int; // number of lines written
	
	public function begin(font, curfn, x, y) {
		if (writing) throw 'writer is still writing';
		writing = true;
		this.font = font;
        this.curfn = curfn;
		last_chr = -1;
		this.ox = x;
		this.oy = y;
		this.bx = x;
		this.by = y;
		this.lines = 1;
		// the initial size is "unknown", so we use
		// values that will definitely be overwritten
		this.left = x + this.font[curfn].font.common.scaleW;
		this.top = y + this.font[curfn].font.common.scaleH;
		this.right = x - this.font[curfn].font.common.scaleW;
		this.bottom = y - this.font[curfn].font.common.scaleH;
		len = 0;
	}
	
	public inline function resetHoriz() {
		ox = bx;
		last_chr = -1;
	}
	
	public inline function resetVert() {
		oy = by;
		this.lines = 0;
	}
	
	public inline function lineAdvance() {
		resetHoriz();
		oy += font[curfn].font.common.lineHeight;
		this.lines += 1;
	}
	
	public inline function end() {
		if (!writing) throw 'writer is not writing';
		writing = false;
	}
	
	public inline function bufpos(i) {return i << 3;}
	// source x
	public inline function sx(i) {return buf[i << 3];}
	public inline function ssx(i, v) {buf[i << 3] = v;}
	// source y
	public inline function sy(i) {return buf[1 + (i << 3)];}
	public inline function ssy(i, v) {buf[1 + (i << 3)] = v;}
	// source width
	public inline function sw(i) {return buf[2 + (i << 3)];}
	public inline function ssw(i, v) {buf[2 + (i << 3)] = v;}
	// source height
	public inline function sh(i) {return buf[3 + (i << 3)];}
	public inline function ssh(i, v) {buf[3 + (i << 3)] = v;}
	// dest x
	public inline function dx(i) {return buf[4 + (i << 3)];}
	public inline function sdx(i, v) {buf[4 + (i << 3)] = v;}
	// dest y
	public inline function dy(i) {return buf[5 + (i << 3)];}
	public inline function sdy(i, v) {buf[5 + (i << 3)] = v;}
	// dest width
	public inline function dw(i) {return buf[6 + (i << 3)];}
	public inline function sdw(i, v) {buf[6 + (i << 3)] = v;}
	// dest height
	public inline function dh(i) {return buf[7 + (i << 3)];}
	public inline function sdh(i, v) {buf[7 + (i << 3)] = v;}

	public inline function width() {return right - left;}
	public inline function height() {return bottom - top;}
	
	public inline function write(ch : Int) {
		if (!writing) throw 'writer is not writing';
		var chd = font[curfn].char.get(ch);
		if (chd != null && len < MAX_CHARS) {
			// add kerning
			ox += font[curfn].kerning.getiii(last_chr, ch, 0);
			// set values to new character
			var bi = len << 3;
			var destx = ox + chd.xoffset;
			var desty = oy + chd.yoffset;
			var destw = chd.width;
			var desth = chd.height;
			buf[bi] = chd.x;
			buf[bi+1] = chd.y;
			buf[bi+2] = chd.width;
			buf[bi+3] = chd.height;
			buf[bi+4] = destx;
			buf[bi+5] = desty;
			buf[bi+6] = destw;
			buf[bi+7] = desth;
			pg[len] = chd.page;
			fn[len] = curfn;
			// calc extents
			if (destx < left) left = destx;
			if (destx + destw > right) right = destx + destw;
			if (desty < top) top = desty;
			if (desty + desth > bottom) bottom = desty + desth;
			// advance
			last_chr = ch;
			ox += chd.xadvance;
			len += 1;
		}
	}
	
	/* automatically break a line into word and linebreak tokens. */ 
	public static function breakLine(s : String, 
		keep_existing_breaks : Bool) {
		var d0 = new Array<WordWrapData>();
		var sa : Array<String>;
		if (keep_existing_breaks) {
			for (n in s.split("\n")) {
				var tok = "";
				for (idx in 0...n.length) {
					var c0 = n.charAt(idx);
					if (c0==" ")
					{
						if (tok.length > 0) {
							d0.push(WWToken(tok));
							tok = "";
						}
						d0.push(WWWhitespace);
					} else {
						tok += c0;
					}
				}
				if (tok.length > 0) {
					d0.push(WWToken(tok));
				}
				d0.push(WWBreak);
			}
		} else {
			s = StringTools.replace(s, "\n", " ");
			var tok = "";
			for (idx in 0...s.length) {
				var c0 = s.charAt(idx);
				if (c0==" ")
				{
					if (tok.length > 0) {
						d0.push(WWToken(tok));
						tok = "";
					}
					d0.push(WWWhitespace);
				} else {
					tok += c0;
				}
			}
			if (tok.length > 0) {
				d0.push(WWToken(tok));
			}
		}
		return d0;
	}
	
	private inline function expand_rect(a : {top:Float,left:Float,bottom:Float,right:Float}) {
		if (a.left > left) a.left = left;
		if (a.right < right) a.right = right;
		if (a.top > top) a.top = top;
		if (a.bottom < bottom) a.bottom = bottom;
	}
	private inline function reset_origin() {
		left = ox;
		right = ox;
		top = oy;
		bottom = oy;
	}
	private inline function reset_rect(a : {top:Float,left:Float,bottom:Float,right:Float}) {
		left = a.left;
		right = a.right;
		top = a.top;
		bottom = a.bottom;
	}
	
	/* render a breakLine()'d array with word wrapping. */
	public function wrap(s : Array<WordWrapData>, lwidth : Float) {
		var cw = 0.;
		var idx = 0;
		
		reset_origin();
		var rect = {top:top,left:left,bottom:bottom,right:right};
		
		while (idx < s.length) {
			if (rect.right - rect.left > lwidth)
				throw '$idx of $s';
			var n = s[idx];
			var line_start = ox == bx;
			switch(n) {
				case WWBreak:
					lineAdvance();
					expand_rect(rect);
				case WWToken(v):
					var c = 0;
					var word_rect = {top:rect.top,left:rect.left,bottom:rect.bottom,right:rect.right};
					while(c < v.length) {
						write(v.charCodeAt(c));
						if (this.width() > lwidth) { // back up
							if (!line_start) { // generous
								len -= c + 1;
								c = 0;
								line_start = true;
								rect.top = word_rect.top;
								rect.left = word_rect.left;
								rect.bottom = word_rect.bottom;
								rect.right = word_rect.right;
							} else { // failsafe
								len -= 1;
							}
							reset_rect(rect);
							lineAdvance();
							expand_rect(rect);
						} else {
							c += 1;
							expand_rect(rect);
						}
					}
				case WWWhitespace:
					write(" ".code);
					if (this.width() > lwidth) {
						reset_rect(rect);
						lineAdvance();
					}
					expand_rect(rect);
			}
			idx += 1;
		}
		
		reset_rect(rect);
	}
	
	public function translateTopLeft(x : Float, y : Float) {
		var xo = x - this.left;
		var yo = y - this.top;
		this.left += xo;
		this.right += xo;
		this.top += yo;
		this.bottom += yo;
		ox += xo;
		oy += yo;
		bx += xo;
		by += yo;
		for (i0 in 0...len) {
			var bi = i0 << 3;
			buf[bi+4] += xo;
			buf[bi+5] += yo;
		}
	}
	
	/* centers around the number of lines, line height, and baseline,
	maintains vertical consistency across multiple bodies of text */
	public function translateBodyCenter(x, y) {
		translateTopLeft(x - this.width()/2, 
		y + (font[curfn].font.common.lineHeight - font[curfn].font.common.base)/2 
		- (this.lines * font[curfn].font.common.lineHeight)/2);
	}
	
	/* centers around the displayed content which may be a little less
	than line height */
	public function translateDisplayCenter(x, y) {
		translateTopLeft(x - this.width()/2, y - this.height()/2);
	}
	
}

enum WordWrapData {
	WWToken(s : String);
	WWBreak;
	WWWhitespace;
}

