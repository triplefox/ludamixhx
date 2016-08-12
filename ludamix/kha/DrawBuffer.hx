package ludamix.kha;
import kha.math.FastMatrix3;

class DrawBuffer {
	
	public var drawContext = new GrowVector1<DrawType>(1);
	public var drawInt = new GrowVector8<Int>(8);
	public var drawInt2 = new GrowVector8<Int>(8);
	public var drawFloat = new GrowVector8<Float>(8);
	public var drawFloat2 = new GrowVector8<Float>(8);
	public var drawString = new GrowVector8<String>(8);
	public var drawMatrix = new GrowVector8FastMatrix3(8);
	public var drawScissor = new GrowVector8<Int>(8);
	public var drawScissorOn = new GrowVector1<Bool>(2);
	
	public function new() {}
	
	public inline function writeRectangle(
		transform0 : FastMatrix3, transform1 : FastMatrix3,
		border : Int, fill : Int, x0 : Float, y0 : Float, w0 : Float, h0 : Float, 
		x1 : Float, y1 : Float, w1 : Float, h1 : Float, strength : Float) 
	{
		drawContext.push(DrawType.DTRectangle);
		drawInt.push(border, fill, 0, 0, 0, 0, 0, 0);
		drawFloat.push(x0, y0, w0, h0, x1, y1, w1, h1);
		drawFloat2.push(strength, 0., 0., 0., 0., 0., 0., 0.);
		drawMatrix.push();
		drawMatrix.setidx2(drawMatrix.l-1, 0, transform0);
		drawMatrix.setidx2(drawMatrix.l-1, 1, transform1);
	}
	
	public inline function writeImage(
		transform0 : FastMatrix3, transform1 : FastMatrix3,
		color : Int, ox : Float, oy : Float, ow : Float, oh : Float,
		x0 : Float, y0 : Float, w0 : Float, h0 : Float, 
		x1 : Float, y1 : Float, w1 : Float, h1 : Float, page : Int) 
	{
		drawContext.push(DrawType.DTImage);
		drawInt.push(color, page, 0, 0, 0, 0, 0, 0);
		drawFloat.push(x0, y0, w0, h0, x1, y1, w1, h1);
		drawFloat2.push(ox, oy, ow, oh, 0., 0., 0., 0.);
		drawMatrix.push();
		drawMatrix.setidx2(drawMatrix.l-1, 0, transform0);
		drawMatrix.setidx2(drawMatrix.l-1, 1, transform1);
	}
	
	public inline function writeScissorMode(
		x0:Int,y0:Int,w0:Int,h0:Int,
		x1:Int,y1:Int,w1:Int,h1:Int,
		on:Bool) {
		drawContext.push(DrawType.DTSetScissorMode);
		drawScissor.push(x0,y0,w0,h0,x1,y1,w1,h1);
		drawScissorOn.push(on);
	}
	
	public inline function resetRead() {
		drawContext.r = 0;
		drawInt.r = 0;
		drawFloat.r = 0;
		drawInt2.r = 0;
		drawFloat2.r = 0;
		drawString.r = 0;
		drawMatrix.r = 0;
		drawScissor.r = 0;
		drawScissorOn.r = 0;
	}

	public inline function resetWrite() {
		drawContext.l = 0;
		drawContext.r = 0;
		drawInt.l = 0;
		drawInt.r = 0;
		drawFloat.l = 0;
		drawFloat.r = 0;
		drawInt2.l = 0;
		drawInt2.r = 0;
		drawFloat2.l = 0;
		drawFloat2.r = 0;
		drawString.l = 0;
		drawString.r = 0;
		drawMatrix.reset();
		drawScissor.l = 0;
		drawScissor.r = 0;
		drawScissorOn.l = 0;
		drawScissorOn.r = 0;
	}
	
}

