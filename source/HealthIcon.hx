package;

import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	var char:String = '';
	var isPlayer:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		this.isPlayer = isPlayer;

		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public function changeIcon(newChar:String):Void
	{
		if (newChar != char)
		{
			if (animation.getByName(newChar) == null)
			{
				loadGraphic(Paths.image('icons/icon-' + newChar, 'songs'), true, 150, 150);
				animation.add(newChar, [0, 1], 0, false, isPlayer);
			}
			animation.play(newChar);
			char = newChar;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
