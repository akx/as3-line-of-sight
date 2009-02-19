package 
{
	public class GenUtils 
	{
		public static function hsv2rgb(h:Number, s:Number, v:Number): Object
		{
			v *= 255;
			if (s == 0)
			{
				return { r: v, g: v, b: v };
			}
			else
			{
				h /= 60.0;
				var i:int = h;
				var f:Number = h - i;
				var p:Number = v * (1.0 - s);
				var q:Number = v * (1.0 - s * f);
				var t:Number = v * (1.0 - s * (1.0 - f));
				if (i == 0) return { r: v, g: t, b: p };
				else if (i == 1) return { r: q, g: v, b: p };
				else if (i == 2) return { r: p, g: v, b: t };
				else if (i == 3) return { r: p, g: q, b: v };
				else if (i == 4) return { r: t, g: p, b: v };
				else if (i == 5) return { r: v, g: p, b: q };
				else return { r: v, g: p, b: q };
			}
		}
		
		public static function rgbobj2hex(o:Object):int
		{
			var r:int = o.r;
			var g:int = o.g;
			var b:int = o.b;
			return r << 16 | g << 8 | b;
		}
		
		public static function hex2rgbobj(hex: int):Object
		{
			return { r: (hex >> 16) & 0xFF, g: (hex >> 8) & 0xFF, b: hex & 0xFF };
		}
		
		public static function rgbmix(a: Object, b: Object, alpha: Number): Object
		{
			var beta:Number = 1.0 - alpha;
			var res:Object={ r: a.r * beta + b.r * alpha, g: a.g * beta + b.g * alpha, b: a.b * beta + b.b * alpha };
			return res;
			
		}
	}
	
}