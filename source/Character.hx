package;

import Song.SwagSection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;
import haxe.io.Path;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var animationNotes:Array<Dynamic> = [];

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = true;

		switch (curCharacter)
		{
			case 'bf':
				frames = Paths.getSparrowAtlas('characters/$curCharacter/BOYFRIEND');
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('hey', 'BF HEY');

				quickAnimAdd('firstDeath', "BF dies");
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				quickAnimAdd('deathConfirm', "BF Dead confirm");

				animation.addByPrefix('scared', 'BF idle shaking', 24, true);

				playAnim('idle');

				flipX = true;

			case 'obedbf':
				frames = Paths.getSparrowAtlas('characters/$curCharacter/OBED_BF');
				quickAnimAdd('idle', 'IDLE');
				quickAnimAdd('singUP', 'UP');
				quickAnimAdd('singLEFT', 'LEFT');
				quickAnimAdd('singRIGHT', 'RIGHT');
				quickAnimAdd('singDOWN', 'DOWN');

				playAnim('idle');

				flipX = true;

			case 'prettyboy':
				frames = Paths.getSparrowAtlas('characters/$curCharacter/prettyboy');
				quickAnimAdd('idle', 'idle');
				quickAnimAdd('singUP', 'down');
				quickAnimAdd('singLEFT', 'right');
				quickAnimAdd('singRIGHT', 'up');
				quickAnimAdd('singDOWN', 'LEFT');

				playAnim('idle');

				flipX = true;

			case 'goldie':
				frames = Paths.getSparrowAtlas('characters/$curCharacter/death_golda');
				quickAnimAdd('idle', 'idle');
				quickAnimAdd('singUP', 'idle');
				quickAnimAdd('singLEFT', 'idle');
				quickAnimAdd('singRIGHT', 'idle');
				quickAnimAdd('singDOWN', 'idle');

				playAnim('idle');

			case 'pico':
				frames = Paths.getSparrowAtlas('characters/$curCharacter/peka');
				quickAnimAdd('idle', 'idle');
				quickAnimAdd('singUP', 'up');
				quickAnimAdd('singRIGHT', 'right');
				quickAnimAdd('singLEFT', 'left');
				quickAnimAdd('singDOWN', 'down');
				quickAnimAdd('singUPmiss', 'up');
				quickAnimAdd('singLEFTmiss', 'left');
				quickAnimAdd('singRIGHTmiss', 'right');
				quickAnimAdd('singDOWNmiss', 'down');

				playAnim('idle');

				flipX = true;

				scale.set(0.6, 0.6);
				
			case 'darnell':
				frames = Paths.getSparrowAtlas('characters/$curCharacter/N-WORD');
				quickAnimAdd('idle', 'darnIdle');
				quickAnimAdd('singUP', 'up');
				quickAnimAdd('singRIGHT', 'left');
				quickAnimAdd('singLEFT', 'right');
				quickAnimAdd('singDOWN', 'down');
				quickAnimAdd('singUPmiss', 'up');
				quickAnimAdd('singLEFTmiss', 'right');
				quickAnimAdd('singRIGHTmiss', 'left');
				quickAnimAdd('singDOWNmiss', 'down');

				playAnim('idle');

				flipX = false;

				scale.set(0.6, 0.6);
		}

		loadOffsetFile();
		dance();
		animation.finish();

		if (isPlayer)
		{
			flipX = !flipX;
		}
	}

	private function loadOffsetFile()
	{
		var daFile:Array<String> = CoolUtil.coolTextFile(Paths.file("songs/characters/" + curCharacter + "/offsets.txt", IMAGE));

		for (i in daFile)
		{
			var splitWords:Array<String> = i.split(" ");
			addOffset(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	function quickAnimAdd(name:String, prefix:String)
	{
		animation.addByPrefix(name, prefix, 24, false);
	}
}
