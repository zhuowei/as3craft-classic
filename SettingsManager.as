package {
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	public class SettingsManager extends EventDispatcher{
		public var _tilesetURL:String="terrain.png";
		public var tileset:Tileset;
		public var tempLoader:Loader;
		public var obj:SharedObject;
		public static var manager:SettingsManager=new SettingsManager();
		public function SettingsManager(){
			obj=SharedObject.getLocal("as3craft-classic-Settings");
		}
		public function set tilesetURL(url:String):void{
			obj.data["tilesetURL"]=url;
			obj.flush();
		}
		public function get tilesetURL():String{
			return obj.data.tilesetURL;
		}
		public function loadTileset():void{
			if(tilesetURL==null){
				return;
			}
			trace("loading");
			var l:Loader=new Loader();

			l.load(new URLRequest(tilesetURL));
			l.contentLoaderInfo.addEventListener("complete", loadSetComplete);
			l.contentLoaderInfo.addEventListener("ioError", function(e:Event):void{trace("ioerror" + l);});
			tempLoader=l;
			function loadSetComplete(e:Event):void{
				trace("loaded tileset");
				l.removeEventListener("complete", loadSetComplete);
				tileset=new Tileset((l.content as Bitmap).bitmapData);
				dispatchEvent(new Event("complete"));
			}

		}

	}
}
