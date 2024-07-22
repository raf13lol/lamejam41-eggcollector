package states;

import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSprite;
import sys.io.File;
import flixel.FlxG;
import flixel.FlxState;

class RhythmState extends FlxState 
{
    public var bpm(default, set):Float = 120.0;
    public var secondsPerBeat(default, null):Float = 0.5;

    public function set_bpm(v:Float)
    {
        if (Math.isNaN(v))
            v = 120.0;
        bpm = v;
        secondsPerBeat = 60 / v;
        return v;
    }

    public var time:Float = 0.0;

    // [beat, cue]
    public var cues:Array<Dynamic> = [];

    public var timingForInputs:Array<Float> = [];

    var lives:Int = 5;
    var livesSprites:Array<FlxSprite> = [];
    var eggSpr:FlxSprite;
    var eggTween:FlxTween;
    var tweenAgain:Bool = true;
    var pistonL:FlxSprite;
    var pistonR:FlxSprite;
    
    var hits:Int = 0;
    var songName:String = "";
    var infoText:FlxText;

    override public function create() 
    {
        eggSpr = new FlxSprite().loadGraphic("assets/images/gebe/goodegg.png");
        eggSpr.scale.set(4,4);
        eggSpr.updateHitbox();
        eggSpr.screenCenter();
        eggSpr.y = -1000;
        add(eggSpr);

        for (i in 0...lives)
        {
            var lifeSpr = new FlxSprite(10 + 34 * i, 10).loadGraphic("assets/images/life.png");
            add(lifeSpr);
            livesSprites.push(lifeSpr);
        }

        pistonL = new FlxSprite(0, 0).loadGraphic("assets/images/piston.png", true, 320, 240);
        pistonL.screenCenter(Y);
        pistonL.animation.add("open", [0], 1, true);
        pistonL.animation.add("close", [1], 1, true);
        add(pistonL);

        pistonR = new FlxSprite(0, 0).loadGraphic("assets/images/piston.png", true, 320, 240);
        pistonR.screenCenter(Y);
        pistonR.flipX = true;
        pistonR.x = 320;
        pistonR.animation.add("open", [0], 1, true);
        pistonR.animation.add("close", [1], 1, true);
        add(pistonR);

        pistonL.animation.play("open");
        pistonR.animation.play("open");

        infoText = new FlxText(0, 290, 0, "Tutorial'ing...", 16);
        infoText.font = Main.font;
        infoText.color = 0xff000000;
        infoText.alignment = LEFT;
        add(infoText);
        if (SaveFile.tutorials[2])
            playSong(FlxG.random.int(0, 5));
        else 
            openSubState(new states.TutorialSubstate(2));

        SaveFile.addCloseButton();
        super.create();
    } 

    function updateInfoText(rating:String = "No rating yet")
    {
        infoText.text = '${songName}\n${bpm} BPM\n+${SaveFile.doMultiplierEgg(hits)} (${SaveFile.eggsGot + SaveFile.doMultiplierEgg(hits)} in total) egg(s)';
        if (rating.length > 0)
            infoText.text += '\n${rating}';
    }

    public function loseLife()
    {
        if (lives <= 0)
            return;
        lives--;
        livesSprites[lives].loadGraphic("assets/images/lifelost.png");
        if (lives <= 0)
        {
            endGame(false);
        }
    }

    public function endGame(win:Bool) 
    {
        FlxG.sound.music.stop();
        FlxG.sound.music = null;
        if (win)
            hits += FlxG.random.int(8, 16);
        var blackscreen = new FlxSprite(0, 0).makeGraphic(640, 360, 0x80000000);
        add(blackscreen);
        SaveFile.eggsGot += SaveFile.doMultiplierEgg(hits);
        var text = new FlxText(0, 0, 0, '5 mistakes have been made,\n so the mini-game is over.\n\nYou got +${SaveFile.doMultiplierEgg(hits)} (${SaveFile.eggsGot}) eggs!', 32);
        if (win)
            text.text += "Bonus from winning!";
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
    }

