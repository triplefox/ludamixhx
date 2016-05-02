package ludamix;

import haxe.ds.Vector;
import haxe.macro.Expr;

class Buffer {
	public var id : Int;
	public var first : Int;
	public var last : Int;
	public var chunkfirst : Int;
	public var chunklen : Int;
	public function length() { return last - first; }
	public function new() { first = 0; last = 0; chunkfirst = 0; chunklen = 0; }
}

class AllocatorMacro {
	public macro static function initialize(allocator:Expr,buffer_id:Expr,
		buf:String,raw:String,len:String,ptr:String) : Expr {
        var x0 = macro var $buf = $allocator.buffer.a[$buffer_id];
		var x1 = macro var $raw = $allocator.rawbuf; 
		var x2 = macro var $len = buf.length();
		var x3 = macro var $ptr = buf.first;
		return macro @:mergeBlock $b{[x0,x1,x2,x3]};
    }
}

class BufferAllocatorFloat
{
	public function new(slabsize : Int, slabs : Int, padding : Int, zero_data : Float) {
		buffer = new LifeArray("buffer", [for (i0 in 0...8) new Buffer()]);
		buffer.onExhausted = function(a0) { /* double */
			var l0 = a0.a.length; for (i0 in 0...l0) 
			{
				a0.a.push(new Buffer());
				a0.z.push(false);
			}
		}
		buffer.onSpawn = function(id : Int, obj : Buffer) {
			obj.chunklen = 0;
			obj.chunkfirst = 0;
			obj.first = 0;
			obj.last = 0;
			obj.id = id;
		};
		var bufsize = slabs * slabsize;
		rawbuf = new Vector(bufsize); for (i0 in 0...bufsize) rawbuf[i0] = zero_data;
		this.slabsize = slabsize;
		this.padding = padding;
		this.zero_data = zero_data;
		slaballoc = [for (i0 in 0...slabsize) false];
		alloc_ptr = 0;
	}
	
	public var buffer : LifeArray<Buffer>;
	public var rawbuf : Vector<Float>;
	public var zero_data : Float;
	public var slaballoc : Array<Bool>;
	public var slabsize : Int;
	public var padding : Int;
	public var alloc_ptr : Int;
	
	public inline function zero(start : Int, length : Int) {
		for (i0 in start...(start+length))
		{
			rawbuf[i0] = zero_data;
		}
	}
	
	public inline function atSlab(c0 : Int) { /* exact buffer position */
		return Std.int(slabsize * c0);
	}
	
	public function allocBuffer(size : Int) {
		var s0 = size + padding;
		var c0 = Std.int(Math.ceil(s0 / slabsize));
		var i0 = alloc_ptr;
		while (i0 < slaballoc.length)
		{
			var ok = true;
			for (i1 in i0...i0 + c0)
			{
				if (slaballoc[i1])
				{
					i0 = i1 + 1; ok = false; break;
				}
			}
			if (ok)
			{
				var obj = buffer.a[buffer.spawn()];
				obj.chunkfirst = i0;
				obj.chunklen = c0;
				for (i1 in i0...i0 + c0)
				{
					slaballoc[i1] = true;
				}
				zero(atSlab(i0), s0);
				obj.first = atSlab(i0);
				obj.last = obj.first + size;
				alloc_ptr = (i0 + c0 + 1) % slaballoc.length;
				return obj;
			}
		}
		/* overrun: allocate double the memory */
		var newbuf = new Vector<Float>(rawbuf.length * 2);
		for (i0 in 0...rawbuf.length) newbuf[i0] = rawbuf[i0];
		for (i0 in rawbuf.length...newbuf.length) newbuf[i0] = zero_data;
		rawbuf = newbuf;
		var oldlen = slaballoc.length;
		for (i0 in 0...oldlen)
		{
			slaballoc.push(false);
		}
		return allocBuffer(size);
	}
	
	public function freeBuffer(id : Int) {
		var b0 = buffer.a[id];
		for (i0 in b0.chunkfirst...b0.chunkfirst + b0.chunklen)
		{
			slaballoc[i0] = false;
		}
		buffer.despawn(id);
	}
	
}

