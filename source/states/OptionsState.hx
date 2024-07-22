package states;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

// No shared values challenge; Level extreme

class OptionsState extends FlxState 
{
    override public function create() 
    {
        var fullscreenButton = new Button(20, 20, "Toggle\nFullscreen", function(){
            Main.playButtonSound();
            FlxG.fullscreen = !FlxG.fullscreen;
            SaveFile.setFullscreen();
        }, 16);
        add(fullscreenButton);
        fullscreenButton.screenCenter(X);

        var calibrationNumText = createText(0, 150, '${SaveFile.calibration}ms', 32, 128);
        var calibrationText = createText(0, Std.int(calibrationNumText.y - 34), "Calibration:");
        calibrationText.screenCenter(X);
        calibrationNumText.screenCenter(X);

        createButton(Std.int(320 - 80 - 32), Std.int(calibrationNumText.y - 8), "uiminus", function(){
            Main.playButtonSound();
            SaveFile.calibration -= 10;
            calibrationNumText.text = '${SaveFile.calibration}ms';
        });
        createButton(Std.int(320 + 80), Std.int(calibrationNumText.y - 8), "uiplus", function(){
            Main.playButtonSound();
            SaveFile.calibration += 10;
            calibrationNumText.text = '${SaveFile.calibration}ms';
        });

        var eraseSaveDataButton = new FlxSprite();
        eraseSaveDataButton = new Button(fullscreenButton.x, 200, "Erase\nSave", function(){
            Main.playButtonSound();
            var b = cast(eraseSaveDataButton, Button);
            if (b.label.text == "Erase\nSave")
            {
                b.label.text = "Are you\nsure?";
                b.color = 0xffffaaaa;
                return;
            }
            b.label.text = "Done.";
            b.status = DISABLED;
            b.color = 0xffbbbbbb;

            SaveFile.won = false;
            SaveFile.eggsGot = 0;
            SaveFile.eggMultiplier = 1;
            SaveFile.tutorials = [false, false, false];
            SaveFile.save();
        }, 16);
        add(eraseSaveDataButton);
        eraseSaveDataButton.screenCenter(X);


        var backButton = new Button(0, 280, "Back", function(){
            Main.playButtonSound();
            SaveFile.save();
            FlxG.switchState(new states.MenuState());
        });
        add(backButton);
        backButton.screenCenter(X);

        SaveFile.addCloseButton();
        super.create();
    } 

    public function createText(x:Int, y:Int, text:String = "", size:Int = 32, width = 0)
    {
        var t = new FlxText(x, y, width, text, size);
        t.font = Main.font;
        t.color = 0xff000000;
        t.alignment = CENTER;
        add(t);
        return t;
    }

    public function createButton(x:Int, y:Int, image:String, onClick:Void->Void)
    {
        var b = new Button(x, y, "", onClick, 32, 13, 'assets/images/${image}.png');
        add(b);
        return b;
    }

    public override function update(elapsed:Float) 
    {
        SaveFile.windowUpdate();
        super.update(elapsed);
    }
}