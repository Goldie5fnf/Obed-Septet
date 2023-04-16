package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import sys.thread.Thread;
#if DISCORD
import DiscordClient.DiscordClient;
#end

using StringTools;

class LoadingState extends MusicBeatState
{
	static var imagesToCache:Array<String> = [];
	static var soundsToCache:Array<String> = [];

	var screen:LoadingScreen;

	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();

		Init.Initialize();

		screen = new LoadingScreen();
		add(screen);

		for (image in Assets.list(IMAGE))
			if (!image.startsWith('flixel'))
				imagesToCache.push(image);
		for (sound in Assets.list(SOUND))
			if (!sound.startsWith('flixel'))
				soundsToCache.push(sound);

		screen.max = imagesToCache.length + soundsToCache.length;

		FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		FlxGraphic.defaultPersist = true;
		Thread.create(() ->
		{
			screen.setLoadingText("Loading images...");
			for (image in imagesToCache)
			{
				trace("Caching image " + image);
				FlxG.bitmap.add(image);
				screen.progress += 1;
			}
			screen.setLoadingText("Loading sounds...");
			for (sound in soundsToCache)
			{
				trace("Caching sound " + sound);
				FlxG.sound.cache(sound);
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
				FlxG.switchState(new TitleState());
			});
		});
	}
}
