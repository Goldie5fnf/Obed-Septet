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

class Note extends FlxSprite {
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

	public function new(strumTime:Float, noteData:Int, ?char:String = 'bf', ?prevNote:Note, ?sustainNote:Bool = false) {
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		frames = Paths.getSparrowAtlas('characters/$char/NOTE_assets');

		animation.addByPrefix('greenScroll', 'upletlet', 24, false);
		animation.addByPrefix('redScroll', 'rightletlet', 24, false);
		animation.addByPrefix('blueScroll', 'downletlet', 24, false);
		animation.addByPrefix('purpleScroll', 'leftletlet', 24, false);

		animation.addByPrefix('holdend1', 'slide zhopkaa');
		animation.addByPrefix('hold1', 'slide siska');
		animation.addByPrefix('holdend2', 'slide zhopka');
		animation.addByPrefix('hold2', 'slide sisk');

		if(char == 'prettyboy') {
			animation.addByPrefix('holdend', 'slideend');
			animation.addByPrefix('hold', 'slideser');
		}

		setGraphicSize(Std.int(width * 0.6));
		updateHitbox();
		antialiasing = true;

		switch (noteData) {
			case 0:
				animation.play('purpleScroll', true);
			case 1:
				x += swagWidth * 1 - 2;
				animation.play('blueScroll', true);
			case 2:
				x += swagWidth * 2 + 3;
				animation.play('greenScroll', true);
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll', true);
		}

		if (isSustainNote && prevNote != null) {
			noteScore * 0.2;
			alpha = 0.6;

			if (PreferencesMenu.getPref('downscroll'))
				angle = 180;

			//x += width / 2;
			if (noteData == 0 || noteData == 2)
				animation.play('holdend1');
			else if (noteData == 1 || noteData == 3)
				animation.play('holdend2');
			else if (char == 'prettyboy')
				animation.play('holdend');

			updateHitbox();

			x -= width / 4.25;
			if (prevNote.isSustainNote) {
				if (noteData == 0 || noteData == 2)
					animation.play('hold1');
				else if (noteData == 1 || noteData == 3)
					animation.play('hold2');
				else if (char == 'prettyboy')
					animation.play('hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
			}
			
			if (animation.name.startsWith('holde'))
				offset.x += width / 4.25; 
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (mustPress) {
			if (willMiss && !wasGoodHit) {
				tooLate = true;
				canBeHit = false;
			} else {
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset) {
					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
						canBeHit = true;
				} else {
					canBeHit = true;
					willMiss = true;
				}
			}
		} else {
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate) {
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
	
	public function beatHit() {
		switch (noteData) {
			case 0:
				animation.play('purpleScroll', true);
			case 1:
				animation.play('blueScroll', true);
			case 2:
				animation.play('greenScroll', true);
			case 3:
				animation.play('redScroll', true);
		}
	}
}
