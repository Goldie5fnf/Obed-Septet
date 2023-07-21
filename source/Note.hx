package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.PreferencesMenu;

using StringTools;

#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	private var willMiss:Bool = false;

	public var isPlayerNote:Bool = false;
	public var altNote:Bool = false;
	public var invisNote:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7 + 10;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(strumTime:Float, noteData:Int, ?char:String = 'BF', ?prevNote:Note, ?sustainNote:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 87.5;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		frames = Paths.charAtlas('NOTE_assets-$char', char.toLowerCase());

		animation.addByPrefix('greenScroll', 'upnote');
		animation.addByPrefix('redScroll', 'rightnote');
		animation.addByPrefix('blueScroll', 'downnote');
		animation.addByPrefix('purpleScroll', 'leftnote');

		animation.addByPrefix('holdend', 'note end hold');
		animation.addByPrefix('hold', 'note hold piece');

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;

		switch (noteData)
		{
			case 0:
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1 - 7;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2 - 2.5;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			if (PreferencesMenu.getPref('downscroll'))
				angle = 180;

			x += width / 2;
			animation.play('holdend');

			updateHitbox();

			x -= width / 4.25;
			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
			}
			if (animation.name.endsWith('end'))
				offset.x += width / 4.25; // i woke up in a new buggatti:fire:
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// miss on the NEXT frame so lag doesnt make u miss notes
			if (willMiss && !wasGoodHit)
			{
				tooLate = true;
				canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset)
				{ // The * 0.5 is so that it's easier to hit them too late, instead of too early
					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
						canBeHit = true;
				}
				else
				{
					canBeHit = true;
					willMiss = true;
				}
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
