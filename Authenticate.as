package {
	import flash.net.*;
	import flash.events.*;
	public class AuthSession extends EventDispatcher{
		private var _username:String;
		private var _password:String;
		private var _url:String;
		public function AuthSession(username:String, password:String, url:String){
			_username=username;
			_password=password;
			_url=url;
		}
		public function connect():void{
			var loader:URLLoader=new URLLoader();
			var request:URLRequest=new URLRequest(_url);
			request.method=URLRequestMethod.POST;
			request.contentType="application/x-www-form-urlencoded";
			request.data=new URLVariables("_lgn="+_username+"|"+_password);
			loader.addEventListener(Event.COMPLETE, completeAuth);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, authFail);
			loader.load(request);
		}
		private function completeAuth(e:Event):void{
			trace(data);
		}
		private function authFail(e:Event):void{
		}
	}
}
