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
		"Help! I'm trapped in an app factory!"
	];
	public static function getSplash():String{
		return messages[Math.floor(Math.random() * messages.length)];
	}
}

}
