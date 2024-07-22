package states;

import flixel.FlxG;
import openfl.display.TriangleCulling;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxBasic;
import flixel.FlxSubState;

class TutorialSubstate extends FlxSubState 
{
    public var tutorialTexts = [
        // main game
        [
            "Welcome to Egg Yield!\n" + 
            "In this game, you must try to collect 1 million eggs.",

            "Play one of the two mini-games to earn eggs.\n" + 
            "With the eggs, you can spend them to have a higher multiplier when you play the games.",

            "That's all, you will get tutorials in the games!"
        ],
        // verifier game
        [
            "Welcome to Verifier.\n" + 
            "In this game, you must decide if the egg is the perfect egg shape.\n" + 
            "Press ENTER/RETURN if it is a perfect egg shape.\n" + 
            "Press SPACE if it is not.",

            "You have a time limit for each egg, as you are replacing a robot.\n" +
            "You can only mess up 2 times before next time means mini-game over.",

            "Have fun!"
        ],
        // rhythm game
        [
            "Welcome to Rhythm.\n" +
            "In this game, you must time your SPACE press to the music.\n" +
            "You will hear a \"1, 2, 3\", press SPACE on when the \"3\" plays.\n" + 
            "Timing could be bit tricky, be wary!",

            "You can make 4 mistakes before the game is over on the next mistake.\n" +
            "Winning the mini-game will provide a bonus!\n" +
            "Don't try spamming.",

            "Have fun!"
        ]
    ];
    public var tutorialThing:Int;
    public var tutorialIndex = 0;

    override public function new(tutorial:Int) 
    {
        super(0x80000000);
        tutorialThing = tutorial;

        var tutorialText = new FlxText(0, 100, 400, "tutorial", 16);
        tutorialText.screenCenter(X);
        tutorialText.font = Main.font;
        tutorialText.alignment = CENTER;
        tutorialText.text = tutorialTexts[tutorialThing][tutorialIndex];
        add(tutorialText);

        var nextButton:FlxBasic = new FlxBasic();
        nextButton = new Button(0, 270, "Next", function(){
            if (tutorialIndex == tutorialTexts.length - 1)
            {
                FlxG.state.closeSubState();
                if (tutorialThing == 1)
                    cast(FlxG.state, states.GoodEggBadEggState).createEgg();
                else if (tutorialThing == 2)
                    cast(FlxG.state, states.RhythmState).playSong(FlxG.random.int(0, 5));
                SaveFile.tutorials[tutorialThing] = true;
                SaveFile.save(); 
            }
            else
            {
                tutorialIndex++;
                if (tutorialIndex == tutorialTexts.length - 1)
                {
                    cast(nextButton, Button).label.text = "Play";
                    tutorialText.size = 32;
                }
                tutorialText.text = tutorialTexts[tutorialThing][tutorialIndex];
            }
        });
        cast(nextButton, FlxSprite).screenCenter(X);
        add(nextButton);
    }

    override public function create() 
    {
        super.create();
    } 
    
    override public function update(elapsed:Float) 
    {
        super.update(elapsed);
    }
}