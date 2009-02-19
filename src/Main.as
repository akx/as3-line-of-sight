package 
{
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.GradientType;
	import flash.display.BlendMode;
	import flash.events.KeyboardEvent;
	import Stats;

	public class Main extends Sprite 
	{
		private var obs:Array;
		private var lights:Array;
		private var dynobs:Array;
		private var maskObj:Sprite;
		private var world:String =
			"##################\n" +
			"#####  #####   ###\n" +
			"#   #  #     # # #\n" +
			"# x    # ### #   #\n" +
			"#   #  # Q#  # # #\n" +
			"##### ##  ## # # #\n" +
			"#    q   x#  # ###\n" +
			"# ### ##  ####   #\n" +
			"# s##  # ###   # #\n" +
			"############ ##  #\n" + 
			"###        #^## ##\n" + 
			"#####.  z    #  ##\n" +
			"######    ########\n" +
			"##################\n"
		;
		private var playerSprite:Sprite;
		private var playerLoc:Point;
		private var playerLight:Light;
		private var playerLightLoc:Point;
		private var keysDown:Object;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function parseWorld():void
		{
			obs = [];
			dynobs = [];
			lights = [];
			var lines:Array = world.split("\n");
			var bs:int = Math.min(stage.stageWidth, stage.stageHeight) / (Math.min(lines.length, lines[0].length));
			var ob:Obstacle;
			var line:String;
			var light:Light;
			keysDown = { };
			for (var y:int = 0; y < lines.length; y++)
			{
				line = lines[y] as String;
				for (var x:int = 0; x < line.length; x++)
				{
					var c:String = line.charAt(x);
					if (c == "#")
					{
						var endX:int = x;
						while (endX < line.length && line.charAt(endX) == "#") endX++;						
						obs.push((new Obstacle((x + endX) / 2.0 * bs -bs/2.0, y * bs).makeSquare((endX - x) * bs, bs).render()));
						x = endX-1;
					}
					else if (c == "x")
					{
						obs.push((new Obstacle(x * bs, y * bs).makeCircle(bs/2.0, 15).render()));
					}
					else if (c == ".")
					{
						obs.push((new Obstacle(x * bs, y * bs).makeWedge(bs, "DL").render()));
					}
					else if (c == "z")
					{
						dynobs.push(new SpinBlockObstacle(x * bs, y * bs, bs*0.33, bs*1.3));
					}
					else if (c == "^")
					{
						light = new Light(new Point(x * bs, y * bs), 0xf8349a, .5, 40, -90, 350, 1);
						light.cachePoly = true;
						light.cacheGfx = true;
						lights.push(light);
					}
					else if (c == "s")
					{
						playerLoc = new Point(x * bs, y * bs);
					}
					else if (c == "q" || c=="Q")
					{
						var color:int = 0x880000;
						if (c == "Q") color = 0x995500;
						light = new SpinLight(new Point(x * bs, y * bs), color, 0.2, 35, 0, 200, 3, 0);
						if (c == "Q") light.lampAngle += 90;
						light.coneBeginDist = 10;
						lights.push(light);
						
						light = new SpinLight(new Point(x * bs, y * bs), color, 0.2, 35, 0, 200, 3, 0);
						light.lampAngle = 180;
						if (c == "Q") light.lampAngle += 90;
						light.coneBeginDist = 10;
						lights.push(light);
						
					}
					
				}
			}
			obs = obs.concat(dynobs);
			for (var i:int = 0; i < obs.length; i++) addChild(obs[i]);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			parseWorld();

			maskObj = new Sprite();
			maskObj.filters = [new BlurFilter(9, 9, 2)];
			maskObj.blendMode = BlendMode.HARDLIGHT;
			maskObj.graphics.clear();
			maskObj.graphics.beginFill(0);
			maskObj.graphics.drawRect(-10, -10, stage.stageWidth+20, stage.stageHeight+20);
			maskObj.graphics.endFill();

			playerLight = new Light(playerLoc, 0xFFFFEE, 0.4, 40, 0, 200);
			playerLightLoc = new Point();
			playerSprite = new Sprite();
			playerSprite.graphics.clear();
			playerSprite.graphics.beginFill(0x333300);
			playerSprite.graphics.drawCircle(0, 0, 12);
			playerSprite.graphics.endFill();
			addChild(playerSprite);
			addChild(maskObj);
			addChild(new Stats());
			addEventListener(Event.ENTER_FRAME, draw);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		public function keyDown(ke: KeyboardEvent): void
		{
			trace(ke.keyCode);
			keysDown[ke.keyCode] = true;
			switch(ke.keyCode)
			{
				case 81:
					maskObj.blendMode = BlendMode.NORMAL;
					break;
				case 82:
					maskObj.blendMode = BlendMode.HARDLIGHT;
					maskObj.alpha = 0.98;
					break;
				case 69:
					maskObj.blendMode = BlendMode.MULTIPLY;
					break;
				case 90:
					maskObj.blendMode = BlendMode.DIFFERENCE;
					break;
				case 66:
					maskObj.filters = [new BlurFilter(9, 9, 2)];
					break;
				case 78:
					maskObj.filters = [];
			}
		}

		public function keyUp(ke: KeyboardEvent): void
		{
			if (keysDown[ke.keyCode]) delete keysDown[ke.keyCode];
		}
		
		public function mouseUp(me: MouseEvent): void
		{
			var ls:LineSeg = new LineSeg(playerLoc, new Point(me.stageX, me.stageY));
			ls.p2 = (Obstacle.findClosestIntersection(ls, obs, ls.length) || ls.p2);
			var color:int = GenUtils.rgbobj2hex(GenUtils.hsv2rgb(Math.random() * 360, 1, 0.2));
			ls.atIntervals(50, function(p:Point):void
			{
				var l:Light = new Light(new Point(p.x, p.y), color, 1);
				
				if (!keysDown[16])
				{
					l.angInc = 1;
					l.cachePoly = true;
					l.cacheGfx = true;
				}
				l.update();
				l.getPolygon(obs);
				l.draw(maskObj);
				lights.push(l);
			});
		}

		
		public function draw(e:Event = null):void
		{
			var i:int;
			playerSprite.x = playerLoc.x;
			playerSprite.y = playerLoc.y;
			if (keysDown[37]||keysDown[65]) playerLoc.x -= 4;
			if (keysDown[39]||keysDown[68]) playerLoc.x += 4;
			if (keysDown[38]||keysDown[87]) playerLoc.y -= 4;
			if (keysDown[40] || keysDown[83]) playerLoc.y += 4;
			for (i = 0; i < dynobs.length; i++) (dynobs[i] as Obstacle).update();
			playerLight.position = playerLoc;
			playerLightLoc.x = (playerLightLoc.x * 5 + stage.mouseX) / 6.0;
			playerLightLoc.y = (playerLightLoc.y * 5 + stage.mouseY) / 6.0;
			playerLight.lampAngle=Math.atan2(playerLightLoc.y - playerLoc.y, playerLightLoc.x - playerLoc.x)* 180.0/Math.PI;
			playerLight.getPolygon(obs);
			playerLight.draw(maskObj);
			for (i = 0; i < lights.length; i++)
			{
				var light:Light = (lights[i] as Light);
				light.update();
				light.getPolygon(obs);
				light.draw(maskObj);
			}
		}
	}
	
}