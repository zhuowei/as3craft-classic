package {
	public class MOTDOptions{
		private var _hax:Boolean;
		private var _ophax:Boolean;
		private var _fly:Boolean;
		private var _jump:Boolean;
		private var _speed:Boolean;
		private var _noclip:Boolean;
		public function MOTDOptions(hax:Boolean, ophax:Boolean, fly:Boolean, jump:Boolean, speed:Boolean, noclip:Boolean){
			_hax=hax;
			_ophax=ophax;
			_fly=fly;
			_jump=jump;
			_speed=speed;
			_noclip=noclip;
		}
		public function get hax():Boolean{
			return _hax;
		}
		public function get ophax():Boolean{
			return _ophax;
		}
		public function get fly():Boolean{
			return _fly;
		}
		public function get jump():Boolean{
			return _jump;
		}
		public function get speed():Boolean{
			return _speed;
		}
		public function get noclip():Boolean{
			return _noclip;
		}
		public function toString():String{
			return "hax: " + _hax +" ophax: " + _ophax + " fly: " + _fly + " jump: " + _jump + 
				" speed: " + _speed + " noclip: " + noclip;
		}
		public static function parse(motd:String, isOp:Boolean=false):MOTDOptions{
			var hax:Object=parseMOTD(motd, "hax");
			if(hax==null){
				hax=true;
			}
			var ophax:Object=parseMOTD(motd, "ophax");
			if(ophax==null){
				ophax=hax;
			}
			var fly:Object=parseMOTD(motd, "fly");
			if(fly==null){
				fly=hax;
			}
			var jump:Object=parseMOTD(motd, "jump");
			if(jump==null){
				jump=hax;
			}
			var speed:Object=parseMOTD(motd, "speed");
			if(speed==null){
				speed=hax;
			}
			var noclip:Object=parseMOTD(motd, "noclip");
			if(noclip==null){
				noclip=hax;
			}
			if(ophax&&isOp){
				fly=true;
				jump=true;
				speed=true;
				noclip=true;
			}
			return new MOTDOptions(hax, ophax, fly, jump, speed, noclip);
		}
		public static function parseMOTD(motd:String, option:String):Object{
			var index:int=motd.indexOf("+"+option);
			if(index>-1){
				return true;
			}
			index=motd.indexOf("-"+option);
			if(index>-1){
				return false;
			}
			return null;
		}
	}
}
	
