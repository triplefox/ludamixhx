package ludamix.contrig;

class ContrigTest {
	
	public static function run() {
		
		var ct = new Contrig();
		ct.addDigital("Up");
		ct.addDigital("Down");
		ct.addDigital("Left");
		ct.addDigital("Right");
		
		trace(ct.isDown("Up") == false);		
		trace(ct.isTap("Up") == false);		
		trace(ct.isHold("Up") == false);		
		ct.setDown("Up");
		trace(ct.isDown("Up") == true);		
		trace(ct.isTap("Up") == true);		
		trace(ct.isHold("Up") == false);		
		ct.pump();
		trace(ct.isDown("Up") == true);		
		trace(ct.isTap("Up") == false);		
		trace(ct.isHold("Up") == true);
		ct.pump();
		trace(ct.isDown("Up") == true);		
		trace(ct.isTap("Up") == false);		
		trace(ct.isHold("Up") == true);
		trace(ct.downLength("Up") == 2);
		trace(ct.upLength("Down") == 3);
		trace(ct.isRelease("Down") == false);
		ct.setUp("Up");
		trace(ct.isRelease("Up") == true);
		trace(ct.upLength("Up") == 0);
		ct.pump();
		trace(ct.isRelease("Up") == false);
		trace(ct.upLength("Up") == 1);
		trace(ct.upLength("Down") == 4);
		
	}
	
}
