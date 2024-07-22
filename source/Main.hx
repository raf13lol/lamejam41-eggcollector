package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import states.*;

class Main extends Sprite
{
    public static var bgColor:Int = 0xffebe126;
    public static var font:String = "assets/fonts/font.ttf";

	public function new()
	{
		super();
		addChild(new FlxGame(640, 360, MenuState, 60, 60, true));
        FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();
        // tada
        FlxG.sound.volumeUpKeys = [];
        FlxG.sound.volumeDownKeys = [];
        FlxG.sound.muteKeys = [];
        FlxG.sound.volume = 0.4;
        FlxG.keys.preventDefaultKeys = [ALT, TAB, ENTER];
        FlxG.mouse.load("assets/images/cursor.png");
        SaveFile.init();
    }

    public static function playButtonSound()
    {
        var snd = FlxG.sound.play("assets/sounds/buttononclick.ogg");
        snd.persist = true;
        snd.autoDestroy = true;
    }
}
