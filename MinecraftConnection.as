package {
	import flash.net.*;
	import flash.events.*;
	import flash.errors.*;
	import flash.utils.*;
	/** a connection to a Minecraft Server. */
	public class MinecraftConnection extends EventDispatcher{
		public static var DATA_RECIEVED:String="dataRecieved";
		public static var HANDSHAKE:String="handshake";
		/** the socket that this MinecraftConnection uses to connect. */
		public var socket:Socket;
		/** the minecraft World that this operates on.*/
		public var world:World;
		private var url:String;
		private var port:int;
		private var loginKey:String;
		private var username:String;
		private var hash:String;
		private var entityID:int;
		private var _serverName:String;
		private var _serverMOTD:String;
		private var currentPacketId:int;
		private var buffer:ByteArray;
		private var gzipLevel:ByteArray=new ByteArray();
		//include "minecraftprotocolcodes.as";
		private var loginSent:Boolean=false;
		private var playerPositionTimer:uint;

		/** the name of the server that this Connection is connected to. */
		public function get serverName():String{
			return _serverName;
		}
		/** the Message of the Day of the server that this Connection is connected to. */
		public function get serverMOTD():String{
			return _serverMOTD;
		}
		public function MinecraftConnection(url:String, port:int, username:String, loginKey: String){
			this.username=username;
			this.loginKey=loginKey;
			this.url=url;
			this.port=port;
			buffer=new ByteArray();
			world=new World();
		}
		public function connect():void{
			socket=new Socket();
			socket.addEventListener(Event.CONNECT, connectHandler);
			socket.addEventListener(Event.CLOSE, closeHandler);
			socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, dataRecieveHandler);
			
			socket.connect(url, port);
		}
		private function dataRecieveHandler(e:ProgressEvent):void{
			//trace(e.toString() + e.bytesLoaded);
			socket.readBytes(buffer, buffer.length, socket.bytesAvailable);
			var continueRead:Boolean=true;
			var x:int;
			var y:int;
			var z:int;
			var playerID:int;
			var yaw:int;
			var pitch:int;
			while(continueRead){
				buffer.position=0;
				try{
				var pktid:int=buffer.readUnsignedByte();
				//trace(pktid);
				switch(pktid){
					case 0x00: //server ID
						trace("server id");
						buffer.readUnsignedByte();
						trace("1")
						_serverName=buffer.readUTFBytes(64);
						trace("2");
						_serverMOTD=buffer.readUTFBytes(64);
						trace("3");
						world.playerType=buffer.readUnsignedByte();
						trace("server id done");
						dispatchEvent(new Event(HANDSHAKE));
						break;
					case 0x01:
						//trace("ping");
						break;
					case 0x02:
						break;
					case 0x03:
						//trace("addchunk");
						var length:int=buffer.readShort();
						//trace("length" + length);
						buffer.readBytes(gzipLevel, gzipLevel.length, length);
						if(length<1024){
							buffer.position+=(1024-length);
						}
						//world.addCompressedChunk(chunkArray, buffer.readUnsignedByte());
						var percent:int= buffer.readUnsignedByte();
						dispatchEvent(new ProgressEvent(DATA_RECIEVED, false, false, percent, 100));
						break;
					case 0x04:
						world.xLength=buffer.readShort();
						world.yLength=buffer.readShort();
						world.zLength=buffer.readShort();
						var mapData:ByteArray=(new GZIPBytesEncoder()).uncompressToByteArray(gzipLevel);
						world.addMap(mapData);
						world.ready();
						playerPositionTimer=setInterval(sendPlayerPosition, 500);
						break;
					case 0x06:
						x=buffer.readShort();
						y=buffer.readShort();
						z=buffer.readShort();
						var type:int=buffer.readUnsignedByte();
						//trace("setblock: " + x + " "  + y +" " + z + " from " + world.getBlock(x,y,z) + " to " + type);
						world.setBlock(x,y,z,type);
						//trace("blockchange");
						dispatchEvent(new Event("blockChange"));
						break;
					case 0x07:
						playerID=buffer.readUnsignedByte();
						var playerName:String = trimStr(buffer.readUTFBytes(64));
						x=buffer.readShort();
						y=buffer.readShort();
						z=buffer.readShort();
						yaw=buffer.readUnsignedByte();
						pitch=buffer.readUnsignedByte();
						world.addPlayer(playerID, playerName, x/32, y/32, z/32, yaw, pitch);
						break;
					case 0x08: //teleport
						trace("teleport");
						playerID=buffer.readUnsignedByte();
						x=buffer.readShort();
						y=buffer.readShort();
						z=buffer.readShort();
						yaw=buffer.readUnsignedByte();
						pitch=buffer.readUnsignedByte();
						world.movePlayerTo(playerID, x/32, y/32, z/32, yaw, pitch);
						break;
					case 0x09://change in position & rotation
						trace("posrot");
						playerID=buffer.readUnsignedByte();
						x=buffer.readByte();
						y=buffer.readByte();
						z=buffer.readByte();
						yaw=buffer.readUnsignedByte();
						pitch=buffer.readUnsignedByte();
						world.moveRotatePlayer(playerID, x/32, y/32, z/32, yaw, pitch);
						break;
					case 0x0a://change in position
						trace("pos");
						playerID=buffer.readUnsignedByte();
						x=buffer.readByte();
						y=buffer.readByte();
						z=buffer.readByte();
						world.movePlayer(playerID, x/32, y/32, z/32);
						break;
					case 0x0b: //change in rotation
						trace("rot");
						playerID=buffer.readUnsignedByte();
						yaw=buffer.readUnsignedByte();
						pitch=buffer.readUnsignedByte();
						world.movePlayerTo(playerID, null, null, null, yaw, pitch);
						break;
					case 0x0c:
						world.removePlayer(buffer.readUnsignedByte());
						break;
					case 0x0d:
						playerID=buffer.readUnsignedByte();
						recieveMessageHandler(playerID, trimStr(buffer.readUTFBytes(64)));
						break;
					case 0x0e:
						kickHandler(trimStr(buffer.readUTFBytes(64)));
						break;
					case 0x0f:
						world.playerType=buffer.readUnsignedByte();
						break;
					default:
						trace("Oh no! unknown packet!!!");
						break;
				}
				var temp:ByteArray=new ByteArray();
				temp.position=0;
				//trace("bufferpos: " +  buffer.position);
				buffer.readBytes(temp);
				//trace("templength: " + temp.length + "bufferlength: " + buffer.length);
				buffer=temp;
				//trace("done copying buffer");
				
			}
			catch(e:EOFError){
				//trace("eof");
				continueRead=false;
			}
			catch(e:Error){
				trace("bad thing: Error" + e);
				continueRead=false;
			}
		    }
			//trace("down dog");
			
		}
		/** Sends initial identification for the player.*/
		private function sendPlayerID(name:String, key:String):void{
			socket.writeByte(0x00);
			socket.writeByte(0x07);
			socket.writeUTFBytes(padOut(name));
			socket.writeUTFBytes(padOut(key));
			socket.writeByte(0x42); //unused
			socket.flush();
		}
		/* sends the setBlock message. */
		private function sendSetBlock(x:int, y:int, z:int, mode:int, type:int):void{
			socket.writeByte(0x05);
			socket.writeShort(x);
			socket.writeShort(y);
			socket.writeShort(z);
			socket.writeByte(mode);
			socket.writeByte(type);
			socket.flush();
		}
		/** Sends a chat message. */
		public function sendMessage(msg:String):void{
			socket.writeByte(0x0d);
			socket.writeByte(0xff);//current user
			socket.writeUTFBytes(padOut(msg));
			socket.flush();
		}
		private function connectHandler(e:Event):void{
			trace("go");
			sendInitialPackets();
			
		}
		public function sendPlayerPosition():void{
			if(world.curplayer && world.isReady){
				var x:int=world.curplayer.x*32;
				var y:int=world.curplayer.y*32;
				var z:int=world.curplayer.z*32;
				socket.writeByte(0x08);
				socket.writeByte(0xff);
				socket.writeShort(x);
				socket.writeShort(y);
				socket.writeShort(z);
				socket.writeByte(world.curplayer.yaw);
				socket.writeByte(world.curplayer.pitch);
				socket.flush();
				//trace("sent" + world.curplayer);
			}
		}
		public function setBlock(x:int, y:int, z:int, type:int, isDelete:Boolean=false):void{
			world.setBlock(x,y,z,(isDelete?0x00:type));
			sendSetBlock(x,y,z,(isDelete?0x00:0x01),type);
		}
		private function ioErrorHandler(e:Event):void{
			trace("io error! " + e);
		}
		private function closeHandler(e:Event):void{
			trace("socket closed!");
			dispatchEvent(new DisconnectEvent("disconnect", true, "The socket was closed."));
			cleanUp();
		}
		private function recieveMessageHandler(id:int, msg:String):void{
			trace(msg + id);
			dispatchEvent(new ChatEvent(ChatEvent.RECIEVED, false, false, msg, id));
		}
		private function sendInitialPackets():Boolean{
			sendPlayerID(username, loginKey);
			return true;
		}

		public function disconnect():void{
			/*socket.writeByte(0xff);
			socket.writeUTFBytes(padOut("Disconnecting..."));
			socket.flush();*/
			socket.close();
			dispatchEvent(new DisconnectEvent("disconnect", false));
			cleanUp();
		}
		public function kickHandler(msg:String):void{
			dispatchEvent(new DisconnectEvent("disconnect", true, msg));
			socket.close();
			cleanUp();
		}
		private function cleanUp():void{
			//dispatchEvent(new Event("disconnect"));
			if(playerPositionTimer){
				clearInterval(playerPositionTimer);
			}
		}
		private function trimStr(str:String):String{
			for(var i:int=0;i<str.length-1;i++){
				if(str.charAt(i)==" " && str.charAt(i+1)==" "){
					return str.substring(0,i);
				}
			}
			return str;
		}
		private function padOut(str:String):String{
			if(str.length>64){
				return str.substr(0,64);
			}
			var retval:String="";
			for(var i:int=0;i<64-str.length;i++){
				retval=retval.concat(" ");
			}
			return str.concat(retval);
		}

	}
}
