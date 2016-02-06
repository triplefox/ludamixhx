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
	}
	
	public inline function lineAdvance() {
		resetHoriz();
		oy += font[curfn].font.common.lineHeight;
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
			buf[bi] = chd.x;
			buf[bi+1] = chd.y;
			buf[bi+2] = chd.width;
			buf[bi+3] = chd.height;
			buf[bi+4] = ox + chd.xoffset;
			buf[bi+5] = oy + chd.yoffset;
			buf[bi+6] = chd.width;
			buf[bi+7] = chd.height;
			pg[len] = chd.page;
			fn[len] = chd.curfn;
			// calc extents
			var cleft = buf[bi + 4];
			var cright = cleft + buf[bi+6];
			var ctop = buf[bi + 5];
			var cbottom = ctop + buf[bi+7];
			if (cleft < left) left = cleft;
			if (cright > right) right = cright;
			if (ctop < top) top = ctop;
			if (cbottom < bottom) bottom = cbottom;
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
	
	/* render a breakLine()'d array with word wrapping. */
	public function wrap(s : Array<WordWrapData>, width : Float) {
		var cw = 0.;
		var idx = 0;
		while (idx < s.length) {
			var n = s[idx];
			var prevlen = this.len;
			var prevtop = this.top;
			var prevleft = this.left;
			var prevbottom = this.bottom;
			var prevright = this.right;
			switch(n) {
				case WWBreak:
					lineAdvance();
				case WWToken(v):
					var c = 0;
					while(this.width() <= width && c < v.length) {
						write(v.charCodeAt(c));
						c += 1;
					}
					// automatic line break
					if (this.width() > width) {
						c = 0; // number chars written in this _word_
						var cw = 0; // number chars written on this _line_
						if (prevlen > 0)
							lineAdvance();
						else
							resetHoriz();
						this.left = prevleft;
						this.top = prevtop;
						this.bottom = prevbottom;
						this.right = prevright;
						this.len = prevlen;
						// now always write 1 char at a time
						while(c < v.length) {
							prevlen = this.len;
							prevtop = this.top;
							prevleft = this.left;
							prevbottom = this.bottom;
							prevright = this.right;
							write(v.charCodeAt(c));
							c += 1;
							cw += 1;
							// failsafe split after 1 write
							if (this.width() > width && cw > 1) {
								lineAdvance();
								this.left = prevleft;
								this.top = prevtop;
								this.bottom = prevbottom;
								this.right = prevright;
								this.len = prevlen;
								c -= 1;
								cw = 0;
							}
						}
					}
				case WWWhitespace:
					write(" ".charCodeAt(0));
					if (this.width() > width) {
						lineAdvance();
						this.left = prevleft;
						this.top = prevtop;
						this.bottom = prevbottom;
						this.right = prevright;
					}
			}
			idx += 1;
		}
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
	
	public function translateCenter(x, y) {
		translateTopLeft(x - this.width()/2, y - this.height()/2);
	}
	
}

enum WordWrapData {
	WWToken(s : String);
	WWBreak;
	WWWhitespace;
}

