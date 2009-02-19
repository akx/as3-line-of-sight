package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.BlendMode;
	import flash.filters.BlurFilter;
	
	public class Light 
	{
		public var position:Point;
		public var lampSpread:Number;
		public var lampAngle:Number;
		public var seeRadius:Number;
		private var ls:LineSeg;
		private var polyPoints:Array;
		public var color:int;
		private var i:int;
		public var alpha:Number;
		public var coneBeginDist:Number;
		public var tempSprite:Sprite;
		public var cachePoly:Boolean;
		public var cacheGfx:Boolean;
		public var gfxDrawn:Boolean;
		public var angInc:Number;
		
		public function Light(position:Point, color:int = 0xFFFFEE, alpha:Number=1, lampSpread: Number = 0, lampAngle: Number = 0, radius: Number = 200, angInc: Number = 2)
		{
			this.position = new Point(position.x, position.y);
			this.lampSpread = lampSpread;
			this.lampAngle = lampAngle;
			this.seeRadius = radius;
			this.color = color;
			this.alpha = alpha;
			this.coneBeginDist = 0;
			this.angInc = angInc;
			cachePoly = false;
			cacheGfx = false;
			gfxDrawn = false;
			
			ls = new LineSeg(this.position, this.position);
		}
		
		public function getPolygon(obs:Array):Array
		{
			if (polyPoints && polyPoints.length && cachePoly) return polyPoints;
			polyPoints = [];
			var startA: Number, endA: Number;
			
			ls.p1 = position;
			if (lampSpread>0)
			{
				//lampAngle = Math.atan2(stage.mouseY - ls.p1.y, stage.mouseX - ls.p1.x)* 180/Math.PI;
				startA = lampAngle-lampSpread;
				endA = lampAngle + lampSpread;
				if (coneBeginDist)
				{
					polyPoints.push(new Point(position.x + Math.cos(lampAngle * Math.PI / 180) * coneBeginDist, position.y + Math.sin(lampAngle * Math.PI / 180) * coneBeginDist));
				}
				else
				{
					polyPoints.push(position);
				}
			}
			else
			{
				startA = 0;
				endA = 360;
			}
			
			for (var a:Number = startA; a < endA; a += angInc)
			{
				var ar:Number = a * Math.PI / 180;
				var outpt:Point=new Point(ls.p1.x + Math.cos(ar) * seeRadius, ls.p1.y + Math.sin(ar) * seeRadius);
				ls.p2 = outpt;
				var ckpt:Point = Obstacle.findClosestIntersection(ls, obs, seeRadius);
				if (ckpt) outpt = ckpt;
				polyPoints.push(outpt);
			}
			return polyPoints;
		}
	
		public function draw(targetSprite:Sprite):void
		{
			if (alpha&&polyPoints)
			{
				if (!tempSprite)
				{
					tempSprite = new Sprite();
					targetSprite.addChild(tempSprite);
					tempSprite.blendMode = BlendMode.ADD;
					if(cacheGfx) tempSprite.cacheAsBitmap = true;
					//tempSprite.filters=[new BlurFilter(9, 9, 2)];
				}
				if (!gfxDrawn || !cacheGfx)
				{
					var g:Graphics = tempSprite.graphics;
					g.clear();
					g.lineStyle();
					var gm:Matrix = new Matrix();
					gm.createGradientBox(seeRadius*2, seeRadius*2, 0, position.x-seeRadius, position.y-seeRadius );
					g.beginGradientFill(GradientType.RADIAL, [color, 0], [alpha, 0], [0, 255], gm);
					//graphics.beginFill(0xFFFF66, 0.3);
					for (i = 0; i < polyPoints.length; i++)
					{
						if (i == 0) g.moveTo(polyPoints[i].x, polyPoints[i].y);
						else g.lineTo(polyPoints[i].x, polyPoints[i].y);
					}
					g.endFill();
					gfxDrawn = true;
				}
				
			}
		}
		
		public function update():void
		{
			
		}
	}
}