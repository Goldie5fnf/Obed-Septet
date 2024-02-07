package;

import haxe.ds.StringMap;

@:structInit class HighscoreMap {
	public var score:Int = 0;
	public var misses:Int = 0;
}

class Highscore {
	public static var songScores:StringMap<HighscoreMap> = new StringMap<HighscoreMap>();
	public static var weekScores:StringMap<HighscoreMap> = new StringMap<HighscoreMap>();

	public static function saveSongScore(song:String, save:HighscoreMap):Void {
		_setScore(songScores, song, save);
	}

	public static function saveWeekScore(week:Int, diff:String, save:HighscoreMap):Void {
		_setScore(weekScores, 'week' + week + diff, save);
	}

	public static function getSongScore(song:String):HighscoreMap {
		return _getScore(songScores, song);
	}

	public static function getWeekScore(week:Int, diff:String):HighscoreMap {
		return _getScore(weekScores, 'week' + week + diff);
	}

	@:dox(hide)
	private static inline function _getScore(strmap:StringMap<HighscoreMap>, id:String):HighscoreMap {
		final dummy:HighscoreMap = {
			score: 0,
			misses: 0
		};

		return strmap.get(id) != null ? strmap.get(id) : dummy;
	}

	@:dox(hide)
	private static function _setScore(strmap:StringMap<HighscoreMap>, id:String, save:HighscoreMap):Void {
		if (strmap.exists(id) && strmap.get(id).score < save.score)
			strmap.set(id, save);
		else if (!strmap.exists(id))
			strmap.set(id, save);
	}
}