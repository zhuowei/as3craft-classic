package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.*;
	import mx.core.*;
	/** displays and allows the user to interact with a Minecraft Classic map. */
	public class MapPane extends UIComponent{
		private var mapWidth:int;
		private var mapHeight:int;
		private var conn:MinecraftConnection;
		private var world:World;
		private var mapData:BitmapData;
		private var map:Bitmap;
		
		private var _scrollX:int=0;
		private var _scrollY:int=0; //y maps to Z
		private var isMouseDown:Boolean=false;
		public var movePlayer:Boolean=true;
		private var moved:Boolean=false;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var beginMouseX:Number;
		private var beginMouseY:Number;
		private var _layer:int=33;
		public var tileset:Tileset;
		public var blockType:int=0x0e;
		public var canBuild:Boolean=true;
//		public var playerLabels:Dictionary=new Dictionary();
		public var motdOptions:MOTDOptions;


		public function MapPane(width:int, height:int, conn:MinecraftConnection){
			mapWidth=width;
			mapHeight=height;
			this.width=width;
			this.height=height;
			this.conn=conn;
			world=conn.world;
			getBuildPermission();
			addMapImage();
			addEventListener("mouseMove", mouseMoveHandler);
			addEventListener("mouseDown", mouseDownHandler);
			addEventListener("mouseUp", mouseUpHandler);
			addEventListener("mouseOut", mouseUpHandler);
			conn.addEventListener("blockChange", function(e:Event):void{trace("changeblk");draw();}, false, 0, true);
			/*world.addEventListener("playerAdded", function(e:Event):void{rebuildPlayers();}, false, 0, true);
			world.addEventListener("playerRemoved", function(e:Event):void{rebuildPlayers();drawPlayers();}, false, 0, true);
			world.addEventListener("playerMove", function(e:Event):void{drawPlayers();}, false, 0, true);
			rebuildPlayers();*/
		}
		private function get tileWidth():int{
			return tileset.tileWidth;
		}
		public function get layer():int{
			return _layer;
		}
		public function set layer(newLayer:int):void{
			if(newLayer>=0&&newLayer<world.yLength){
				_layer=newLayer;
			}
		}
		public function get scrollX():int{
			return _scrollX;
		}
		public function set scrollX(val:int):void{
			if(val>=0 && val <=(world.xLength * tileset.tileWidth)-mapWidth){
				_scrollX=val;
			}
			else{
				if(val<0){
					_scrollX=0;
				}
				if(val>(world.xLength * tileset.tileWidth)-mapWidth){
					_scrollX=(world.xLength * tileset.tileWidth)-mapWidth;
				}
			}
			//draw();
		}
		public function get scrollY():int{
			return _scrollY;
		}
		public function set scrollY(val:int):void{
			if(val>=0 && val<=(world.zLength * tileset.tileWidth)-mapHeight){
				_scrollY=val;
			}
			else{
				if(val<0){
					_scrollY=0;
				}
				if(val>(world.zLength * tileset.tileWidth)-mapHeight){
					_scrollY=(world.zLength * tileset.tileWidth)-mapHeight;
				}
			}
			//draw();
		}
		public function get scrollXBlocks():Number{
			return scrollX/tileWidth;
		}
		public function set scrollXBlocks(val:Number):void{
			scrollX=val*tileWidth;
		}
		/* returns Z coordinates that corresponds to the top of the map */
		public function get scrollZBlocks():Number{
			return scrollY/tileWidth;
		}
		public function set scrollZBlocks(val:Number):void{
			scrollY=val*tileWidth;
		}
		public function get mapWidthBlocks():int{
			return mapWidth/tileWidth;
		}
		public function get mapHeightBlocks():int{
			return mapHeight/tileWidth;
		}
		public function getBuildPermission():void{
			motdOptions=MOTDOptions.parse(conn.serverMOTD, world.playerType==0x64);
			trace(motdOptions.toString());
			canBuild=motdOptions.fly&&motdOptions.jump&&motdOptions.noclip;
		}
		public function addMapImage():void{
			mapData=new BitmapData(mapWidth, mapHeight, false);
			map=new Bitmap(mapData);
			addChild(map);
		}
		public function drawBlock(x:Number, y:Number, type:int):void{
			var tilePos:Point=tileset.lookup(type);
			//trace("painting: " + tilePos.toString() + " " + x + " " + y + " " + type);
			mapData.copyPixels(tileset.data, new Rectangle(tilePos.x, tilePos.y, tileset.tileWidth, tileset.tileWidth), new Point(x,y));
		}
		public function draw():void{
			//trace("start drawing");
			mapData.lock();
			mapData.fillRect(new Rectangle(0,0,mapData.width, mapData.height), 0x000000);
			//trace("scroll:"+scrollXBlocks + "  " + scrollZBlocks + " " + layer);
			for(var l:int=layer-3;l<=layer;l++){ //draw 4 layers down

				for(var i:int=int(scrollXBlocks-1);i<int(scrollXBlocks + mapWidthBlocks)+1;i++){
					//trace(i + "," + scrollZBlocks + ", " + l);
					//trace(mapWidthBlocks + " " + mapHeightBlocks);
					for(var j:int=int(scrollZBlocks-1);j<int(scrollZBlocks + mapHeightBlocks)+1;j++){

						if(world.getBlock(i,l,j)!=0){
							//trace("not air:" +  i + "," + j + ", " + layer +);
							//mapData.fillRect(new Rectangle((((i-scrollXBlocks)*tileWidth)-(scrollX%tileWidth)), (((j-scrollZBlocks)*tileWidth)-(scrollY%tileWidth)), tileWidth, tileWidth), (0xff0000 +(world.getBlock(i,layer,j) * 50)));
							drawBlock((i*tileWidth)-scrollX, (j*tileWidth)-scrollY, world.getBlock(i,l,j));
							//trace((((i-scrollXBlocks)*tileWidth)) + "," + (((j-scrollZBlocks)*tileWidth)) );
						}
					}
				}
				if(l!=layer){
					mapData.colorTransform(new Rectangle(0,0,mapData.width,mapData.height), new ColorTransform(0.6,0.6,0.6));
				}
			}
			mapData.unlock();
			//trace("enddraw");
			//drawPlayers();
						
					
		}/*
		public function rebuildPlayers():void{
			trace("rebuildplayer");
			var p:Player;
			for(var i:Object in world.player){
				p=world.player[i];
				if(playerLabels[p]==null){
					trace("adding" + p.toString());
					var tf:TextField=new TextField();
					tf.text=p.name;
					//trace("updating p" + p.toString());
					//tf.x=(p.x*tileWidth)-scrollX;
					//tf.y=(p.z*tileWidth)-scrollY;
					addChild(tf);
					playerLabels[p]=tf;
				}
			}
			for(var z:Object in playerLabels){
				p=z as Player;
				if(world.player[p.id]==null){
					trace("removing" + p.toString());
					var tf:TextField=playerLabels[i];
					removeChild(tf);
					delete playerLabels[i];
				}
			}
		}
					
		public function drawPlayers():void{
			trace("drawplayers!" + playerLabels);
			for(var i:Object in playerLabels){
				var p:Player = i as Player;
				trace("updating p" + p.toString());
				playerLabels[i].x=(p.x*tileWidth)-scrollX;
				playerLabels[i].y=(p.z*tileWidth)-scrollY;
			}
		}*/
				
		public function pixelXCoordToGrid(x:int):int{
			return x/tileWidth;
		}
		public function mouseMoveHandler(e:MouseEvent):void{
			if(isMouseDown){
				//trace("scroll" + " " + e.localX +" from " + lastMouseX + " " + (e.localX - lastMouseX) + "," + (e.localY - lastMouseY));
				scrollX-=(e.localX - lastMouseX);
				scrollY-=(e.localY - lastMouseY);
				lastMouseX=e.localX;
				lastMouseY=e.localY;
				moved=true;
				if(movePlayer){
					world.curplayer.x=scrollXBlocks+ (mapWidthBlocks/2);
					world.curplayer.y=layer;
					world.curplayer.z=scrollZBlocks + (mapWidthBlocks/2);
					conn.sendPlayerPosition();
					//drawPlayers();
				}
				draw();
			}
		}
		public function mouseDownHandler(e:MouseEvent):void{
			isMouseDown=true;
			moved=false;
			lastMouseX=e.localX;
			lastMouseY=e.localY;
			beginMouseX=e.localX;
			beginMouseY=e.localY;
			trace("click" + lastMouseX);
		}
		public function mouseUpHandler(e:MouseEvent):void{
			isMouseDown=false;
			if(Math.abs(beginMouseX-e.localX)<(tileWidth/4) && Math.abs(beginMouseY-e.localY)<(tileWidth/4)){
				trace("place block");
				//conn.setBlock(int((scrollX+e.localX)/32), layer, int((scrollY+e.localY)/32), blockType);
				blockClick(int((scrollX+e.localX)/tileWidth), layer, int((scrollY+e.localY)/tileWidth));
				draw();
			}
			
		}
		private function blockClick(x:int, y:int, z:int):Boolean{
			trace("distance" + Math.abs(world.curplayer.x-x) + "," + Math.abs(world.curplayer.y-y) + "," + Math.abs(world.curplayer.z-z));
			if(!canBuild){
				return false;
			}
			if(Math.abs(world.curplayer.x-x)>6||Math.abs(world.curplayer.y-y)>6||Math.abs(world.curplayer.z-z)>6){
				trace("distance cannot build:" + Math.abs(world.curplayer.x-x) + "," + Math.abs(world.curplayer.y-y) + "," + Math.abs(world.curplayer.z-z));
				return false;
			}
			if(world.getBlock(x,y,z)==7 && world.playerType!=0x64){ //bedrock and not op
				return false;
			}
			conn.setBlock(x, y, z, blockType, world.getBlock(x,y,z)!=0);
			return true;
		}
		public function centerToPlayer():void{
			scrollXBlocks=world.curplayer.x - (mapWidthBlocks/2);
			scrollZBlocks=world.curplayer.z - (mapHeightBlocks/2);
			layer=world.curplayer.y;
			draw();
		}
		public function destroy():void{
			removeEventListener("mouseMove", mouseMoveHandler);
			removeEventListener("mouseDown", mouseDownHandler);
			removeEventListener("mouseUp", mouseUpHandler);
			world=null;
			conn=null;
			removeChild(map);
			mapData=null;
			map=null;
			tileset=null;
		}
		public function moveUp():void{
			layer++;
			world.curplayer.y=layer;
			conn.sendPlayerPosition();
			draw();
		}
		public function moveDown():void{
			layer--;
			world.curplayer.y=layer;
			conn.sendPlayerPosition();
			draw();
		}
	}
}
