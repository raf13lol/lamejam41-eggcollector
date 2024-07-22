package states;

import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class MainState extends FlxState 
{
    var gebeButton:Button;
    var rhyButton:Button;
    var egg:FlxSprite;
    var winning:Bool = false;

    override public function create() 
    {
        if (FlxG.sound.music == null)
            FlxG.sound.playMusic("assets/music/loopmenutheme.ogg");
        bgColor = Main.bgColor;

        gebeButton = new Button(20, 290, "Verifier", function(){
            if (winning) return;

            Main.playButtonSound();
            FlxG.switchState(new states.GoodEggBadEggState());
        });
        add(gebeButton);

        rhyButton = new Button(640 - 148, 290, "Rhythm", function(){
            if (winning) return;

            Main.playButtonSound();
            FlxG.switchState(new states.RhythmState());
        });
        add(rhyButton);

        var backButton = new Button(20, 10, "Back", function(){
            if (winning) return;

            Main.playButtonSound();
            FlxG.switchState(new states.MenuState());
        });
        add(backButton);

        var eggText = new FlxText(160, 10, 0, '${SaveFile.eggsGot} egg(s), x${SaveFile.eggMultiplier}; Upgrade for ${SaveFile.price()} eggs');
        eggText.font = Main.font;
        eggText.color = 0xff000000;
        eggText.size = 16;
        add(eggText);

        var upgradeButton = new Button(640 - 148, 10, "Upgrade", function(){
            if (winning) return;
            if (SaveFile.eggsGot >= SaveFile.price())
            {
                SaveFile.eggsGot -= SaveFile.price();
                SaveFile.eggMultiplier *= 2;
                SaveFile.save();
                eggText.text = '${SaveFile.eggsGot} egg(s), x${SaveFile.eggMultiplier}; Upgrade for ${SaveFile.price()} eggs';
            }
        }, 32, 13, null, -1);
        add(upgradeButton);

        
        egg = new FlxSprite(0,0).loadGraphic("assets/images/egg.png", true, 64, 64);
        egg.scale.set(4, 4);
        egg.updateHitbox();
        egg.animation.add("normal", [0], 1, true);
        egg.animation.add("cracking", [0, 1, 2, 3, 4], 0.5, false);
        egg.animation.add("golden", [4], 1, true);
        egg.animation.finishCallback = function(name:String){
            if (name == "cracking")
            {
                egg.animation.play("golden");
                winning = false;
            }
        };
        if (SaveFile.won)
            egg.animation.play("golden");
        else 
            egg.animation.play("normal");
        add(egg);
        egg.screenCenter();

        if (!SaveFile.won && SaveFile.eggsGot >= 1000000)
            win();

        if (!SaveFile.tutorials[0])
            openSubState(new states.TutorialSubstate(0));

        SaveFile.save();
        SaveFile.addCloseButton();
        super.create();
    } 

    public function win()
    {
        egg.animation.play("cracking");
        FlxG.sound.playMusic("assets/music/milliontheme.ogg");
        FlxG.sound.music.onComplete = function(){
            FlxG.sound.playMusic("assets/music/loopmenutheme.ogg");
        };
        SaveFile.won = true;
    }
    
    public override function update(elapsed:Float) 
    {
        SaveFile.windowUpdate();
        super.update(elapsed);
    }
}