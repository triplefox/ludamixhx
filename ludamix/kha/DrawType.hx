package ludamix.kha;

@:enum 
abstract DrawType(Int){
	var DTRectangle = 1;
	var DTImage = 2;
	var DTSetScissorMode = 3;
	public function new(i) { this = i; }
	public inline function asInt() : Int { return this; }
}