class BufferAllocatorInt
{
	public function new(slabsize : Int, slabs : Int, padding : Int, zero_data : Int) {
		buffer = new LifeArray("buffer", [for (i0 in 0...8) new Buffer()]);
		buffer.onExhausted = function(a0) { /* double */
			var l0 = a0.a.length; for (i0 in 0...l0) 
			{
				a0.a.push(new Buffer());
				a0.z.push(false);
			}
		}
		buffer.onSpawn = function(id : Int, obj : Buffer) {
			obj.chunklen = 0;
			obj.chunkfirst = 0;
			obj.first = 0;
			obj.last = 0;
			obj.id = id;
		};
		var bufsize = slabs * slabsize;
		rawbuf = new Vector(bufsize); for (i0 in 0...bufsize) rawbuf[i0] = zero_data;
		this.slabsize = slabsize;
		this.padding = padding;
		this.zero_data = zero_data;
		slaballoc = [for (i0 in 0...slabsize) false];
	}
	
	public var buffer : LifeArray<Buffer>;
	public var rawbuf : Vector<Int>;
	public var zero_data : Int;
	public var slaballoc : Array<Bool>;
	public var slabsize : Int;
	public var padding : Int;
	
	public inline function zero(start : Int, length : Int) {
		for (i0 in start...(start+length))
		{
			rawbuf[i0] = zero_data;
		}
	}
	
	public inline function atSlab(c0 : Int) { /* exact buffer position */
		return Std.int(slabsize * c0);
	}
	
	public function allocBuffer(size : Int) {
		var s0 = size + padding;
		var c0 = Std.int(Math.ceil(s0 / slabsize));
		var i0 = 0;
		while (i0 < slaballoc.length)
		{
			var ok = true;
			for (i1 in i0...i0 + c0)
			{
				if (slaballoc[i1])
				{
					i0 = i1 + 1; ok = false; break;
				}
			}
			if (ok)
			{
				var obj = buffer.a[buffer.spawn()];
				obj.chunkfirst = i0;
				obj.chunklen = c0;
				for (i1 in i0...i0 + c0)
				{
					slaballoc[i1] = true;
				}
				zero(atSlab(i0), s0);
				obj.first = atSlab(i0);
				obj.last = obj.first + size;
				return obj;
			}
		}
		/* overrun: allocate double the memory */
		var newbuf = new Vector<Int>(rawbuf.length * 2);
		for (i0 in 0...rawbuf.length) newbuf[i0] = rawbuf[i0];
		for (i0 in rawbuf.length...newbuf.length) newbuf[i0] = zero_data;
		rawbuf = newbuf;
		var oldlen = slaballoc.length;
		for (i0 in 0...oldlen)
		{
			slaballoc.push(false);
		}
		return allocBuffer(size);
	}
	
	public function freeBuffer(id : Int) {
		var b0 = buffer.a[id];
		for (i0 in b0.chunkfirst...b0.chunkfirst + b0.chunklen)
		{
			slaballoc[i0] = false;
		}
		buffer.despawn(id);
	}
	
}

class BufferStackFloat {
	
	public var data : GrowVector1<Int>;
	public var alloc : BufferAllocatorFloat;
	
	public function new(alloc) {
		this.alloc = alloc;
		data = new GrowVector1(1);
	}
	
	public inline function push(size : Int) : Buffer {
		var buf = alloc.allocBuffer(size);
		data.push(buf.id);
		return buf;
	}
	
	public inline function pop() : Buffer {
		data.l -= 1;
		return read(0);
	}
	
	public inline function read(down : Int) : Buffer {
		return (data.l-down > 0) ? alloc.buffer.a[data.get(data.l-1-down)] : null;
	}
	
}

class BufferStackInt {
	
	public var data : GrowVector1<Int>;
	public var alloc : BufferAllocatorInt;
	
	public function new(alloc) {
		this.alloc = alloc;
		data = new GrowVector1(1);
	}
	
	public inline function push(size : Int) : Buffer {
		var buf = alloc.allocBuffer(size);
		data.push(buf.id);
		return buf;
	}
	
	public inline function pop() : Buffer {
		alloc.freeBuffer(read(0).id);
		data.l -= 1;
		return read(0);
	}
	
	public inline function read(down : Int) : Buffer {
		return (data.l-down > 0) ? alloc.buffer.a[data.get(data.l-1-down)] : null;
	}
	
}