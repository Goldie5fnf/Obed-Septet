package;

#if DISCORD
import DiscordClient.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState {
	var songs:Array<SongMetadata> = [];

	var curSelected:Int = 0;
	var curDifficulty:Int = 0;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	var coolColors:Array<Int> = [
		0xffc7ff45,
		0xffc7ff45,
		0xff9271fd
	];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	var bg:FlxSprite;
	var scoreBG:FlxSprite;

	override function create() {
		#if DISCORD
		DiscordClient.changePresence("Freeplay", null);
		#end

		var isDebug:Bool = false;

		songs.push(new SongMetadata('death-beat', 1));

		if (FlxG.sound.music != null) {
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.sound('freakyMenu', 'menus'));
		}

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'menus'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0x99000000);
		scoreBG.antialiasing = false;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
	}

	public function addSong(songName:String, weekNum:Int) {
		songs.push(new SongMetadata(songName, weekNum));
	}

	public function addWeek(songs:Array<String>, weekNum:Int,) {
		var num:Int = 0;
		for (song in songs)
			addSong(song, weekNum);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.sound.music != null) {
			if (FlxG.sound.music.volume < 0.7)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);
		bg.color = FlxColor.interpolate(bg.color, coolColors[songs[curSelected].week % coolColors.length], CoolUtil.camLerpShit(0.045));

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);

		positionHighscore();

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (FlxG.mouse.wheel != 0)
			changeSelection(-Math.round(FlxG.mouse.wheel / 4));

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu', 'menus'));
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			PlayState.SONG = Song.loadFromJson(songs[curSelected].songName.toLowerCase() + '-' + CoolUtil.difficultyArray[curDifficulty], songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			LoadingState.path = 'songs';
			LoadingState.bullshit = new PlayState();
			LoadingState.daSong = PlayState.SONG;
			FlxG.switchState(new LoadingState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 1;
		if (curDifficulty > 1)
			curDifficulty = 0;
		
		intendedScore = Highscore.getSongScore(songs[curSelected].songName + '-' + CoolUtil.difficultyArray[curDifficulty]).score;
		diffText.text = "< " + CoolUtil.difficultyString().toUpperCase() + " >";
		positionHighscore();
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu', 'menus'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
		
		intendedScore = Highscore.getSongScore(songs[curSelected].songName + '-' + CoolUtil.difficultyArray[curDifficulty]).score;
		
		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (item in grpSongs.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

	function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;

		diffText.x = Std.int(scoreBG.x + scoreBG.width / 2);
		diffText.x -= (diffText.width / 2);
	}
}

class SongMetadata {
	public var songName:String = "";
	public var week:Int = 0;

	public function new(song:String, week:Int) {
		this.songName = song;
		this.week = week;
	}
}
