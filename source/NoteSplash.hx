package;

import flixel.FlxSprite;

class NoteSplash extends FlxSprite
{
	public function new(x:Float, y:Float, ?char:String = "BF"):Void
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('noteassets/NOTEsplash-$char');

		animation.addByPrefix('note', 'NOTEIMPACT', 24, false);
		animation.play('note', true);
		scale.set(0.8, 0.8);
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
