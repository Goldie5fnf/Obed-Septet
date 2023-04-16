package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.graphics.FlxGraphic;
import flixel.effects.FlxFlicker;
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
	var warning:FlxText;
	var enabled:Bool = true;

	override function create()
	{
		super.create();

		warning = new FlxText(0, 0, 0, 'Do you want to preload every image and sound in a game?\n
		(RECOMMENDED FOR DEVICES WITH HIGH RAM)\n\n
		Press ENTER to preload or ESC to skip.', 30);
		warning.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warning.screenCenter();
		add(warning);

		Init.Initialize();
	}

	override function update(elapsed)
	{
		if (enabled)
		{
			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				enabled = false;
				FlxFlicker.flicker(warning, 1, 0.06, true, false, function(flick:FlxFlicker)
				{
					warning.destroy();
					precache();
				});
			}
			else if (controls.BACK)
			{
				enabled = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				warning.destroy();
				FlxG.switchState(new TitleState());
			}
		}

		super.update(elapsed);
	}

	function precache()
	{
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
