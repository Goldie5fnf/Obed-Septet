package;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
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
	public static var path:String = "menus";
	public static var bullshit:FlxState = new TitleState();
	var screen:LoadingScreen;
	static var imagesToCache:Array<String> = [];
	static var soundsToCache:Array<String> = [];

	override function create()
	{
		super.create();

		screen = new LoadingScreen();
		add(screen);

		for (image in Assets.list(IMAGE))
		{
			if (image.startsWith('assets/gfx/$path'))
				imagesToCache.push(image);
			else if (path != 'global')
				Assets.cache.removeBitmapData(image);
		}
		for (sound in Assets.list(SOUND))
		{
			if (sound.startsWith('assets/sfx/$path'))
				soundsToCache.push(sound);
			else if (path != 'global')
				Assets.cache.removeSound(sound);
		}

		screen.max = imagesToCache.length + soundsToCache.length;

		FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		FlxGraphic.defaultPersist = true;
		Thread.create(() ->
		{
			screen.setLoadingText("Loading images...");
			for (image in imagesToCache)
			{
				trace('Caching $path image $image');
				FlxG.bitmap.add(image);
				screen.progress += 1;
			}
			screen.setLoadingText("Loading sounds...");
			for (sound in soundsToCache)
			{
				trace('Caching $path image $sound');
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
				FlxG.switchState(bullshit);
			});
		});
	}
}