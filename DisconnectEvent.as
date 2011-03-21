package { 
import flash.events.Event;
public class DisconnectEvent extends Event{
	private var _kick:Boolean;
	private var _reason:String;
	public function get kick():Boolean{
		return _kick;
	}
	public function get reason():String{
		return _reason;
	}
	public function DisconnectEvent(type:String, kick:Boolean, reason:String=null, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
			_kick=kick;
			_reason=reason;
	}
}
}
