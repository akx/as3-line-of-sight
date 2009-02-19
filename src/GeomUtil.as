package 
{
	import flash.display.PixelSnapping;
	import flash.geom.Point;
	
	public class GeomUtil 
	{
		static public function lineIntersect(p1: Point, p2: Point, p3: Point, p4: Point): Point
		{
			var xi:Number, yi:Number, d:Number, a:Number, b:Number;
			if (p1.x == p3.x && p2.x == p4.x && p1.y == p3.y && p2.y == p4.y)
				return new Point((p1.x + p2.x) / 2.0, (p1.y + p2.y) / 2.0);

			d = ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y));
			if (d == 0) return null;


			a = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / d;
			b = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / d;
			if (a<0.0 || a>1 || b<0 || b>1) return null;
			
			if (a >= 0.0 && a <= 1.0)
			{
				xi = p1.x + a * (p2.x - p1.x);
				yi = p1.y + a * (p2.y - p1.y);
				return new Point(xi, yi);
			}	
			if (b >= 0.0 && b <= 1.0)
			{
				xi = p3.x + b * (p4.x - p3.x);
				yi = p3.y + b * (p4.y - p3.y);
				return new Point(xi, yi);
			}
			return null;
		}
		
		static public function lineIntersectLS(ls1: LineSeg, ls2: LineSeg): Point
		{
			return lineIntersect(ls1.p1, ls1.p2, ls2.p1, ls2.p2);
		}
		
		static public function pointDistanceFast(p1: Point, p2: Point): Number
		{
			var xx: Number = p2.x - p1.x;
			var yy: Number = p2.y - p1.y;
			return (xx * xx + yy * yy);
		}
	}
	
}