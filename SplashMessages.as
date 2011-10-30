package {
public class SplashMessages{
	public static const messages:Array = [
		"10% less bugs!", 
		"This is not splash text!",
		"Random splash!",
		"Might actually work!",
		"Good luck!",
		"Splash message found!",
		"Self reference: like this", 
		"Help! I'm trapped in an app factory!",
		"Now with better documentation!",
		"Classic!",
		"Adobe Flex!",
		"twitter.com/zhuowei :)",
		"Now with texture pack!",
		"Textured with MSPaint!",
		"MSPainterly Pack!",
		"Built on Linux!",
		"Canadian!",
		"Free to play!",
		"test\";drop table 'splashmessages';--"
	];
	public static function getSplash():String{
		return messages[Math.floor(Math.random() * messages.length)];
	}
}

}
