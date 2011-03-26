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
			colorize();
		}
		/* look up the location of the block in the tileset. */
		public function lookup(type:int):Point{
			if(type>=0&&type<blocks.length){
				return new Point(blocks[type].x * tileWidth, blocks[type].y * tileWidth);
			}
			return blocks[1];//Error handler block of doom!
		}
		/** Colourize the grass and the leaves block from Beta tilesets.*/
		private function colorize():void{
			var bColor:ColorTransform=new ColorTransform(0,1,0);
			var bPoint:Point=lookup(2);
			data.colorTransform(new Rectangle(bPoint.x, bPoint.y, tileWidth, tileWidth), bColor);
			bPoint=lookup(18); //leaves
			data.colorTransform(new Rectangle(bPoint.x, bPoint.y, tileWidth, tileWidth), bColor);
		}
	}
}
