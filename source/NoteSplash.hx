package;

import flixel.FlxG;
import flixel.FlxSprite;

class NoteSplash extends FlxSprite
{
	public function new(x:Float, y:Float, ?char:String = "bf"):Void
	{
		super(x, y);

		var randomizer:Int = FlxG.random.int(1, 2);
		frames = Paths.getSparrowAtlas('characters/$char/NoteSplash$randomizer');

		animation.addByPrefix('splash', 'splash', 30, false);
		animation.play('splash', true);
		//scale.set(0.8, 0.8);
		updateHitbox();
		antialiasing = true;
		offset.set(width * 0.4, height * 0.4);
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
