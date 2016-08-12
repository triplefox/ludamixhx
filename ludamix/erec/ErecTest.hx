package ludamix.erec;

class ErecTest {
	
	private static function flag(title : String, r : Array<Bool>) {
		var ok = true;
		for (n in r) {
			ok = ok && n;
		}
		if (!ok) {
			trace('test failed: $title');
			throw r;
		}
		else
			trace('test OK: $title');
	}
	
	public static function run() {
		
		{
			var title = "alloc and intersection";
			var flags = new Array<Bool>();
			var erec = new Erec();
			erec.init(2);
			
			var e0 = erec.alloc(0);
			var e1 = erec.alloc(1);
			
			erec.loadA(e0);
			erec.aX = 0;
			erec.aY = 0;
			erec.aW = 4;
			erec.aH = 4;
			erec.storeA(e0);
			
			erec.loadA(e1);
			erec.aX = 4;
			erec.aY = 4;
			erec.aW = 4;
			erec.aH = 4;
			erec.storeA(e1);
			
			erec.loadA(e0);
			erec.loadB(e1);
			flags.push(erec.intersect() == false);
			flags.push(erec.intersectX() == false);
			flags.push(erec.intersectY() == false);
			erec.swap();
			flags.push(erec.intersect() == false);
			flags.push(erec.intersectX() == false);
			flags.push(erec.intersectY() == false);
			erec.swap();
			
			erec.bX -= 1;
			erec.bY -= 1;
			flags.push(erec.intersectX() == true);
			flags.push(erec.intersectY() == true);
			erec.swap();
			flags.push(erec.intersectX() == true);
			flags.push(erec.intersectY() == true);
			
			flag(title, flags);
		}
		
		{
			var title = "small rect intersection";
			var flags = new Array<Bool>();
			var erec = new Erec();
			erec.init(2);
			
			var e0 = erec.alloc(0);
			var e1 = erec.alloc(1);
			
			erec.loadA(e0);
			erec.aX = 0;
			erec.aY = 0;
			erec.aW = 1;
			erec.aH = 1;
			erec.storeA(e0);
			
			erec.loadA(e1);
			erec.aX = 1;
			erec.aY = 1;
			erec.aW = 1;
			erec.aH = 1;
			erec.storeA(e1);
			
			erec.loadA(e0);
			erec.loadB(e1);
			flags.push(erec.intersect() == false);
			flags.push(erec.intersectX() == false);
			flags.push(erec.intersectY() == false);
			erec.swap();
			flags.push(erec.intersect() == false);
			flags.push(erec.intersectX() == false);
			flags.push(erec.intersectY() == false);
			erec.swap();
			
			erec.bX -= 1;
			erec.bY -= 1;
			flags.push(erec.intersectX() == true);
			flags.push(erec.intersectY() == true);
			erec.swap();
			flags.push(erec.intersectX() == true);
			flags.push(erec.intersectY() == true);
			
			flag(title, flags);
		}
		
		{
			var title = "point intersection";
			var flags = new Array<Bool>();
			var erec = new Erec();
			erec.init(2);
			
			var e0 = erec.alloc(0);
			
			erec.loadA(e0);
			erec.aX = 0;
			erec.aY = 0;
			erec.aW = 2;
			erec.aH = 2;
			erec.storeA(e0);
			
			flags.push(erec.intersectPoint(-1,-1) == false);
			flags.push(erec.intersectPoint(0,-1) == false);
			flags.push(erec.intersectPoint(1,-1) == false);
			flags.push(erec.intersectPoint(2,-1) == false);
			flags.push(erec.intersectPoint(3,-1) == false);

			flags.push(erec.intersectPoint(-1,0) == false);
			flags.push(erec.intersectPoint(0,0) == true);
			flags.push(erec.intersectPoint(1,0) == true);
			flags.push(erec.intersectPoint(2,0) == false);
			flags.push(erec.intersectPoint(3,0) == false);
			
			flags.push(erec.intersectPoint(-1,1) == false);
			flags.push(erec.intersectPoint(0,1) == true);
			flags.push(erec.intersectPoint(1,1) == true);
			flags.push(erec.intersectPoint(2,1) == false);
			flags.push(erec.intersectPoint(3,1) == false);
			
			flags.push(erec.intersectPoint(-1,2) == false);
			flags.push(erec.intersectPoint(0,2) == false);
			flags.push(erec.intersectPoint(1,2) == false);
			flags.push(erec.intersectPoint(2,2) == false);
			flags.push(erec.intersectPoint(3,2) == false);
			
			flags.push(erec.intersectPoint(-1,3) == false);
			flags.push(erec.intersectPoint(0,3) == false);
			flags.push(erec.intersectPoint(1,3) == false);
			flags.push(erec.intersectPoint(2,3) == false);
			flags.push(erec.intersectPoint(3,3) == false);
			
			flag(title, flags);
		}
		
		{
			var title = "allocation limits";
			var flags = new Array<Bool>();
			var erec = new Erec();
			erec.init(2);
			trace('due to kha/kode bugs test $title is currently disabled');
			/*try {
				erec.alloc(0);
				erec.alloc(0);
				erec.alloc(0);
				flags.push(false);
			}
			catch (d : String) {
				flags.push(d == "erec alloc: timeout");
			}*/
			flag(title, flags);
		}
		
		{
			var title = "deallocation";
			var flags = new Array<Bool>();
			var erec = new Erec();
			erec.init(2);
			for (n in 0...1000) {
				var h = erec.alloc(0);
				erec.free(h);
			}
			flags.push(erec.data[0] == erec.unused && erec.data[4] == erec.unused);
			flag(title, flags);
		}
		
		{
			var title = "pushout behavior";
			var flags = new Array<Bool>();
			var erec = new Erec();
			erec.init(2);
			
			var e0 = erec.alloc(0);
			var e1 = erec.alloc(1);
			
			erec.loadA(e0);
			erec.aX = 0;
			erec.aY = 0;
			erec.aW = 4;
			erec.aH = 4;
			erec.storeA(e0);
			
			erec.loadA(e1);
			erec.aX = 4;
			erec.aY = 4;
			erec.aW = 4;
			erec.aH = 4;
			erec.storeA(e1);
			
			erec.loadA(e0);
			erec.loadB(e1);
			
			erec.pushoutRight();
			flags.push(erec.aX == 8);		
			flags.push(erec.intersectX() == false);
			erec.pushoutBottom();
			flags.push(erec.aY == 8);
			flags.push(erec.intersectY() == false);
			
			erec.loadA(e1);
			erec.loadB(e0);
			
			erec.pushoutLeft();
			flags.push(erec.aX == -4);		
			flags.push(erec.intersectX() == false);
			erec.pushoutTop();
			flags.push(erec.aY == -4);
			flags.push(erec.intersectY() == false);
			
			flag(title, flags);
		}
		
		{
			var title = "send and recieve masks";
			var flags = new Array<Bool>();
			var erec = new Erec();
			erec.init(3);
			
			var e0 = erec.alloc(0);
			var e1 = erec.alloc(1);
			var e2 = erec.alloc(2);
			
			erec.loadA(e0);
			erec.aCS = 1;
			erec.aCR = 4;
			erec.storeA(e0);
			erec.loadA(e1);
			erec.aCS = 1 | 2;
			erec.aCR = 1;
			erec.storeA(e1);
			erec.loadA(e2);
			erec.aCS = 4;
			erec.aCR = 2;
			erec.storeA(e2);
			
			erec.loadA(e0);
			erec.loadB(e1);
			
			flags.push(erec.ASendB() == true);
			flags.push(erec.BSendA() == false);
			
			erec.loadA(e0);
			erec.loadB(e2);
			
			flags.push(erec.ASendB() == false);
			flags.push(erec.BSendA() == true);
			
			erec.loadA(e1);
			erec.loadB(e2);
			
			flags.push(erec.ASendB() == true);
			flags.push(erec.BSendA() == false);
			
			flag(title, flags);
		}
		
		{
			var title = "collide all X";
			var flags = new Array<Bool>();
			var erec = new Erec();
			erec.init(4);
			
			var e0 = erec.alloc(0);
			var e1 = erec.alloc(1);
			var e2 = erec.alloc(2);
			
			erec.loadA(e0);
			erec.aX = 0;
			erec.aY = 0;
			erec.aW = 2;
			erec.aH = 1;
			erec.storeA(e0);			
			erec.loadA(e1);
			erec.aX = 1;
			erec.aY = 0;
			erec.aW = 2;
			erec.aH = 1;
			erec.storeA(e1);			
			erec.loadA(e2);
			erec.aX = 2;
			erec.aY = 0;
			erec.aW = 2;
			erec.aH = 1;
			erec.storeA(e2);
			
			var ps = [e2,e1,e0,24];
			var result = [];
			
			erec.collideAllX(ps, result);
			flags.push(ps.length == 4 && 
				ps[0] == e0 && ps[1] == e1 && ps[2] == e2 && ps[3] == 24);
			flags.push(result.length == 4 && 
				result[0] == e0 && result[1] == e1 && result[2] == e1 && result[3] == e2);
			flag(title, flags);
		}
		
		{
			var title = "collide all Y";
			var flags = new Array<Bool>();
			var erec = new Erec();
			erec.init(4);
			
			var e0 = erec.alloc(0);
			var e1 = erec.alloc(1);
			var e2 = erec.alloc(2);
			
			erec.loadA(e0);
			erec.aY = 0;
			erec.aX = 0;
			erec.aH = 2;
			erec.aW = 1;
			erec.storeA(e0);			
			erec.loadA(e1);
			erec.aY = 1;
			erec.aX = 0;
			erec.aH = 2;
			erec.aW = 1;
			erec.storeA(e1);			
			erec.loadA(e2);
			erec.aY = 2;
			erec.aX = 0;
			erec.aH = 2;
			erec.aW = 1;
			erec.storeA(e2);
			
			var ps = [e2,e1,e0,24];
			var result = [];
			
			erec.collideAllY(ps, result);
			flags.push(ps.length == 4 && 
				ps[0] == e0 && ps[1] == e1 && ps[2] == e2 && ps[3] == 24);
			flags.push(result.length == 4 && 
				result[0] == e0 && result[1] == e1 && result[2] == e1 && result[3] == e2);
			flag(title, flags);
		}
		
		{
			var title = "union";
			var flags = new Array<Bool>();
			var erec = new Erec();
			erec.init(5);
			
			var e0 = erec.alloc(0);
			var e1 = erec.alloc(1);
			var e2 = erec.alloc(2);
			var e3 = erec.alloc(3);
			var e4 = erec.alloc(4);
			
			erec.loadA(e0);
			erec.aX = 0;
			erec.aY = 0;
			erec.aW = 1;
			erec.aH = 1;
			erec.storeA(e0);			
			erec.loadA(e1);
			erec.aX = 1;
			erec.aY = 1;
			erec.aW = 1;
			erec.aH = 1;
			erec.storeA(e1);
			erec.loadA(e2);
			erec.aX = 0;
			erec.aY = 0;
			erec.aW = 4;
			erec.aH = 4;
			erec.storeA(e2);			
			erec.aX = 4;
			erec.aY = 4;
			erec.aW = 1;
			erec.aH = 1;
			erec.storeA(e3);			
			erec.aX = 4;
			erec.aY = 2;
			erec.aW = 4;
			erec.aH = 1;
			erec.storeA(e4);			
			
			erec.loadA(e0);
			erec.loadB(e0);
			erec.union();
			flags.push(erec.aX == 0 && erec.aY == 0 && erec.aW == 1 && erec.aH == 1);
			
			erec.loadA(e0);
			erec.loadB(e2);
			erec.union();
			flags.push(erec.aX == 0 && erec.aY == 0 && erec.aW == 4 && erec.aH == 4);
			
			erec.loadA(e0);
			erec.loadB(e3);
			erec.union();
			flags.push(erec.aX == 0 && erec.aY == 0 && erec.aW == 5 && erec.aH == 5);
			
			erec.loadA(e1);
			erec.loadB(e3);
			erec.union();
			flags.push(erec.aX == 1 && erec.aY == 1 && erec.aW == 4 && erec.aH == 4);
			
			erec.loadA(e0);
			erec.loadB(e1);
			erec.union();
			flags.push(erec.aX == 0 && erec.aY == 0 && erec.aW == 2 && erec.aH == 2);
			
			erec.loadB(e0);
			erec.loadA(e1);
			erec.union();
			flags.push(erec.aX == 0 && erec.aY == 0 && erec.aW == 2 && erec.aH == 2);
			
			erec.loadA(e0);
			erec.loadB(e4);
			erec.union();
			flags.push(erec.aX == 0 && erec.aY == 0 && erec.aW == 8 && erec.aH == 3);
			
			erec.loadA(e0);
			erec.unionPoint(1,1);
			flags.push(erec.aX == 0 && erec.aY == 0 && erec.aW == 2 && erec.aH == 2);
			
			erec.loadA(e1);
			erec.unionPoint(0,0);
			flags.push(erec.aX == 0 && erec.aY == 0 && erec.aW == 2 && erec.aH == 2);
			
			flag(title, flags);
		}
		
	}
	
}

