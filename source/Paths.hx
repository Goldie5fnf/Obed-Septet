package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;

using StringTools;

class Paths
{
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

	static public function sound(key:String, folder:String)
	{
		return getPath('$folder/$key.ogg', SOUND);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, folder:String)
	{
		return sound(key + FlxG.random.int(min, max), folder);
	}

	inline static public function voices(song:String, char:String)
	{
		return getPath('songs/${song.toLowerCase()}/${char}Voices.ogg', MUSIC);
	}

	inline static public function inst(song:String)
	{
		return getPath('songs/${song.toLowerCase()}/Inst.ogg', MUSIC);
	}

	inline static public function image(key:String, folder:String)
	{
		return getPath('$folder/$key.png', IMAGE);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function charImage(file:String, char:String) {
		return image('characters/$char/$file', 'songs');
	}

	inline static public function charAtlas(file:String, char:String) {
		return getSparrowAtlas('characters/$char/$file');
	}

	inline static public function getSparrowAtlas(key:String, folder:String = 'songs')
	{
		return FlxAtlasFrames.fromSparrow(image(key, folder), image(key, folder).replace('.png', '.xml'));
	}

	inline static public function getPackerAtlas(key:String, folder:String = 'songs')
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, folder), image(key, folder).replace('.png', '.txt'));
	}

	inline static public function videos(key:String)
	{
		return SUtil.getStorageDirectory() + 'assets/videos/$key';
	}
}
