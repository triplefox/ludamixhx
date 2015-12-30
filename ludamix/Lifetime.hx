package ludamix;

/*

JWH:

The purpose of "Lifetime" is to allow data to be normalized against a singular container.
That is, given a type identifier and a key(usually an integer), the database can automatically access
the appropriate container of an attribute. The attribute's type is assigned by the database at
startup; this makes it straightforward for user code to compose additional data.

Additionally, the way Lifetime is structured allows it to contain entity relationships.

This pattern could theoretically be abstracted many ways, but the grain of Haxe OO
makes it most straightforward to implement with an interface and parameterized classes.

*/

interface Lifetime
{
	public var name : String;
	public var attribute : Int; /* attribute type identifier */
	public function despawn(id : Int) : Void;
	public function reset() : Void;
}
