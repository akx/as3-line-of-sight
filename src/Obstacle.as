package 
{
	import flash.display.ActionScriptVersion;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Obstacle extends Sprite 
	{
		public var points:Array;
		public var bbox:Rectangle;
		
		public function Obstacle(x: Number, y:Number)
		{
			this.x = x;
			this.y = y;
			this.bbox = new Rectangle(0, 0, 0, 0);
		}
		
		public function makeSquare(w: Number, h:Number): Obstacle
		{
			w /= 2.0;
			h /= 2.0;
			points = [
				new Point( -w, -h),
				new Point( w, -h),
				new Point( w, h),
				new Point( -w, h)
			];
			updateBbox();
			return this;
		}
		
		public function makeCircle(r: Number, resolution:int = 10): Obstacle
		{
			var q:Number = (1.0 / Number(resolution)) * Math.PI * 2.0;
			points = [];
			for (var i:int = 0; i < resolution; i++)
			{
				var an:Number = i * q;
				points.push(new Point(Math.cos(an) * r, Math.sin(an) * r));
			}
			updateBbox();
			return this;
		}
		
		public function makeWedge(size: Number, cornerOrientation: String): Obstacle
		{
			var cornerX:Number, cornerY:Number;
			
			points = [];
			
			cornerY = size / 2.0 * (cornerOrientation.substr(1,1) == "U"? -1: 1);
			cornerX = size / 2.0 * (cornerOrientation.substr(0,1) == "L"? 1: -1);
			points.push(new Point(cornerX, cornerY));
			points.push(new Point(cornerX, -cornerY));
			points.push(new Point( -cornerX, cornerY));
			updateBbox();
			return this;
		}
		
		public function rotateGeometry(a:Number):void
		{
			var nx: Number, ny: Number;
			var ca: Number, sa: Number;
			ca = Math.cos(a);
			sa = Math.sin(a);
			for (var i:int = 0; i < points.length; i++)
			{
				nx = points[i].x * ca - points[i].y * sa;
				points[i].y = points[i].x * sa + points[i].y * ca;
				points[i].x = nx;
			}
		}
		
		public function updateBbox():void
		{
			var minX:Number, minY:Number, maxX: Number, maxY:Number;
			minX = maxX = points[0].x;
			minY = maxY = points[0].y;
			for (var i:int = 0; i < points.length; i++)
			{
				var p:Point = (points[i] as Point);
				if (p.x < minX) minX = p.x;
				if (p.y < minY) minY = p.y;
				if (p.x > maxX) maxX = p.x;
				if (p.y > maxY) maxY = p.y;
			}
			bbox = new Rectangle(minX, minY, Math.abs(maxX - minX), Math.abs(maxY - minY));
		}
		
		public function getLocBbox(): Rectangle
		{
			return new Rectangle(x + bbox.x, y + bbox.y, bbox.width, bbox.height);
		}
		
		public function render():Obstacle
		{
			graphics.clear();
			graphics.lineStyle();// -1, 0xFF00FF);
			graphics.beginFill(0x806040);
			for (var i:int = 0; i < points.length; i++)
			{
				var p:Point=(points[i] as Point);
				if (i == 0) graphics.moveTo(p.x, p.y);
				else graphics.lineTo(p.x, p.y);
			}
			graphics.endFill();
			cacheAsBitmap = true;
			//graphics.lineStyle(1, 0xFF00);
			//graphics.drawRect(bbox.x, bbox.y, bbox.width, bbox.height);
			return this;
		}
		
		public function intersectionPoints(ls: LineSeg): Array
		{
			var out:Array = [];
			var n:int = points.length;
			var c:Point = new Point(x, y);
			if (n <= 1) return out;
			var lsp1:Point = ls.p1.subtract(c);
			var lsp2:Point = ls.p2.subtract(c);
			
			for (var i:int = 1; i < n + 1; i++)
			{
				//trace(n, i, [(i-1) % n , i % n]);
				var p1:Point = (points[(i -1) % n] as Point);
				var p2:Point = (points[(i % n)] as Point);
				var ip:Point = GeomUtil.lineIntersect(lsp1, lsp2, p1, p2);
				if (ip) out.push(ip.add(c));
			}
			return out;
		}
		
		public function update():void
		{
			
		}
		
		public static function findClosestIntersection(ls: LineSeg, obs: Array, maxds: Number): Point
		{
			var box:Rectangle = ls.getBox();
			var lcips:Array = [];
			var i:int = 0;
			for (i = 0; i < obs.length; i++)
			{
				var ob:Obstacle = (obs[i] as Obstacle);
				if (box.height==0||box.width==0||ob.getLocBbox().intersects(box)) lcips = lcips.concat(ob.intersectionPoints(ls));
			}
			if (lcips.length)
			{
				var minds:Number = maxds*maxds+5;
				var minpt:Point;
				for (i = 0; i < lcips.length; i++)
				{
					//if (a == 30) graphics.drawCircle(lcips[i].x, lcips[i].y, 5);
					var ds:Number = GeomUtil.pointDistanceFast(ls.p1, lcips[i]);
					if (ds < minds)
					{
						minds = ds;
						minpt = lcips[i];
					}
				}
				return minpt;
			}
			return null;
		}
	}
	
}