    function stringToCue(string = "Drop"):Cues
    {
        var retCue:Cues = Drop;
        switch (string.toLowerCase())
        {
            default: retCue = Drop;
            case "onetwothree1beat"    | "123,1b":   retCue = OneTwoThree1Beat;
            case "onetwothreehalfbeat" | "123,0.5b": retCue = OneTwoThreeHalfBeat;
            case "onetwothree2beat"    | "123,2b":   retCue = OneTwoThree2Beat;

            case "eggdrop":     retCue = EggDrop;
            case "drophint":    retCue = DropHint;
            case "eggcatch":    retCue = EggCatch;
            case "eggtoox":     retCue = EggTooX;
            case "eggmissed":   retCue = EggMissed;
            case "pistonclose": retCue = PistonClose;
            case "pistonopen":  retCue = PistonOpen;

            case "qone":      retCue = QOne;
            case "qtwo":      retCue = QTwo;
            case "qthree":    retCue = QThree;
            case "qfour":     retCue = QFour;
            case "qonealt":   retCue = QOneAlt;
            case "qtwoalt":   retCue = QTwoAlt;
            case "qthreealt": retCue = QThreeAlt;
            case "qfouralt":  retCue = QFourAlt;

            case "jpone"   | "one":   retCue = JPOne;
            case "jptwo"   | "two":   retCue = JPTwo;
            case "jpthree" | "three": retCue = Three;
            case "jpfour"  | "four":  retCue = JPFour;
        }
        return retCue;
    }

    public function playSong(id:Int = 0)
    {
        var songs:Array<Dynamic> = [["eggsong1", "Catching Eggs"], ["eggstudio", "Rhythm Eggen"], ["crackcore", "Crackcore"]];
        id %= songs.length;

        FlxG.sound.playMusic('assets/music/${songs[id][0]}.ogg', 0.9, false);
        FlxG.sound.music.persist = false;
        FlxG.sound.music.onComplete = function(){
            endGame(true);
        };

        songName = songs[id][1];
        // parser for txt files
        var text = File.getContent('assets/data/${songs[id][0]}.txt');
        var cuesStuff = text.split("\n");
        bpm = Std.parseFloat(cuesStuff[0]);

        updateInfoText();

        var cueArray:Array<Cues> = [
            Drop, OneTwoThree1Beat, OneTwoThreeHalfBeat, OneTwoThree2Beat, // input cues
            EggDrop,  DropHint, EggCatch, EggTooX, EggMissed, PistonClose, PistonOpen, // egg cues
            QOne, QTwo, QThree, QFour, // q base
            QOneAlt, QTwoAlt, QThreeAlt, QFourAlt, // q alt
            JPOne, JPTwo, Three, JPFour, // JP
        ];

        for (i in 1...cuesStuff.length)
        {
            var thing = cuesStuff[i];
            var parts = thing.split(" ");
            while (parts.remove("")) {} // do nothing
            if (parts.length < 2)
                continue;
            var num:Int = Std.parseInt(parts[1]) ?? -1;
            // grasping at straws here
            if (Std.string(num).length != parts[1].length)
                num = -1;
            var cue = Cues.Drop;
            if (num < 0)
                cue = stringToCue(parts[1]);
            else 
            {
                if (num >= cueArray.length)
                    num = 0;
                cue = cueArray[num];
            }
            cues.push([Std.parseFloat(parts[0]), cue]);
        }
    }

