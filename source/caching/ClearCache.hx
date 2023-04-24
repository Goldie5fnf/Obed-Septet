package caching;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;


class ClearCache
{
    private static var currentTrackedAssets:Map<String, Map<String, Dynamic>> = ["textures" => [], "graphics" => [], "sounds" => []];
	private static var localTrackedAssets:Map<String, Array<String>> = ["graphics" => [], "sounds" => []];

	public static final extensions:Map<String, String> = ["image" => "png", "audio" => "ogg", "video" => "mp4"];

	public static var dumpExclusions:Array<String> = [];

	public static function excludeAsset(key:String):Void {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static function clearUnusedMemory():Void {
		for (key in currentTrackedAssets["graphics"].keys()) {
			@:privateAccess
			if (!localTrackedAssets["graphics"].contains(key)) {
				if (currentTrackedAssets["textures"].exists(key)) {
					var texture:Null<Texture> = currentTrackedAssets["textures"].get(key);
					texture.dispose();
					texture = null;
					currentTrackedAssets["textures"].remove(key);
				}

				var graphic:Null<FlxGraphic> = currentTrackedAssets["graphics"].get(key);
				OpenFlAssets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				graphic.destroy();
				currentTrackedAssets["graphics"].remove(key);
			}
		}

		for (key in currentTrackedAssets["sounds"].keys()) {
			if (!localTrackedAssets["sounds"].contains(key)) {
				OpenFlAssets.cache.removeSound(key);
				currentTrackedAssets["sounds"].remove(key);
			}
		}

		// run the garbage collector for good measure lmfao
		System.gc();
	}

	public static function clearStoredMemory():Void {
		FlxG.bitmap.dumpCache();

		@:privateAccess
		for (key in FlxG.bitmap._cache.keys()) {
			if (!currentTrackedAssets["graphics"].exists(key)) {
				var graphic:Null<FlxGraphic> = FlxG.bitmap._cache.get(key);
				OpenFlAssets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				graphic.destroy();
			}
		}

		for (key in OpenFlAssets.cache.getSoundKeys()) {
			if (!currentTrackedAssets["sounds"].exists(key))
				OpenFlAssets.cache.removeSound(key);
		}

		for (key in OpenFlAssets.cache.getFontKeys())
			OpenFlAssets.cache.removeFont(key);

		localTrackedAssets["sounds"] = localTrackedAssets["graphics"] = [];
	}
}