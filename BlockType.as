package {
	/** Represents a type of Minecraft block. 
	 * @see BlockDropDownList
	*/
	public class BlockType{
		public var type:uint;
		public var label:String;
		public function BlockType(type:uint, label:String){
			this.type=type;
			this.label=label;
		}
		public function toString():String{
			return label;
		}
	}
}
