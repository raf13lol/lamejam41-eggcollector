package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class Button extends FlxButton 
{
    var baseImage = "assets/images/button.png";

	public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void, Size = 32, Offset = 13, ?Image, xOffset = 0)
    {
        labelAlphas = [1, 1, 1, 1];
        if (Image != null)
            baseImage = Image;
        super(X, Y, Text, OnClick);
        label.font = Main.font;
        label.size = Size;
        label.fieldWidth = 128;
        label.alpha = 1.0;
        for (i in 0...labelOffsets.length)
        {
            labelOffsets[i].x += xOffset;
            labelOffsets[i].y += Offset;
        }
        label.color = 0xff000000;
        labelAlphas = [1, 1, 1, 1];
    } 

    override function loadDefaultGraphic() 
    {
        if (baseImage == "assets/images/button.png")
            loadGraphic(baseImage, true, 128, 64);
        else
            loadGraphic(baseImage);
    }  
}
