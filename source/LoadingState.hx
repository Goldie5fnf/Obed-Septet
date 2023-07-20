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
			if (image.startsWith('assets/gfx/$path') || image.startsWith('assets/gfx/global'))
				imagesToCache.push(image);
		}
		for (sound in Assets.list(SOUND))
		{
			if (sound.startsWith('assets/sfx/$path') || sound.startsWith('assets/sfx/global'))
				soundsToCache.push(sound);
		}

		screen.max = imagesToCache.length + soundsToCache.length;

		FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		FlxGraphic.defaultPersist = true;
		Thread.create(() ->
		{
			FlxG.bitmap.dumpCache();
			screen.setLoadingText("Unloading images...");
			@:privateAccess
			for (image in FlxG.bitmap._cache.keys()) {
				if (image.startsWith('assets/gfx'))
				{
					trace('Uncaching image $image');
					var graphic:Null<FlxGraphic> = FlxG.bitmap._cache.get(image);
					Assets.cache.removeBitmapData(image);
					FlxG.bitmap._cache.remove(image);
					graphic.destroy();
				}
			}
			screen.setLoadingText("Unloading sounds...");
			for (sound in Assets.cache.getSoundKeys()) {
				if (sound.startsWith('assets/sfx'))
				{
					trace('Uncaching sound $sound');
					Assets.cache.removeSound(sound);
				}
			}
			screen.setLoadingText("Loading images...");
			for (image in imagesToCache)
			{
				trace('Caching image $image');
				FlxG.bitmap.add(image);
				screen.progress += 1;
			}
			screen.setLoadingText("Loading sounds...");
			for (sound in soundsToCache)
			{
				trace('Caching sound $sound');
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
				imagesToCache = [];
				soundsToCache = [];
				@:privateAccess
				for (key in FlxG.bitmap._cache.keys())
				{
					if (key.contains('assets'))
					{
						trace('key: ' + key + " is on mem");
					}
				}
				FlxG.switchState(bullshit);
			});
		});
	}
}