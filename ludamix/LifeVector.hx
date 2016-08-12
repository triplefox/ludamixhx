package ludamix;
import haxe.ds.Vector;

class LifeVector<T> implements Lifetime
{
	
	/* Manages the lifetimes of statically allocated objects in a vector container. */
	
	public var a : Vector<T>; /* array */
	public var z : Vector<Bool>; /* alive */
	public var c : Int; /* spawn count */
	public var name : String; /* name */
	public var attribute : Int; /* attribute */
	public var onSpawn : Int->T->Void;
	public var onDespawn : Int->T->Void;
	public var onExhausted : LifeVector<T>->Void; /* when alloc fails */
	
	public inline function new(name : String, origin : Vector<T>)
	{
		a = origin;
		c = 0;
		z = Vector.fromArrayCopy([for (n0 in a) false]);
		this.name = name;
	}
	
	public function spawn() : Int
	{
		var i0 = 0;
		var zl = z.length;
		while (z[(c + i0) % zl] && i0 < zl) i0 += 1;
		if (i0 >= zl) 
		{
			if (onExhausted == null) throw "too many " + name + " instances!";
			else onExhausted(this);
		}
		c = (c + i0) % z.length;
		z[c] = true;
		if (onSpawn != null) onSpawn(c, a[c]); 
		return c;
	}
	
	public function despawn(i0 : Int)
	{
		if (onDespawn != null) onDespawn(i0, a[i0]);
		z[i0] = false;
		if (i0 < c) c = i0;
	}
	
	public function reset()
	{
		for (i0 in 0...z.length) { z[i0] = false; }
	}
	
}