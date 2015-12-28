package ludamix.proframe;

class ProframeTest {

	public static function run() {
		var pf = new Proframe([
			"control",
			"ai",
			"collision",
			"render"
		], "ms");
		
		var t = 0;
		pf.start(t);
		t += 3;
		pf.log("control", t);
		t += 6;
		pf.log("ai", t);
		t += 5;
		pf.log("collision", t);
		t += 8;
		pf.log("render", t);
		t += 1;
		pf.end(t);
		
		trace(pf.report());		
	}
	
}
