package 
{
	import flash.geom.Point;
	public class SpinLight extends Light 
	{
		public var blinkSpeed:int;
		public var blinkPhase:int;
		public var spinSpeed:Number;
		public var visible:Boolean;
		
		public function SpinLight(position:Point, color:int = 0xFFFFEE, alpha:Number = 1, lampSpread: Number = 0, lampAngle: Number = 0, radius: Number = 200, spinSpeed: Number = 3, blinkSpeed: int = 10, blinkPhase: int = 0)
		{
			super(position, color, alpha, lampSpread, lampAngle, radius);
			this.blinkSpeed = blinkSpeed;
			this.blinkPhase = blinkPhase;
			this.spinSpeed = spinSpeed;
			this.visible = true;
		}
		
		public override function update():void
		{
			lampAngle += spinSpeed;
			if (blinkSpeed)
			{
				blinkPhase++;
				if (blinkPhase >= blinkSpeed)
				{
					blinkPhase = 0;
					visible = !visible;
				}
				if (!visible) alpha *= 0.8;
				else alpha = 1;
			}
			else
			{
				alpha = 1;
			}
		}
	}
	
}