    override public function update(elapsed:Float) 
    {
        SaveFile.windowUpdate();
        super.update(elapsed);
        if (FlxG.sound.music == null)
        {
            time = -1;
            return;
        }
        time = (FlxG.sound.music.time - SaveFile.calibration) / 1000;
    
        while (cues.length > 0)
        {
            if (cues[0][0] <= time / secondsPerBeat)
            {
                switch (cues[0][1])
                {
                    case Drop:
                        timingForInputs.push(secondsPerBeat);
                        cues.insert(1, [cues[0][0] + 1, DropHint]);
                        FlxG.sound.play("assets/sounds/eggdrop.ogg");

                    case OneTwoThree1Beat:
                        cues.insert(1, [cues[0][0] + 1, TwoThree1Beat]);
                        FlxG.sound.play("assets/sounds/count/one.ogg");
                    case TwoThree1Beat:
                        cues.insert(1, [cues[0][0] + 1, Three]);
                        timingForInputs.push(secondsPerBeat);
                        FlxG.sound.play("assets/sounds/count/two.ogg");

                    case OneTwoThreeHalfBeat:
                        cues.insert(1, [cues[0][0] + 0.5, TwoThreeHalfBeat]);
                        FlxG.sound.play("assets/sounds/count/one.ogg");
                    case TwoThreeHalfBeat:
                        cues.insert(1, [cues[0][0] + 0.5, Three]);
                        timingForInputs.push(secondsPerBeat / 2.0);
                        FlxG.sound.play("assets/sounds/count/two.ogg");

                    case OneTwoThree2Beat:
                        cues.insert(1, [cues[0][0] + 2, TwoThree2Beat]);
                        FlxG.sound.play("assets/sounds/count/one.ogg");
                    case TwoThree2Beat:
                        cues.insert(1, [cues[0][0] + 2, Three]);
                        timingForInputs.push(secondsPerBeat * 2.0);
                        FlxG.sound.play("assets/sounds/count/two.ogg");
                    

                    // Cue sounds
                    case EggDrop:     FlxG.sound.play("assets/sounds/eggdrop.ogg");
                    case DropHint:    FlxG.sound.play("assets/sounds/egghint.ogg");
                    case EggCatch:    FlxG.sound.play("assets/sounds/eggcatch.ogg");
                    case EggTooX:     FlxG.sound.play("assets/sounds/barely.ogg");
                    case EggMissed:   FlxG.sound.play("assets/sounds/missed.ogg");
                    case PistonClose: FlxG.sound.play("assets/sounds/thinairhit.ogg", 0.25);
                    case PistonOpen:  FlxG.sound.play("assets/sounds/openairthing.ogg", 0.25);

                    case QOne:      FlxG.sound.play("assets/sounds/qsounds/one.ogg");
                    case QTwo:      FlxG.sound.play("assets/sounds/qsounds/two.ogg");
                    case QThree:    FlxG.sound.play("assets/sounds/qsounds/three.ogg");
                    case QFour:     FlxG.sound.play("assets/sounds/qsounds/four.ogg");
                    case QOneAlt:   FlxG.sound.play("assets/sounds/qsounds/onealt.ogg");
                    case QTwoAlt:   FlxG.sound.play("assets/sounds/qsounds/twoalt.ogg");
                    case QThreeAlt: FlxG.sound.play("assets/sounds/qsounds/threealt.ogg");
                    case QFourAlt:  FlxG.sound.play("assets/sounds/qsounds/fouralt.ogg");

                    case JPOne:  FlxG.sound.play("assets/sounds/count/one.ogg");
                    case JPTwo:  FlxG.sound.play("assets/sounds/count/two.ogg");
                    case Three:  FlxG.sound.play("assets/sounds/count/three.ogg");
                    case JPFour: FlxG.sound.play("assets/sounds/count/four.ogg");
                }
                cues.shift();
            }
            else 
                break;
        }
        for (i in 0...timingForInputs.length)
            timingForInputs[i] -= elapsed;
        if (timingForInputs.length > 0)
        {
            if (timingForInputs[0] <= 0.499 * secondsPerBeat && tweenAgain)
            {
                eggSpr.color = 0xffffffff;
                eggSpr.alpha = 1;
                eggSpr.y = -eggSpr.frameHeight * 4 - 1;
                forceEggY = -1;
                eggTween = FlxTween.tween(eggSpr, {y: 361 + eggSpr.frameHeight}, (0.525 * secondsPerBeat) * 2, {type: PERSIST});
                tweenAgain = false;
            }
            if (timingForInputs[0] < -0.25 * secondsPerBeat)
            {
                var oldnum = timingForInputs[0];
                updateInfoText('Complete Miss, ${roundDec((time - timingForInputs[0] - time) * 1000)}ms');
                while (timingForInputs.length > 0)
                {
                    if (Math.abs(timingForInputs[0] - oldnum) <= 0.01)
                        timingForInputs.shift();
                    else 
                        break;
                }
                tweenAgain = true;
                FlxG.sound.play("assets/sounds/missed.ogg");
                loseLife();
            }
            if (timingForInputs.length > 0 && FlxG.keys.justPressed.SPACE)
            {
                var rating = "Good";
                var gotSomething = false;
                var missed = false;
                if (Math.abs(timingForInputs[0]) <= 0.19 * secondsPerBeat)
                {
                    gotSomething = true;
                    eggDisappear();
                }
                else if (Math.abs(timingForInputs[0]) > 0.19 * secondsPerBeat && Math.abs(timingForInputs[0]) <= 0.24 * secondsPerBeat)
                {
                    missed = true;
                    if (timingForInputs[0] > 0.0)
                    {
                        eggDisappear();
                        eggSpr.color = 0xffff9999;
                        rating = "Too Early";
                    }
                    else if (timingForInputs[0] < 0.0)
                        rating = "Too Late";
                    loseLife();
                }

                if (gotSomething || missed)
                {
                    if (gotSomething)
                    {
                        hits++;
                        FlxG.sound.play("assets/sounds/eggcatch.ogg");
                    }
                    else
                        FlxG.sound.play("assets/sounds/barely.ogg");
                    pistonClose();

                    updateInfoText('${rating}, ${roundDec((time - timingForInputs[0] - time) * 1000)}ms');
                    tweenAgain = true;
                    var oldnum = timingForInputs[0];
                    while (timingForInputs.length > 0)
                    {
                        if (Math.abs(timingForInputs[0] - oldnum) <= 0.01)
                            timingForInputs.shift();
                        else 
                            break;
                    }
                }
                else
                {
                    pistonClose();
                    if (timeSinceLastGhostTap < 0.5)
                        loseLife();
                    timeSinceLastGhostTap = 0.0;
                }
            }
        }
        else if (FlxG.keys.justPressed.SPACE)
        {
            pistonClose();
        }
        if (forceEggY >= 0)
            eggSpr.y = forceEggY;
        timeSinceLastGhostTap += elapsed;
        
    }

