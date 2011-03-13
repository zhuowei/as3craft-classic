package {
	/** represents a Minecraft player. */
	public class Player{
		public var id:int;
		public var name:String;
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var yaw:int;
		public var pitch:int;
		public function Player(id:int){
			super();
			this.id=id;
		}
		public function toString():String{
			return "name: " + name + "id: " + id + " " + x + ", " + y + ", " + z + ": " + yaw + " " + pitch;
		}
	}
}
