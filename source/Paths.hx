package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static public function getPath(file:String, type:AssetType)
	{
		var folder:String = (type == TEXT) ? 'data' : ((type == IMAGE) ? 'gfx' : ((type == MUSIC || type == SOUND) ? 'sfx' : ''));
		return (folder != '') ? 'assets/$folder/$file' : 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT)
	{
		return getPath(file, type);
	}

	inline static public function txt(key:String)
	{
		return getPath('$key.txt', TEXT);
	}

	inline static public function xml(key:String)
	{
		return getPath('$key.xml', TEXT);
	}

	inline static public function json(key:String)
	{
		return getPath('$key.json', TEXT);
	}

	static public function sound(key:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int)
	{
		return sound(key + FlxG.random.int(min, max));
	}

	inline static public function music(key:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC);
	}

	inline static public function voices(song:String, char:String)
	{
		return getPath('songs/${song.toLowerCase()}/${char}Voices.$SOUND_EXT', MUSIC);
	}

	inline static public function inst(song:String)
	{
		return getPath('songs/${song.toLowerCase()}/Inst.$SOUND_EXT', MUSIC);
	}

	inline static public function image(key:String)
	{
		return getPath('images/$key.png', IMAGE);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key), image(key).replace('.png', '.xml'));
	}

	inline static public function getPackerAtlas(key:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), image(key).replace('.png', '.txt'));
	}

	inline static public function videos(key:String)
	{
		return SUtil.getStorageDirectory() + 'assets/videos/$key';
	}
}
