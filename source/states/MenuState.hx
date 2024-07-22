package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.text.FlxText;

class MenuState extends FlxState
{

	override public function create()
	{
        if (FlxG.sound.music == null)
            FlxG.sound.playMusic("assets/music/loopmenutheme.ogg");
        bgColor = Main.bgColor;

        var logoText = new FlxText(320, 100, 0, "EGG\nYIELD", 64);
        logoText.alignment = CENTER;
        logoText.color = 0xff000000;
        logoText.font = Main.font;
        logoText.screenCenter(X);
        add(logoText);

        var playButton = new Button(30, 260, "Play", function(){
            Main.playButtonSound();
            FlxG.switchState(new states.MainState());
        });

        var optButton = new Button(30, 260, "Options", function(){
            Main.playButtonSound();
            FlxG.switchState(new states.OptionsState());
        });
        optButton.screenCenter(X);

        var exitButton = new Button(640 - 128 - 30, 260, "Exit", function(){
            Main.playButtonSound();
            Sys.exit(0);
        });

        add(playButton);
        add(optButton);
        add(exitButton);

        SaveFile.addCloseButton();
		super.create();
	}

    public override function update(elapsed:Float) 
    {
        SaveFile.windowUpdate();
        super.update(elapsed);
    }
}
