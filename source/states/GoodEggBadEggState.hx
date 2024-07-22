package states;

import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class GoodEggBadEggState extends FlxState 
{
    // transitions
    var egg1:FlxSprite;
    var egg2:FlxSprite;
    var lives:Int = 3;
    var livesSprite:Array<FlxSprite> = [];
    var badEgg:Bool = false;
    var time:Float = 0.0;

    var centerX:Int;
    var screenOffset:Int;
    var screenYOffset:Int;

    var firstEgg:Bool = true;
    var useEgg1:Bool = true;
    var canMoveOn:Bool = true;

    var stopRepeats:Int = 0;
    var badRepeating:Bool = false;
    var hits:Int = -1;

    var timer:FlxText;
    var eggsGot:FlxText;

    override public function create() 
    {
        FlxG.sound.playMusic("assets/music/eggverifier.ogg");
        FlxG.sound.music.persist = false;
        bgColor = Main.bgColor;

        egg1 = new FlxSprite();
        // stuff needed for uhhh thing
        egg1.loadGraphic("assets/images/gebe/goodegg.png");
        egg1.scale.set(4, 4);
        // needed for width+height update
        egg1.updateHitbox();

        // uhh ok
        egg2 = new FlxSprite();
        egg2.loadGraphic("assets/images/gebe/goodegg.png");
        egg2.scale.set(4, 4);
        // origin update...
        egg2.updateHitbox();

        egg1.screenCenter(X);
        centerX = Std.int(egg1.x);

        egg1.screenCenter(Y);
        egg2.screenCenter(Y);

        add(egg1);
        add(egg2);

        screenOffset = Std.int(egg1.width) + 2;
        screenYOffset = Std.int(egg1.height) + 2;

        egg1.x = -screenOffset;
        egg2.x = -screenOffset;
        
        var goodeggsign = new FlxSprite(576, 80).loadGraphic("assets/images/gebe/goodeggsign.png");
        add(goodeggsign);
        var badeggsign = new FlxSprite(400, 0).loadGraphic("assets/images/gebe/badeggsign.png");
        add(badeggsign);

        for (i in 0...3)
        {
            var lifeSpr = new FlxSprite(10 + 34 * i, 10).loadGraphic("assets/images/life.png");
            add(lifeSpr);
            livesSprite.push(lifeSpr);
        }
                
        timer = new FlxText(4, 320, 200, "1.0", 16);
        timer.font = Main.font;
        timer.color = 0xff000000;
        add(timer);
        eggsGot = new FlxText(4, 340, 0, "", 16);
        eggsGot.font = Main.font;
        eggsGot.color = 0xff000000;
        add(eggsGot);
        var eggsPlusMult = SaveFile.doMultiplierEgg(hits);
        eggsGot.text = '${SaveFile.eggsGot + eggsPlusMult} total eggs (+${eggsPlusMult} eggs)';

        if (SaveFile.tutorials[1])
            createEgg();
        else 
            openSubState(new states.TutorialSubstate(1));
        // need time to get your bearings
        time = 5.0;
        SaveFile.addCloseButton();
        super.create();
    } 

    public function loseLife()
    {
        lives--;
        livesSprite[lives].loadGraphic("assets/images/lifelost.png");
        if (lives <= 0)
        {
            var blackscreen = new FlxSprite(0, 0).makeGraphic(640, 360, 0x80000000);
            add(blackscreen);
            var eggsPlusMult = SaveFile.doMultiplierEgg(hits);
            eggsGot.text = '${SaveFile.eggsGot + eggsPlusMult} total eggs (+${eggsPlusMult} eggs)';
            SaveFile.eggsGot += SaveFile.doMultiplierEgg(hits);
            var text = new FlxText(0, 0, 0, '3 mistakes have been made,\n so the mini-game is over.\n\nYou got +${SaveFile.doMultiplierEgg(hits)} (${SaveFile.eggsGot}) eggs!', 32);
            if(hits == 0)
            {
                text.size = 64;
                text.text = "F";
            }
            text.font = Main.font;
            text.screenCenter();
            text.alignment = CENTER;
            text.y -= 10;
            add(text);
            var backButton = new Button(0, 290, "Back", function(){
                Main.playButtonSound();
                FlxG.switchState(new states.MainState());
            });
            backButton.screenCenter(X);
            add(backButton);
            canMoveOn = false;
        }
    }

    public function createEgg(badEggWhack:Bool = false)
    {
        var lifeLost = badEggWhack != badEgg;
        if (lifeLost && !firstEgg)
            loseLife();

        if (!badEggWhack)
            FlxG.sound.play("assets/sounds/moveright.ogg");
        else 
            FlxG.sound.play("assets/sounds/moveup.ogg");
        if (!firstEgg)
        {
            var exitEgg = getEggToUse(true);
            if (badEggWhack)
                FlxTween.tween(exitEgg, {y: -screenYOffset}, 0.2, {ease: FlxEase.quadIn});
            else 
                FlxTween.tween(exitEgg, {x: 640 + screenOffset}, 0.3, {ease: FlxEase.quadIn});
        }
        else 
            firstEgg = false;

        var egg = getEggToUse();
        var oldbadRepa = badRepeating;

        // stop fucking repeating
        badEgg = FlxG.random.bool(40 + (stopRepeats * 12.5 * (badRepeating ? 1 : -1)));
        if (badEgg)
        {
            if (FlxG.random.bool(0.1))
                egg.loadGraphic("assets/images/gebe/birdegg.png");
            else if (FlxG.random.bool(0.1))
                egg.loadGraphic("assets/images/gebe/egg.egg.png");
            else    
                egg.loadGraphic('assets/images/gebe/badegg${FlxG.random.int(1, 5)}.png');
        }
        else 
            egg.loadGraphic("assets/images/gebe/goodegg.png");
        badRepeating = badEgg;
        if (oldbadRepa != badRepeating)
            stopRepeats = 0;

        egg.x = -screenOffset;
        egg.screenCenter(Y);
        
        canMoveOn = false;
        useEgg1 = !useEgg1;
        FlxTween.tween(egg, {x: centerX}, 0.3, {ease: FlxEase.quadIn, onComplete: function(_){
            canMoveOn = lives > 0;
        }});
        if (!lifeLost)
            hits++;

        time = 1.25;
        if (hits > 10)
            time -= 0.25;
        if (hits > 20)
            time -= 0.25;
        if (hits > 30)
            time -= (hits - 30) * 0.01; 
        timer.text = '${roundDec(time)} seconds left';

        if (lives > 0)
        {
            var eggsPlusMult = SaveFile.doMultiplierEgg(hits);
            eggsGot.text = '${SaveFile.eggsGot + eggsPlusMult} total eggs (+${eggsPlusMult} eggs)';
        }
    }
    
    public function getEggToUse(invert:Bool = false):FlxSprite
    {
        if (invert)
            return (useEgg1) ? egg2 : egg1;
        return (useEgg1) ? egg1 : egg2;
    }

    override public function update(elapsed:Float) 
    {
        SaveFile.windowUpdate();
        if (canMoveOn)
        {
            if (FlxG.keys.justPressed.SPACE)
                createEgg(true);
            else if (FlxG.keys.justPressed.ENTER)
                createEgg();
        }
        if (lives > 0)
        {
            time -= elapsed;
            if (time <= 0.0)
            {
                loseLife();
                if (lives > 0)
                    time = 4.0;
            }
        }
        timer.text = '${roundDec(time)} seconds left';
        super.update(elapsed);
    }

    function roundDec(val:Float)
    {
        var value = Std.string(FlxMath.roundDecimal(val, 2));
        if (value.length != 4)
        {
            if (value.length == 1)
                value += ".0";
            value += "0";
        }

        return value;
    }
}