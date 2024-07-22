package;

import openfl.Lib;
import flixel.FlxG;

class  SaveFile 
{
    public static var eggsGot:Int = 0;
    public static var eggMultiplier:Float = 1.0;
    public static var won:Bool = false;
    public static var tutorials:Array<Bool> = [false, false, false];
    public static var fullscreen:Bool = false;
    public static var calibration:Int = 30;

    public static function init()
    {
        FlxG.save.bind("egggame", "egggame");
        eggsGot = FlxG.save.data.eggsGot ?? 0; 
        eggMultiplier = FlxG.save.data.eggMult ?? 1.0; 
        won = FlxG.save.data.won ?? false; 
        tutorials = cast FlxG.save.data.tutorials ?? [false, false, false]; 
        fullscreen = FlxG.save.data.fullscreen ?? false; 
        calibration = FlxG.save.data.calibration ?? 30; 

        FlxG.fullscreen = fullscreen;
    }    

    public static function price():Int
    {
        var index = (eggMultiplier - 1.0);
        return Std.int(Math.round( 22 * (index + 1) * (1.225 - index / 150 ) +  Math.pow((index + 2) / 4  , index / 100)   ));
    }

    public static function setFullscreen()
    {
        fullscreen = FlxG.fullscreen;
        FlxG.save.data.fullscreen = fullscreen;
    }

    public static function addCloseButton()
    {
        FlxG.state.add(new Button(640 - 16, 0, "", function(){Sys.exit(0);}, 32, 13, "assets/images/close.png"));
    }

    public static function windowUpdate()
    {
        setFullscreen();
        if (fullscreen || FlxG.fullscreen)
            return;

        // if (Lib.application.window.width != 1280)
        //     Lib.application.window.width = 1280;
        // if (Lib.application.window.height != 720)
        //     Lib.application.window.height = 720;
    }

    public static function save()
    {
        FlxG.save.data.eggsGot = eggsGot; 
        FlxG.save.data.eggMult = eggMultiplier; 
        FlxG.save.data.won = won; 
        FlxG.save.data.tutorials = tutorials;
        FlxG.save.data.fullscreen = fullscreen;
        FlxG.save.data.calibration = calibration;
        FlxG.save.flush();
    }

    public static function doMultiplierEgg(num:Int):Int
    {
        return Math.round(num * eggMultiplier);
    }
}