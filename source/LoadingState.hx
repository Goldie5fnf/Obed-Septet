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
	static var library:String = "";

	var screen:LoadingScreen;

	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();

		trace(Assets.list(IMAGE));

		screen = new LoadingScreen();
		add(screen);

		screen.max = soundsToCache.length + imagesToCache.length;

		FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		FlxGraphic.defaultPersist = true;
		Thread.create(() ->
		{
			screen.setLoadingText("Loading sounds...");
			for (sound in soundsToCache)
			{
				trace("Caching sound " + sound);
				FlxG.sound.cache(Paths.sound(sound, library));
				screen.progress += 1;
			}

			screen.setLoadingText("Loading images...");
			for (image in imagesToCache)
			{
				trace("Caching image " + image);
				FlxG.bitmap.add(Paths.image(image, library));
				screen.progress += 1;
			}

			FlxGraphic.defaultPersist = false;

			screen.setLoadingText("Done!");
			trace("Done caching");
			
			FlxG.camera.fade(FlxColor.BLACK, 1, false);
			new FlxTimer().start(1, function(_:FlxTimer)
			{
				screen.kill();
				screen.destroy();
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
			FlxG.bitmap.removeByKey(Paths.image(image, library));
		}
		soundsToCache = [];
		imagesToCache = [];
	}
}