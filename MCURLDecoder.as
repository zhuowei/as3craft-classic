package {
	import flash.utils.*;
	/** Decodes a Minecraft Direct Connect URL, as used by WoM.*/
	public class MCURLDecoder{
		/** Decodes a mc:// url. 
		 * @return an Object with a host, port, username and key value. 
		 * @throws URIError when the beginning of the URL does not match mc://. */
		public static function decode(url:String):Object{
			var retval:Object=new Object();
			if(url.substring(0,5)!="mc://"){
				throw new URIError(url + " does not match beginning: should be mc://; is "+ url.substring(0,5));
			}
			var urlparts:Array=url.substring(5).split("/");
			trace(urlparts);
			var hostparts:Array=urlparts[0].split(":");
			retval["host"]=hostparts[0];
			retval["port"]=hostparts[1];
			retval["username"]=urlparts[1];
			retval["key"]=urlparts[2];
			return retval;
		}
	}
}
