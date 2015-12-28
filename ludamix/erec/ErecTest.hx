package ludamix.erec;
import haxe.ds.Vector;

class ErecTest {
	
	public static function run() {
		
		{ /* alloc and intersection */
			var erec = new Erec(2);
			
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
			trace(erec.intersect() == false);
			trace(erec.intersectX() == false);
			trace(erec.intersectY() == false);
			erec.bX -= 1;
			trace(erec.intersectX() == true);
			erec.bY -= 1;
			trace(erec.intersectY() == true);
		}
		
		{ /* allocation limits */
			var erec = new Erec(2);
			try {
				erec.alloc(0);
				erec.alloc(0);
				erec.alloc(0);
				trace(false);
			}
			catch (d : String) {
				trace(d == "erec alloc: timeout");
			}
		}
		
		{ /* deallocation */
			var erec = new Erec(2);
			for (n in 0...1000) {
				var h = erec.alloc(0);
				erec.free(h);
			}
			trace(erec.data[0] == erec.unused && erec.data[4] == erec.unused);
		}
		
		{ /* pushout behavior */
			var erec = new Erec(2);
			
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
			trace(erec.aX == 8);		
			trace(erec.intersectX() == false);
			erec.pushoutBottom();
			trace(erec.aY == 8);
			trace(erec.intersectY() == false);
			
			erec.loadA(e1);
			erec.loadB(e0);
			
			erec.pushoutLeft();
			trace(erec.aX == -4);		
			trace(erec.intersectX() == false);
			erec.pushoutTop();
			trace(erec.aY == -4);
			trace(erec.intersectY() == false);
			
		}
		
		{ /* send and recieve masks */
			var erec = new Erec(3);
			
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
			
			trace(erec.ASendB() == true);
			trace(erec.BSendA() == false);
			
			erec.loadA(e0);
			erec.loadB(e2);
			
			trace(erec.ASendB() == false);
			trace(erec.BSendA() == true);
			
			erec.loadA(e1);
			erec.loadB(e2);
			
			trace(erec.ASendB() == true);
			trace(erec.BSendA() == false);
			
		}
		
		{ /* collide all X */
			var erec = new Erec(4);
			
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
			trace(ps.length == 4 && 
				ps[0] == e0 && ps[1] == e1 && ps[2] == e2 && ps[3] == 24);
			trace(result.length == 4 && 
				result[0] == e0 && result[1] == e1 && result[2] == e1 && result[3] == e2);
		}
		
		{ /* collide all Y */
			var erec = new Erec(4);
			
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
			trace(ps.length == 4 && 
				ps[0] == e0 && ps[1] == e1 && ps[2] == e2 && ps[3] == 24);
			trace(result.length == 4 && 
				result[0] == e0 && result[1] == e1 && result[2] == e1 && result[3] == e2);
		}
		
	}
	
}

