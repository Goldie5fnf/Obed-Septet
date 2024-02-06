package;

import flixel.FlxG;
import flixel.FlxSprite;

class NoteSplash extends FlxSprite
{
	public function new(x:Float, y:Float, ?char:String = "bf", splashNum:Int = 1):Void
	{
		super(x, y);

		if (splashNum == 3)
			frames = Paths.getSparrowAtlas('characters/$char/NoteSplash');
		else
			frames = Paths.getSparrowAtlas('characters/$char/NoteSplash$splashNum');

		animation.addByPrefix('splash', 'splash', 24, false);
		animation.play('splash', true);
		scale.set(0.4, 0.4);
		updateHitbox();
		antialiasing = true;
		//offset.set(width * 0.4, height * 0.4);
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
