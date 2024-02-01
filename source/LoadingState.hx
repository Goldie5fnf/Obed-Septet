package;

import Song.SwagSong;
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
	public static var daSong:SwagSong;
	public static var path:String = "menus";
	public static var bullshit:FlxState = new TitleState();
	var screen:LoadingScreen;
	static var charsToCache:Array<String> = [];
	static var imagesToCache:Array<String> = [];
	static var soundsToCache:Array<String> = [];

	override function create() {
		super.create();

		screen = new LoadingScreen();
		add(screen);

		if(path == 'songs')
			charsToCache = [daSong.player1, daSong.player2];

		for (image in Assets.list(IMAGE)) {
			if (image.startsWith('assets/gfx/$path') || image.startsWith('assets/gfx/global')) {
				if (image.startsWith('assets/gfx/songs/characters/')) {
					for (char in charsToCache) {
						if (image.startsWith('assets/gfx/songs/characters/$char'))
							imagesToCache.push(image);
					}
				} else
					imagesToCache.push(image);
			}
		}
		
		for (sound in Assets.list(SOUND)) {
			if (sound.startsWith('assets/sfx/$path') || sound.startsWith('assets/sfx/global'))
				soundsToCache.push(sound);
		}

		FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		FlxGraphic.defaultPersist = true;
		Thread.create(() -> {
			FlxG.bitmap.dumpCache();
			screen.setLoadingText("Unloading images...");
			@:privateAccess
			for (image in FlxG.bitmap._cache.keys()) {
				if (image.startsWith('assets/gfx') && !image.startsWith('assets/gfx/global/')) {
					var graphic:Null<FlxGraphic> = FlxG.bitmap._cache.get(image);
					Assets.cache.removeBitmapData(image);
					FlxG.bitmap._cache.remove(image);
					graphic.destroy();
				}
			}

			screen.setLoadingText("Unloading sounds...");
			for (sound in Assets.cache.getSoundKeys()) {
				if (sound.startsWith('assets/sfx') && !sound.startsWith('assets/sfx/global'))
					Assets.cache.removeSound(sound);
			}

			screen.setLoadingText("Loading images...");
			for (image in imagesToCache)
				FlxG.bitmap.add(image);

			screen.setLoadingText("Loading sounds...");
			for (sound in soundsToCache)
				FlxG.sound.cache(sound);
			
			FlxGraphic.defaultPersist = false;
			screen.setLoadingText("Done!");

			FlxG.camera.fade(FlxColor.BLACK, 1, false);
			new FlxTimer().start(1, function(_:FlxTimer) {
				screen.kill();
				screen.destroy();
				imagesToCache = [];
				soundsToCache = [];
				
				FlxG.switchState(bullshit);
			});
		});
	}
}