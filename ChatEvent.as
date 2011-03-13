package {
	import flash.events.Event;
	public class ChatEvent extends Event{
		public static var RECIEVED:String="recieved";
		private var _message:String;
		private var _id:int;
		public function ChatEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, message:String="", userID:int=-1){
			super(type,bubbles,cancelable);
			_message=message;
			_id=id;
		}
		public function get message():String{
			return _message;
		}
		public function get id():int{
			return _id;
		}
	}
}
		
