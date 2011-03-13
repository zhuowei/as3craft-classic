package {
	import flash.display.*;
	/** a test case for the MCURLDecoder class. */
	public class TestDecode extends Sprite{
		public function TestDecode(){
			var result:Object=MCURLDecoder.decode("mc://123.234.34.45:25565/username/c0a1433eca514e285f667356b2bde709");
			for(var i:Object in result){
				trace(i+"="+result[i]);
			}
			trace("done");
		}
	}
}
