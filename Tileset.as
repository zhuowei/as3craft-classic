package {
	import flash.display.*;
	import flash.geom.*;
	/* Represents a Minecraft tileset. */
	public class Tileset{
		public var tileWidth:int=32;
		public var data:BitmapData;
		//public static var offset:Array=[-1,1,3,2,16,4,15,17,221,222,253,254,18,19,32,33,34,21,54];
		public static var blocks:Array=[];
		include "tilemap_pos.as";
		public function Tileset(data:BitmapData){
			this.data=data;
			this.tileWidth = data.width/16;
		}
		/* look up the location of the block in the tileset. */
		public function lookup(type:int):Point{
			return new Point(blocks[type].x * tileWidth, blocks[type].y * tileWidth);
		}
	}
}
