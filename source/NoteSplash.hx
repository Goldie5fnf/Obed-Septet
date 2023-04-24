package;

import flixel.FlxSprite;

class NoteSplash extends FlxSprite
{
	public function new(x:Float, y:Float, ?char:String = "BF"):Void
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('noteassets/NOTEIMPACT-$char');

		animation.addByPrefix('note', 'note impact 2', 18, false);
		animation.play('note', true);
		scale.set(0.7, 0.7);
		updateHitbox();
		antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
