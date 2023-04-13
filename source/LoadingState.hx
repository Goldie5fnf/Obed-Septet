package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import sys.thread.Thread;

using StringTools;

class LoadingState extends MusicBeatState
{
	public static var target:FlxState;
	public static var stopMusic = false;

	static var imagesToCache:Array<String> = [];
	static var soundsToCache:Array<String> = [];

	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();

		for (image in Assets.list(IMAGE))
			imagesToCache.push(image);
		for (sound in Assets.list(SOUND))
			soundsToCache.push(sound);

		FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		FlxGraphic.defaultPersist = true;
		Thread.create(() ->
		{
			for (sound in soundsToCache)
			{
				trace("Caching sound " + sound);
				FlxG.sound.cache(sound);
			}
			for (image in imagesToCache)
			{
				trace("Caching image " + image);
				FlxG.bitmap.add(image);
			}
			FlxGraphic.defaultPersist = false;
			trace("Done caching");
			
			FlxG.camera.fade(FlxColor.BLACK, 1, false);
			new FlxTimer().start(1, function(_:FlxTimer)
			{
				loadAndSwitchState(target, false);
			});
		});
	}

	public static function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		Paths.setCurrentLevel("week" + PlayState.storyWeek);

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		Main.dumping = false;
		FlxG.switchState(target);
	}

	public static function dumpAdditionalAssets()
	{
		for (image in imagesToCache)
		{
			trace("Dumping image " + image);
			FlxG.bitmap.removeByKey(image);
		}
		soundsToCache = [];
		imagesToCache = [];
	}
}