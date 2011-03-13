package {
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.*;
	[SWF(backgroundColor="#FFFFFF", frameRate="15", width="1024", height="600")]
	public class Test extends Sprite{
		public var conn:MinecraftConnection;
		public var world:World;
		private var chatBox:TextField;
		private var mapPane:MapPane;
		[Embed(source="terrain.png")]
		private var tileEmbed:Class;
		public function Test(){
			chatBox=new TextField();
			chatBox.x=600;
			chatBox.y=0;
			chatBox.text="Foo! Chat messages will appear here.\n";
			chatBox.width=300;
			chatBox.height=200;
			addChild(chatBox);
			connect();
			//setInterval(mapPane.draw, 5000);
		}
		public function connect():void{
			conn=new MinecraftConnection("127.0.0.1", 25565, "AS3Craft", "Eggs");
			conn.connect();
			world=conn.world;
			var tileset:Tileset = new Tileset((new tileEmbed() as Bitmap).bitmapData);
			mapPane=new MapPane(600,600, conn);
			mapPane.x=0;
			mapPane.y=0;
			mapPane.tileset=tileset;
			addChild(mapPane);
			conn.addEventListener(ChatEvent.RECIEVED, messageRecieved);
			conn.world.addEventListener("playerReady", playerReadyHandler);
			setInterval(moveForward, 3000);
		}
		public function messageRecieved(event:ChatEvent):void{
			trace("message" + event.message);
			chatBox.appendText(event.message + "\n");
		}
		public function moveForward():void{
			if(!world.curplayer){
				return;
			}
			//world.curplayer.x-=1;
			//conn.sendPlayerPosition();
			conn.setBlock(int(world.curplayer.x), int(world.curplayer.y), int(world.curplayer.z), 0x2E);
			//mapPane.scrollXBlocks=world.curplayer.x - (mapPane.mapWidthBlocks/2);
			//mapPane.scrollZBlocks=world.curplayer.z - (mapPane.mapHeightBlocks/2);
			//mapPane.layer=world.curplayer.y;
			//mapPane.draw();
			world.curplayer.y-=1;
			mapPane.layer=world.curplayer.y;
			mapPane.draw();
			
		}
		public function playerReadyHandler(e:Event):void{
			trace("player be ready");
			conn.sendPlayerPosition();
			mapPane.scrollXBlocks=world.curplayer.x - (mapPane.mapWidthBlocks/2);
			mapPane.scrollZBlocks=world.curplayer.z - (mapPane.mapHeightBlocks/2);
			mapPane.layer=world.curplayer.y;
			mapPane.draw();
		}
	}
}
