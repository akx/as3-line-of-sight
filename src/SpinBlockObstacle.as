package 
{
	public class SpinBlockObstacle extends Obstacle
	{
		public var w:Number;
		public var h:Number;
		public var ad:Number;
		public var origPoints:Array;
		public var angle:Number;
		public function SpinBlockObstacle(x: Number, y:Number, w: Number, h: Number, angle:Number = 0, ad: Number = 0.02)
		{
			super(x, y);
			this.w = w;
			this.h = h;
			this.ad = ad;
			this.angle = angle;
			makeSquare(w, h);
		}		
		
		public override function update(): void
		{
			rotateGeometry(ad);
			updateBbox();
			render();
		}
	}
	
}