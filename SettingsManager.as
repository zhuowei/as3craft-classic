package {
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	public class SettingsManager{
		public var tilesetURL:String="terrain.png";

		public function loadTileset():void{/*
			trace("loading");
			var l:Loader=new Loader();
			l.addEventListener("complete", loadSetComplete);
			l.addEventListener("ioError", function(e:Event):void{trace("ioerror" + l);});
			l.load(new URLRequest(tilesetURL));
			function loadSetComplete(e:Event):void{
				trace("loaded tileset");
				l.removeEventListener("complete", loadSetComplete);
				tileset=new Tileset((l.content as Bitmap).bitmapData);
			}*/
		}
	}
}
