package 
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class LineSeg extends Sprite
	{
		public var p1: Point;
		public var p2: Point;
		
		public function LineSeg(p1: Point, p2: Point): void
		{
			this.p1 = p1;
			this.p2 = p2;
		}
		
		public function render(): void
		{
			graphics.clear();
			graphics.lineStyle(1, 0xFF0000);
			graphics.moveTo(p1.x, p1.y);
			graphics.lineTo(p2.x, p2.y);
		}
		
		public function getBox():Rectangle
		{
			var r:Rectangle = new Rectangle(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y);
			if (r.width <= 0)
			{
				r.x += r.width;
				r.width *= -1;
			}
			if (r.height <= 0)
			{
				r.y += r.height;
				r.height *= -1;
			}
			
			return r;
		}
		
		public function get length():Number
		{
			return ((this.p2.subtract(this.p1)).length);
		}
		
		public function atIntervals(interval:Number,f:Function):void
		{
			var p:Point = new Point(p1.x, p1.y);
			var count:int = Math.floor(this.length / interval);
			var deltaX:Number = (p2.x-p1.x) / count;
			var deltaY:Number = (p2.y-p1.y) / count;
			while (count--)
			{
				p.x += deltaX;
				p.y += deltaY;
				f(p);
			}
		}
	}
	
}