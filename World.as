package {
	import flash.utils.*;
	import flash.errors.*;
	import flash.events.*;
	/** A representation of a Minecraft World. */
	public class World extends EventDispatcher{
		public static var PLAYER_READY:String="playerReady";
		public var player:Dictionary=new Dictionary();	//a map containing players
		public var xLength:int;
		public var yLength:int;
		public var zLength:int;
		public var map:ByteArray=new ByteArray();
		public var playerType:int=0;
		public var isReady:Boolean=false;
		private var gzip:GZIPBytesEncoder = new GZIPBytesEncoder();
		public function addMap(data:ByteArray):void{
			trace("block length: " + data.readInt());
			data.readBytes(map, 0);
		}
		public function ready():void{
			trace("we be ready" + "map length: " + xLength + "," + yLength + "," + zLength + ":" + map.length);
			isReady=true;
			//for(var i:int=0;i<map.length;i++){
				//if(map[i]==43){
					//trace("2slab at offset " + i);
				//}
			//}
			
		}

		public function setBlock(x:int, y:int, z:int, type:int):void{
			if(x>=0&&y>=0&&z>=0&&x<xLength&&y<yLength&&z<zLength){
				map[getBlockIndex(x,y,z)]=type;
			}
		}
		public function getBlock(x:int, y:int, z:int):int{
			if(x>=0&&y>=0&&z>=0&&x<xLength&&y<yLength&&z<zLength){
				return map[getBlockIndex(x,y,z)];
			}
			else{
				return 7; //adminium
			}
		}
		private function getBlockIndex(x:int, y:int, z:int):int{
			//return x + (y * yLength + z) * xLength; 
			return (y * xLength * zLength) + (z * xLength) + x;
		}
		public function get curplayer():Player{
			return player[0xff];
		}
		public function addPlayer(id:int, name:String, x:Number, y:Number, z:Number, yaw:int, pitch:int):void{
			var newplayer:Player=new Player(id);
			newplayer.name=name;
			newplayer.x=x;
			newplayer.y=y;
			newplayer.z=z;
			newplayer.yaw=yaw;
			newplayer.pitch=pitch;
			player[id]=newplayer;
			trace("addplayer" + newplayer);
			dispatchEvent(new Event("playerAdded"));
			if(id==0xff){
				dispatchEvent(new Event("playerReady"));
			}
		}
		public function movePlayerTo(id:int, x:Number, y:Number, z:Number, yaw:int, pitch:int):void{
			trace("moveplayerto: " + id + x + y + z + yaw + pitch);
			var playertomove:Player=player[id];
			if(x){
				playertomove.x=x;
			}
			if(y){
				playertomove.y=y;
			}
			if(z){
				playertomove.z=z;
			}
			if(yaw){
				playertomove.yaw=yaw;
			}
			if(pitch){
				playertomove.pitch=pitch;
			}
			trace("moveto" + player[id].toString());
			dispatchEvent(new Event("playerMove"));
		}
		public function movePlayer(id:int, x:Number, y:Number, z:Number):void{
			movePlayerTo(id,player[id].x+x, player[id].y+y, player[id].z+z, player[id].yaw, player[id].pitch);
		}
		public function rotatePlayer(id:int, yaw:int, pitch:int):void{
			movePlayerTo(id,player[id].x, player[id].y, player[id].z, player[id].yaw, player[id].pitch);
		}
		public function moveRotatePlayer(id:int, x:Number, y:Number, z:Number, yaw:int, pitch:int):void{
			movePlayerTo(id,player[id].x+x, player[id].y+y, player[id].z+z, yaw, pitch);
		}
		public function removePlayer(id:int):void{
			player[id]=null;
			dispatchEvent(new Event("playerRemove"));
		}


	}
}
