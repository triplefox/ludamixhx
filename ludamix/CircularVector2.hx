package ludamix;

import haxe.ds.Vector;

class CircularVector2<T> {
	public var data : Vector<T>;
	public var start : Int;
	public var length : Int;
	public var r0 : T;
	public var r1 : T;
	public inline function new(size) {
		data = new Vector<T>(size * 2);
		start = 0;
		length = 0;
	}
	public inline function writehead() {
		return (start + length) % data.length;
	}
	public inline function push(v0 : T, v1 : T) {
		var pos = writehead();
		data[pos] = v0;
		data[pos + 1] = v1;
		length += 2;		
	}
	public inline function full() {
		return length >= data.length;
	}
	public inline function empty() {
		return length <= 0;
	}
	public inline function shift() {
		r0 = data[start];
		r1 = data[start + 1];
		start = (start + 2) % data.length;
		length -= 2;
	}
	public inline function shiftClear(c0 : T, c1 : T) {
		r0 = data[start];
		r1 = data[start + 1];
		data[start] = c0;
		data[start + 1] = c1;
		start = (start + 2) % data.length;
		length -= 2;
	}
	public inline function startIndex() {
		return start >> 1;
	}
	public inline function setStartIndex(v : Int) {
		start = (v << 1) % data.length;
	}
	public inline function indexLength() {
		return length >> 1;
	}
	public inline function indexCapacity() {
		return data.length >> 1;
	}
	public inline function endIndex() {
		return (startIndex() + indexLength()) % indexCapacity();
	}
	public inline function loadRelativeIndex(i : Int) {
		var idx = (startIndex() + (i << 1)) % indexCapacity();
		r0 = data[idx];
		r1 = data[idx + 1];
	}
	public inline function loadAbsoluteIndex(i : Int) {
		var idx = (i << 1);
		r0 = data[idx];
		r1 = data[idx + 1];
	}
	public inline function storeRelativeIndex(i : Int, v0 : T, v1 : T) {
		var idx = (startIndex() + i) % indexCapacity(); 
		data[idx] = v0;
		data[idx + 1] = v1;
	}
	public inline function storeAbsoluteIndex(i : Int, v0 : T, v1 : T) {
		var idx = i << 1; 
		data[idx] = v0;
		data[idx + 1] = v1;
	}
}
