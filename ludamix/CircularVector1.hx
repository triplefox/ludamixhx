package ludamix;

import haxe.ds.Vector;

class CircularVector1<T> {
	public var data : Vector<T>;
	public var start : Int;
	public var length : Int;
	public inline function new(size) {
		data = new Vector<T>(size);
		start = 0;
		length = 0;
	}
	public inline function writehead() {
		return (start + length) % data.length;
	}
	public inline function push(v : T) {
		data[writehead()] = v;
		length += 1;
	}
	public inline function full() {
		return length >= data.length;
	}
	public inline function empty() {
		return length <= 0;
	}
	public inline function shift() {
		var v = data[start]; 
		start = (start + 1) % data.length;
		length -= 1;
		return v;
	}
	public inline function shiftClear(clear : T) {
		var v = data[start];
		data[start] = clear;
		start = (start + 1) % data.length;
		length -= 1;
		return v;
	}
	public inline function startIndex() {
		return start;
	}
	public inline function setStartIndex(v : Int) {
		start = v % data.length;
	}
	public inline function loadRelativeIndex(i : Int) {
		return data[(startIndex() + i) % indexCapacity()];
	}
	public inline function loadAbsoluteIndex(i : Int) {
		return data[i];
	}
	public inline function storeRelativeIndex(i : Int, v : T) {
		data[(startIndex() + i) % indexCapacity()] = v;
	}
	public inline function storeAbsoluteIndex(i : Int, v : T) {
		data[i] = v;
	}
	public inline function indexLength() {
		return length;
	}
	public inline function indexCapacity() {
		return data.length;
	}
	public inline function endIndex() {
		return (startIndex() + indexLength()) % indexCapacity();
	}
}