    function pistonClose()
    {
        FlxG.sound.play("assets/sounds/thinairhit.ogg", 0.25);
        pistonL.animation.play("close");
        pistonR.animation.play("close");
        new FlxTimer().start(0.125, function(_){
            FlxG.sound.play("assets/sounds/openairthing.ogg", 0.25);
            pistonL.animation.play("open");
            pistonR.animation.play("open");
        });
    }

    public var forceEggY:Float = -1;
    public var timeSinceLastGhostTap = 10.0;

    function eggDisappear()
    {
        var eggY = eggSpr.y;
        eggTween.cancel();
        eggSpr.y = eggY;
        forceEggY = eggY;
        FlxTween.tween(eggSpr, {alpha: 0}, 0.1, { ease: FlxEase.circOut, type: PERSIST, startDelay: 0.125});
    }

    function roundDec(val:Float)
    {
        var value = Std.string(FlxMath.roundDecimal(val, 1));
        if (value.length - Std.string(Std.int(val)).length != 2)
            value += ".0";

        return value;
    }
}

enum Cues
{
    Drop; // 0
    OneTwoThree1Beat; // 1
    OneTwoThreeHalfBeat; // 2
    OneTwoThree2Beat; // 3

    // internal shit that is really dumb
    TwoThree1Beat;
    TwoThreeHalfBeat;
    TwoThree2Beat;
    
    // sound cues
    EggDrop; // 4
    DropHint; // 5
    EggCatch; // 6
    EggTooX; // 7
    EggMissed; // 8
    PistonClose; // 9
    PistonOpen; // 10
    QOne; // 11
    QTwo; // 12
    QThree; // 13
    QFour; // 14
    QOneAlt; // 15
    QTwoAlt; // 16
    QThreeAlt; // 17
    QFourAlt; // 18
    JPOne; // 19
    JPTwo; // 20
    Three; // uhhh this is internal but also // 21
    JPFour; // 22
}