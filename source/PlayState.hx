package;

import Song.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import ui.PreferencesMenu;

using StringTools;

#if DISCORD
import DiscordClient.DiscordClient;
#end

class PlayState extends MusicBeatState {
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var deathCounter:Int = 0;

	var vocalsP1:FlxSound;
	var vocalsP2:FlxSound;
	var vocalArray:Array<FlxSound> = [];
	private var vocalsFinished:Bool = false;

	private var daun:Character;
	private var eblan:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var enemyStrums:FlxTypedGroup<FlxSprite>;
	private var crashStrum:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = true;
	private var curSong:String = "";

	private var healthP1:Float = 2;
	private var healthP2:Float = 2;
	private var healthP1TXT:FlxText;
	private var healthP2TXT:FlxText;
	private var hp1txtX:Float;
	private var hp2txtX:Float;
	private var combo:Int = 0;
	private var enemyCombo:Int = 0;

	private var barP1BG:FlxSprite;
	private var barP2BG:FlxSprite;
	private var barP1:FlxBar;
	private var barP2:FlxBar;
	private var barX:Float = -150;
	private var barY:Float = FlxG.height * 0.69;

	private var barP1grp:FlxTypedGroup<Dynamic>;
	private var barP2grp:FlxTypedGroup<Dynamic>;

	var p1PART:String;
	var p2PART:String;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var songScore:Int = 0;
	var enemyScore:Int = 0;
	var scoreTxt:FlxText;

	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var randomizer:Array<Float> = [5, 10, 30, 5]; //used for random opponent ratings
	var playerMisses:Int = 0;
	var enemyMisses:Int = 0;
	var isEnemyMiss:Bool = false;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	var inCutscene:Bool = false;

	#if DISCORD
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var camPos:FlxPoint;
	
	var boom:FlxSprite;
	var boomTween:FlxTween;

	var layer:FlxSprite;
	var smoke:FlxSprite;
	var smoke2:FlxSprite;

	override public function create() {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = new SwagCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('death-beat');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if DISCORD
		initDiscord();
		#end

		switch (SONG.song.toLowerCase()) {
			default:
				defaultCamZoom = 0.45;
				curStage = 'main';

				var sky:FlxSprite = new FlxSprite(-1680, -1000).loadGraphic(Paths.image('bgs/main/sky', 'songs'));
				sky.antialiasing = true;
				sky.updateHitbox;
				sky.scrollFactor.set(.7, .4);
				add(sky);

				var bgcity:FlxSprite = new FlxSprite(-1670, -900).loadGraphic(Paths.image('bgs/main/bgcity', 'songs'));
				bgcity.antialiasing = true;
				bgcity.setGraphicSize(Std.int(bgcity.width * 1.1));
				bgcity.updateHitbox;
				bgcity.scrollFactor.set(.8, .6);
				bgcity.alpha = .8;
				add(bgcity);

				var location:FlxSprite = new FlxSprite(-1630, -1000).loadGraphic(Paths.image('bgs/main/mainlocation', 'songs'));
				location.antialiasing = true;
				location.updateHitbox;
				add(location);

				var barrel:FlxSprite = new FlxSprite(-1630, -1000).loadGraphic(Paths.image('bgs/main/vsbochkafnf', 'songs'));
				barrel.antialiasing = true;
				barrel.updateHitbox;
				add(barrel);

				var smokeback:FlxSprite = new FlxSprite(-1700, -1000).loadGraphic(Paths.image('bgs/main/smokeback', 'songs'));
				smokeback.antialiasing = true;
				smokeback.updateHitbox;
				smokeback.scrollFactor.set(.85, .85);
				smokeback.alpha = .4;
				add(smokeback);

				smoke = new FlxSprite(-1630, -1000).loadGraphic(Paths.image('bgs/main/smoke', 'songs'));
				smoke.antialiasing = true;
				smoke.updateHitbox;
				smoke.scrollFactor.set(.7, 1);
				smoke.alpha = .4;

				smoke2 = new FlxSprite(-1630, -1000).loadGraphic(Paths.image('bgs/main/smokefront', 'songs'));
				smoke2.antialiasing = true;
				smoke2.updateHitbox;
				smoke2.flipX = true;
				smoke2.scrollFactor.set(.7, 1);
				smoke2.alpha = .4;

				layer = new FlxSprite(-1630, -1000).loadGraphic(Paths.image('bgs/main/layer', 'songs'));
				layer.antialiasing = true;
				layer.updateHitbox;
				layer.alpha = .75;
				layer.blend = ADD;
		}

		daun = new Character(70, 100, SONG.player2);

		camPos = new FlxPoint(daun.getMidpoint().x + 200, daun.getMidpoint().y - 200);

		switch (SONG.player2) {
			case 'darnell':
				daun.y += 100;
			case 'goldie':
				daun.x += 25;
				daun.y += 115;
		}

		eblan = new Boyfriend(1000, 450, SONG.player1);
		
		switch (SONG.player1) {
			case 'pico':
				eblan.y -= 200;
				eblan.x -= 300;
				camPos.y += 500;
		}

		add(daun);
		add(eblan);
		if (curStage == 'main') {
			add(smoke);
			add(smoke2);
			add(layer);
		}

		// shit/bad/good/miss
		switch (daun.curCharacter) {
			case 'goldie':
				randomizer = [3, 10, 30, 5];
			case 'absolute':
				randomizer = [2, 7, 30, 2];
			case 'shyllis':
				randomizer = [1, 5, 25, 1];
			case 'drey':
				randomizer = [5, 15, 50, 7];
			case 'rofos':
				randomizer = [5, 10, 35, 5];
			case 'soda':
				randomizer = [8, 30, 60, 8];
			case 'darnell':
				randomizer = [3, 7, 30, 2];
		}

		Conductor.songPosition = -5000;

		boom = new FlxSprite(0, 0).loadGraphic(Paths.image('L', 'songs'));
		boom.antialiasing = true;
		boom.updateHitbox();
		boom.scrollFactor.set();
		boom.alpha = 0;
		boom.screenCenter();
		add(boom);
		
		strumLine = new FlxSprite(0, -20).makeGraphic(FlxG.width, 10);

		if (PreferencesMenu.getPref('downscroll'))
			strumLine.y = FlxG.height - 150; // 150 just random ass number lol

		strumLine.scrollFactor.set();

		p1PART = SONG.player1.toLowerCase();
		p2PART = SONG.player2.toLowerCase();

		for (i in 0...2)
		{	
			var arrowBar:FlxSprite = new FlxSprite(43 + (i * 610), strumLine.y + 55).loadGraphic(Paths.image((i == 1) ? 'characters/$p1PART/bar' : 'characters/$p2PART/bar', 'songs'));
			arrowBar.antialiasing = true;
			arrowBar.setGraphicSize(Std.int(arrowBar.width * 0.6));
			arrowBar.updateHitbox();
			arrowBar.scrollFactor.set();
			arrowBar.cameras = [camHUD];
			add(arrowBar);
		}

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		add(grpNoteSplashes);

		barP1grp = new FlxTypedGroup<Dynamic>();
		add(barP1grp);

		barP2grp = new FlxTypedGroup<Dynamic>();
		add(barP2grp);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();
		crashStrum = new FlxTypedGroup<FlxSprite>();

		generateSong();

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (PreferencesMenu.getPref('downscroll'))
			barY = FlxG.height * 0.1;

		var barbgScale:Float = 0.6;
		var barWH:Array<Int> = [340, 44];

		barP1BG = new FlxSprite(barX + 670, barY);
		barP1BG.frames = Paths.getSparrowAtlas('barassets/HPBARMAINPATTERN');
		barP1BG.animation.addByPrefix('idle', 'HPBARMAINPATTERN', 24, true);
		barP1BG.animation.play('idle');
		barP1BG.flipX = true;
		barP1BG.scrollFactor.set();

		barP2BG = new FlxSprite(barX, barY);
		barP2BG.frames = Paths.getSparrowAtlas('barassets/HPBARMAINPATTERN');
		barP2BG.animation.addByPrefix('idle', 'HPBARMAINPATTERN', 24, true);
		barP2BG.animation.play('idle');
		barP2BG.scrollFactor.set();

		barP1BG.scale.set(barbgScale, barbgScale);
		barP2BG.scale.set(barbgScale, barbgScale);

		barP1 = new FlxBar(barP1BG.x + 325, barP1BG.y + 114, LEFT_TO_RIGHT, barWH[0], barWH[1], this, 'healthP1', 0, 2);
		barP1.flipX = barP1BG.flipX;
		barP1.scrollFactor.set();
		barP1.createImageBar(Paths.image('barassets/defhp', 'songs'), Paths.image('characters/$p1PART/hpbar', 'songs'));

		barP2 = new FlxBar(barP2BG.x + 245, barP2BG.y + 114, LEFT_TO_RIGHT, barWH[0], barWH[1], this, 'healthP2', 0, 2);
		barP2.scrollFactor.set();
		barP2.createImageBar(Paths.image('barassets/defhp', 'songs'), Paths.image('characters/$p2PART/hpbar', 'songs'));

		barP1.scale.x = barP2.scale.x = 0.9;
		
		hp1txtX = barP1BG.x + 449.5;
		hp2txtX = barP2BG.x + 380;

		healthP1TXT = new FlxText(hp1txtX, barP1BG.y + 167.5, 0, barP1.percent + '%', 30);
		healthP1TXT.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		healthP2TXT = new FlxText(hp2txtX, barP2BG.y + 167.5, 0, barP2.percent + '%', 50);
		healthP2TXT.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		barP1grp.add(barP1);
		barP1grp.add(barP1BG);
		barP1grp.add(healthP1TXT);

		barP2grp.add(barP2);
		barP2grp.add(barP2BG);
		barP2grp.add(healthP2TXT);

		scoreTxt = new FlxText(250, -20, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		boom.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		barP1grp.cameras = [camHUD];
		barP2grp.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		#if android
		addHitbox(false);
		addHitboxCamera(false);
		#end

		startingSong = true;


		switch (curSong.toLowerCase())
		{
			default:
				startCountdown();
		}
		
		super.create();
	}

	function initDiscord():Void
	{
		#if DISCORD
		storyDifficultyText = CoolUtil.difficultyString();
		iconRPC = SONG.player2;

		detailsText = isStoryMode ? "Story Mode: Week " + storyWeek : "Freeplay";
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
	}

	var startTimer:FlxTimer = new FlxTimer();
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;
		camHUD.visible = true;
		#if android
		hitbox.visible = true;
		#end

		generateStaticArrows(0);
		generateStaticArrows(1);

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (swagCounter % 2 == 0)
			{
				if (!eblan.animation.curAnim.name.startsWith("sing"))
					eblan.playAnim('idle');
				if (!daun.animation.curAnim.name.startsWith("sing"))
					daun.dance();
			}
			if (generatedMusic)
				notes.sort(sortNotes, FlxSort.DESCENDING);

			var introSprPaths:Array<String> = ["ready", "set", "go"];
			var altSuffix:String = "";

			var introSndPaths:Array<String> = [
				"intro3" + altSuffix, "intro2" + altSuffix,
				"intro1" + altSuffix, "introGo" + altSuffix
			];

			if (swagCounter > 0)
				readySetGo(introSprPaths[swagCounter - 1]);
			FlxG.sound.play(Paths.sound(introSndPaths[swagCounter], 'songs'), 0.6);

			swagCounter += 1;
		}, 4);
	}

	function readySetGo(path:String):Void
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(path, 'songs'));
		spr.scrollFactor.set();

		spr.updateHitbox();
		spr.screenCenter();
		add(spr);
		FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				spr.destroy();
			}
		});
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		for (vocals in vocalArray)
			vocals.play();

		#if DISCORD
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	private function generateSong():Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
		{
			var daPenis:String = '';
			switch (SONG.song.toLowerCase()) {
				case 'metal-pipe':
					daPenis = 'Pico';
				case 'death-beat':
					daPenis = 'BF';
			}

			vocalsP1 = new FlxSound().loadEmbedded(Paths.voices(SONG.song, daPenis));
			
			switch (SONG.song.toLowerCase()) {
				case 'metal-pipe':
					daPenis = 'Darnell';
				case 'death-beat':
					daPenis = 'Kartoshka';
			}

			vocalsP2 = new FlxSound().loadEmbedded(Paths.voices(SONG.song, daPenis));
			vocalArray.push(vocalsP1);
			vocalArray.push(vocalsP2);
		}
		else
		{
			vocalsP1 = new FlxSound();
			vocalsP2 = new FlxSound();
		}

		for (vocals in vocalArray)
		{
			vocals.onComplete = function()
			{
				vocalsFinished = true;
			};
			FlxG.sound.list.add(vocals);
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;
		
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				if ((songNotes[1] >= 4 && section.mustHitSection) || (songNotes[1] <= 3 && !section.mustHitSection))
					songNotes[4] = false;
				else
					songNotes[4] = true;

				var swagNote:Note = new Note(daStrumTime, daNoteData, songNotes[4] ? SONG.player1.toLowerCase() : SONG.player2.toLowerCase(), oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.isPlayerNote = songNotes[4];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, songNotes[4] ? SONG.player1.toLowerCase() : SONG.player2.toLowerCase(), oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2.25 + 35; // general offset
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2.25 + 35; // general offset
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(order:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note) {
		return FlxSort.byValues(order, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void {
		var arrowPathShit:String = (player == 1) ? SONG.player1.toLowerCase() : SONG.player2.toLowerCase();
		for (i in 0...4) {
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y - 5);
			var crashArrow:FlxSprite = new FlxSprite();
			crashArrow.alpha = 0;

			babyArrow.frames = Paths.getSparrowAtlas('characters/$arrowPathShit/NOTE_assets');
			crashArrow.frames = Paths.getSparrowAtlas('CRASHNOTE_assets');
			babyArrow.antialiasing = true;
			crashArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.6));
			crashArrow.setGraphicSize(Std.int(crashArrow.width * 0.6));

			switch (Math.abs(i)) {
				case 0:
					babyArrow.animation.addByPrefix('static', 'leftstat');
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					crashArrow.animation.addByPrefix('press', 'left press', 24, false);
				case 1:
					babyArrow.x += -2 + Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'downstat');
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
					crashArrow.animation.addByPrefix('press', 'down press', 24, false);
				case 2:
					babyArrow.x += 3 + Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'upstat');
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
					crashArrow.animation.addByPrefix('press', 'up press', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'rightstat');
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					crashArrow.animation.addByPrefix('press', 'right press', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			crashArrow.updateHitbox();
			crashArrow.scrollFactor.set();

			if (!isStoryMode) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;
			crashArrow.ID = i;

			switch (player) {
				case 0:
					enemyStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
					crashStrum.add(crashArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += ((FlxG.width / 2.25 + 35) * player) - 10;
			crashArrow.animation.play('press');
			crashArrow.x = babyArrow.x;
			crashArrow.y = babyArrow.y;

			enemyStrums.forEach(function(spr:FlxSprite) {
				spr.centerOffsets();
			});

			strumLineNotes.add(babyArrow);
			if (player == 1)
				strumLineNotes.add(crashArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				for (vocals in vocalArray)
					vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if DISCORD
			if (startTimer.finished)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		super.closeSubState();
	}

	#if DISCORD
	override public function onFocus():Void
	{
		if (healthP1 > 0 && !paused && FlxG.autoPause)
		{
			if (Conductor.songPosition > 0.0)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (healthP1 > 0 && !paused && FlxG.autoPause)
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);

		super.onFocusLost();
	}
	#end

	function resyncVocals():Void
	{
		if (_exiting)
			return;

		for (vocals in vocalArray)
			vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		if (vocalsFinished)
			return;

		for (vocals in vocalArray)
		{
			vocals.time = Conductor.songPosition;
			vocals.play();
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.04);

		#if !debug
		perfectMode = false;
		#end
		
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		super.update(elapsed);

		scoreTxt.text = "Enemy Score:" + enemyScore  + " | Enemy Missed:" + enemyMisses + " || Player Score:" + songScore + " | Player Missed:" + playerMisses;
		scoreTxt.screenCenter(X);
		healthP1TXT.text = barP1.percent + '%';
		healthP2TXT.text = barP2.percent + '%';

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			var boyfriendPos = eblan.getScreenPosition();
			var pauseSubState = new PauseSubState(boyfriendPos.x, boyfriendPos.y);
			openSubState(pauseSubState);
			pauseSubState.camera = camHUD;
			boyfriendPos.put();

			#if DISCORD
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(new ChartingState());

			#if DISCORD
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if (FlxG.keys.justPressed.TAB)
			showScore();
		
		if (healthP1 < 0)
			healthP1 = 0;
		if (healthP2 < 0)
			healthP2 = 0;

		if (barP1.percent >= 100)
			healthP1TXT.x = hp1txtX;
		else if (barP1.percent < 100)
			healthP1TXT.x = hp1txtX + 10;
		else if (barP1.percent < 10)
			healthP1TXT.x = hp1txtX + 50;

		if (barP2.percent >= 100)
			healthP2TXT.x = hp2txtX;
		else if (barP2.percent < 100)
			healthP2TXT.x = hp2txtX + 10;
		else if (barP2.percent < 10)
			healthP2TXT.x = hp2txtX + 50;

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		if (FlxG.keys.justPressed.PAGEUP)
			changeSection(1);
		if (FlxG.keys.justPressed.PAGEDOWN)
			changeSection(-1);
		#end

		if (FlxG.keys.justPressed.EIGHT)
		{
			if (FlxG.keys.pressed.SHIFT)
				FlxG.switchState(new AnimationDebug(SONG.player1));
			else
				FlxG.switchState(new AnimationDebug(SONG.player2));
		}

		if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null)
		{
			cameraRightSide = SONG.notes[Std.int(curStep / 16)].mustHitSection;

			cameraMovement();
		}

		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (!inCutscene && !_exiting)
		{
			if (controls.RESET)
				healthP1 = 0;

			#if CAN_CHEAT
			if (controls.CHEAT)
				healthP1 += 1;
			#end

			if (healthP1 <= 0)
			{
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				for (vocals in vocalArray)
					vocals.stop();
				FlxG.sound.music.stop();

				deathCounter += 1;

				openSubState(new GameOverSubstate(eblan.getScreenPosition().x, eblan.getScreenPosition().y));

				#if DISCORD
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
			}
		}

		while (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed) {
			var dunceNote:Note = unspawnNotes[0];
			notes.add(dunceNote);

			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.shift();
		}

		if (generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if ((PreferencesMenu.getPref('downscroll') && daNote.y < -daNote.height)
					|| (!PreferencesMenu.getPref('downscroll') && daNote.y > FlxG.height))
				{
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = true;
					daNote.active = true;
				}

				var strumLineMid = strumLine.y + Note.swagWidth / 2;

				if (PreferencesMenu.getPref('downscroll')) {
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote) {
						if (daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						if ((!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
							&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= strumLineMid) {
							var swagRect:FlxRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);

							swagRect.height = (strumLineMid - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
						&& daNote.y + daNote.offset.y * daNote.scale.y <= strumLineMid) {
						var swagRect:FlxRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);

						swagRect.y = (strumLineMid - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;
						daNote.clipRect = swagRect;
					}
				}

				if (isEnemyMiss && !daNote.isPlayerNote) {
					daNote.mustPress = true;
					isEnemyMiss = false;
				}

				if (!daNote.mustPress && daNote.wasGoodHit) {
					isEnemyMiss = !daNote.isPlayerNote ? FlxG.random.bool(randomizer[3]) : false;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null) {
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (daNote.altNote)
						altAnim = '-alt';

					switch (Math.abs(daNote.noteData)) {
						case 0:
							daun.playAnim('singLEFT' + altAnim, true);
						case 1:
							daun.playAnim('singDOWN' + altAnim, true);
						case 2:
							daun.playAnim('singUP' + altAnim, true);
						case 3:
							daun.playAnim('singRIGHT' + altAnim, true);
					}

					if (daun.holdTimer > Conductor.stepCrochet * 4 * 0.001) {
						if (daun.animation.curAnim.name.startsWith('sing') && !daun.animation.curAnim.name.endsWith('miss'))
							daun.dance();
					}

					enemyStrums.forEach(function(spr:FlxSprite) {
						if (Math.abs(daNote.noteData) == spr.ID)
							spr.animation.play('confirm', true);
						else
							spr.animation.play('static', true);
						
						if (spr.animation.curAnim.name == 'confirm') {
							spr.centerOffsets();
							var addToOffset:Array<Array<Int>> = [[-25, 20], [-6, 19], [-9, -3], [9, 16]];
							spr.offset.x -= 40 + addToOffset[Std.int(spr.ID)][0];
							spr.offset.y -= 20 + addToOffset[Std.int(spr.ID)][1];
						} else
							spr.centerOffsets();
					});

					if(!daNote.isSustainNote) {
						enemyCombo++;
						popUpScore(daNote.strumTime, daNote, 2);
					}
					
					daun.holdTimer = 0;

					if (SONG.needsVoices)
						for (vocals in vocalArray)
							vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.isSustainNote && daNote.wasGoodHit) {
					if ((!PreferencesMenu.getPref('downscroll') && daNote.y < -daNote.height)
						|| (PreferencesMenu.getPref('downscroll') && daNote.y > FlxG.height)) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				} else if (daNote.tooLate || daNote.wasGoodHit) {
					if (daNote.tooLate && !daNote.isSustainNote) {
						if (daNote.isPlayerNote)
							noteMiss(Std.int(Math.abs(daNote.noteData)), false, "eblan", 0.0075);
						else
							noteMiss(Std.int(Math.abs(daNote.noteData)), false, "daun", 0.0075);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		enemyStrums.forEach(function(spr:FlxSprite) {
			if (spr.animation.finished) {
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (!inCutscene)
			keyShit();
	}

	function killCombo(player:Int = 1):Void {
		if (player == 1) {
			if (combo > 50)
				LLLLL();
			if (combo != 0) {
				combo = 0;
				displayCombo();
			}
		} else {
			if (enemyCombo != 0) {
				enemyCombo = 0;
				displayCombo(2);
			}
		}
	}

	function LLLLL()
	{
		if(boomTween != null)
			boomTween.cancel();

		boom.alpha = 1;
		boomTween = FlxTween.tween(boom, {alpha: 0}, 1);
		FlxG.sound.play(Paths.sound('vineBoom', 'songs'));
	}

	var scoreTween:FlxTween;
	var scoreTxtVisible:Bool = false;
	function showScore()
	{
		if(scoreTween != null)
			scoreTween.cancel();

		if (!scoreTxtVisible) {
			scoreTxtVisible = true;
			scoreTween = FlxTween.tween(scoreTxt, {y: 18}, 0.5, {ease: FlxEase.cubeInOut});
		} else {
			scoreTxtVisible = false;
			scoreTween = FlxTween.tween(scoreTxt, {y: -20}, 0.5, {ease: FlxEase.cubeInOut});
		}
	}

	#if debug
	function changeSection(sec:Int):Void
	{
		FlxG.sound.music.pause();

		var daBPM:Float = SONG.bpm;
		var daPos:Float = 0;
		for (i in 0...(Std.int(curStep / 16 + sec)))
		{
			if (SONG.notes[i].changeBPM)
			{
				daBPM = SONG.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		Conductor.songPosition = FlxG.sound.music.time = daPos;
		updateCurStep();
		resyncVocals();
	}
	#end

	function endSong():Void
	{
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		for (vocals in vocalArray)
			vocals.volume = 0;
		#if android
		removeHitbox();
		#end
		if (SONG.validScore)
		{
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.sound('freakyMenu', 'menus'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				switch (PlayState.storyWeek)
				{
					default:
						LoadingState.path = 'menus';
						LoadingState.bullshit = new StoryMenuState();
						FlxG.switchState(new LoadingState());
				}

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-fine';

				if (storyDifficulty == 1)
					difficulty = '-obed';

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				FlxG.sound.music.stop();
				for (vocals in vocalArray)
					vocals.stop();
				prevCamFollow = camFollow;

				SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase() + difficulty, storyPlaylist[0]);
				LoadingState.path = 'songs';
				LoadingState.bullshit = new PlayState();
				LoadingState.daSong = SONG;
				FlxG.switchState(new LoadingState());
			}
		}
		else
		{
			LoadingState.path = 'menus';
			LoadingState.bullshit = new FreeplayState();
			FlxG.switchState(new LoadingState());
		}
	}

	private function ratingPizdos() {
		var daRating:String = 'sick';
		
		if (FlxG.random.bool(randomizer[0]))
			daRating = 'shit';
		else if (FlxG.random.bool(randomizer[1]) && daRating != 'shit')
			daRating = 'bad';
		else if (FlxG.random.bool(randomizer[2]) && daRating != 'shit' && daRating != 'bad')
			daRating = 'good';
		
		return daRating;
	}

	private function popUpScore(strumtime:Float, daNote:Note, player:Int = 1):Void {
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		for (vocals in vocalArray)
			vocals.volume = 1;

		var rating:FlxSprite = new FlxSprite();
		var daRating:String = "sick";

		if (player == 1) {
			if (noteDiff > Conductor.safeZoneOffset * 0.5)
				daRating = 'shit';
			else if (noteDiff > Conductor.safeZoneOffset * 0.25)
				daRating = 'bad';
			else if (noteDiff > Conductor.safeZoneOffset * 0.1)
				daRating = 'good';
		} else
			daRating = ratingPizdos();

		if (player == 1) {
			switch (daRating) {
				case 'shit':
					songScore += 60;
					killCombo();
				case 'bad':
					songScore += 100;
				case 'good':
					songScore += 200;
				default:
					songScore += 350;
					doNoteSplash(daNote, SONG.player1.toLowerCase());
			}
		} else {
			switch (daRating) {
				case 'shit':
					enemyScore += 60;
					killCombo(2);
				case 'bad':
					enemyScore += 100;
				case 'good':
					enemyScore += 200;
				default:
					enemyScore += 350;
					doNoteSplash(daNote, SONG.player2.toLowerCase());
			}
		}

		rating.loadGraphic(Paths.image(daRating, 'songs'));
		rating.x = FlxG.width * 0.55 + 200;
		if (player != 1)
			rating.x -= 600;
		if (rating.x < FlxG.camera.scroll.x)
			rating.x = FlxG.camera.scroll.x;
		else if (rating.x > FlxG.camera.scroll.x + FlxG.camera.width - rating.width)
			rating.x = FlxG.camera.scroll.x + FlxG.camera.width - rating.width;

		rating.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 - 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = true;
		rating.updateHitbox();
		add(rating);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {onComplete: function(tween:FlxTween) { rating.destroy(); }, startDelay: Conductor.crochet * 0.001});

		if ((combo >= 10 || combo == 0) || (enemyCombo >= 10 || enemyCombo == 0))
			displayCombo(player);
	}

	function displayCombo(player:Int = 1):Void
	{
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo', 'songs'));
		comboSpr.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 + 80;
		comboSpr.x = FlxG.width * 0.55 + 280;
		if (player != 1)
			comboSpr.x -= 600;
		if (comboSpr.x < FlxG.camera.scroll.x + 194)
			comboSpr.x = FlxG.camera.scroll.x + 194;
		else if (comboSpr.x > FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width)
			comboSpr.x = FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width;

		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(comboSpr);
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.antialiasing = true;
		comboSpr.updateHitbox();

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		var seperatedScore:Array<Int> = [];
		var tempCombo:Int = combo;

		if (player != 1)
			tempCombo = enemyCombo;

		while (tempCombo != 0)
		{
			seperatedScore.push(tempCombo % 10);
			tempCombo = Std.int(tempCombo / 10);
		}
		while (seperatedScore.length < 3)
			seperatedScore.push(0);

		var daLoop:Int = 1;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i), 'songs'));
			numScore.y = comboSpr.y;
			numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			numScore.x = comboSpr.x - (43 * daLoop);
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
	}

	var cameraRightSide:Bool = false;

	function cameraMovement() {
		if (camFollow.x != daun.getMidpoint().x + 250 && !cameraRightSide)
			camFollow.setPosition(daun.getMidpoint().x + 250, daun.getMidpoint().y - 180);

		if (cameraRightSide && camFollow.x != eblan.getMidpoint().x - 250)
			camFollow.setPosition(eblan.getMidpoint().x - 250, eblan.getMidpoint().y - 260);
	}

	function doNoteSplash(note:Note, player:String) {
		var splashThing:Int = 1;

		switch (note.noteData) {
			case 1 | 3:
				splashThing = 2;
		}
		
		if (player == 'prettyboy')
			splashThing = 3;
			
		var noteSplash:NoteSplash = new NoteSplash(note.x - 100, strumLine.y - 90, player, splashThing);
		grpNoteSplashes.add(noteSplash);
	}

	private function keyShit():Void
	{
		var holdArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var pressArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
		var releaseArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];

		if (holdArray.contains(true) && generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		if (pressArray.contains(true) && generatedMusic) {
			eblan.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					if (directionList.contains(daNote.noteData)) {
						for (coolNote in possibleNotes) {
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10) {
								dumbNotes.push(daNote);
								break;
							} else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime) {
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					} else {
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (perfectMode)
				goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0) {
				for (shit in 0...pressArray.length) {
					if (pressArray[shit] && !directionList.contains(shit))
						noteMiss(shit, true);
				}

				for (coolNote in possibleNotes) {
					if (pressArray[coolNote.noteData])
						goodNoteHit(coolNote);
				}
			} else {
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit, true);
			}
		}

		if (eblan.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true)) {
			if (eblan.animation.curAnim.name.startsWith('sing') && !eblan.animation.curAnim.name.endsWith('miss'))
				eblan.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite) {
			if (!holdArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm') {
				spr.centerOffsets();
				var addToOffset:Array<Array<Int>> = [[-25, 20], [-6, 19], [-9, -3], [9, 16]];
				spr.offset.x -= 40 + addToOffset[Std.int(spr.ID)][0];
				spr.offset.y -= 20 + addToOffset[Std.int(spr.ID)][1];
			} else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1, isCrashNote:Bool = false, player:String = 'eblan', additionalHealthDown:Float = 0):Void
	{
		switch (player)
		{
			case 'eblan':
				songScore -= 10;
				healthP1 -= 0.1 + additionalHealthDown;
				playerMisses++;
				killCombo();
				vocalsP1.volume = 0;

				switch (direction)
				{
					case 0:
						eblan.playAnim('singLEFTmiss', true);
					case 1:
						eblan.playAnim('singDOWNmiss', true);
					case 2:
						eblan.playAnim('singUPmiss', true);
					case 3:
						eblan.playAnim('singRIGHTmiss', true);
				}

				if (isCrashNote)
				{
					crashStrum.forEach(function(cspr:FlxSprite)
					{
						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (spr.ID == direction) {
								spr.alpha = 0.001;
								new FlxTimer().start(0.2, function(tmr:FlxTimer) {
									spr.alpha = 1;
								});
							}

							if (cspr.ID == direction)
							{
								cspr.alpha = 1;
								cspr.animation.play('press');
								// я заебался оффсеты делать нахуй завтра крч
								var addToOffset:Array<Array<Int>> = [[-25, 20], [-6, 19], [-9, -3], [9, 16]];
								cspr.offset.x -= 40 + addToOffset[Std.int(cspr.ID)][0];
								cspr.offset.y -= 20 + addToOffset[Std.int(cspr.ID)][1];
								new FlxTimer().start(0.2, function(tmr:FlxTimer) {
									cspr.alpha = 0.001;
								});
							}
						});
					});
				}
			case 'daun':
				enemyScore -= 10;
				healthP2 -= 0.1 + additionalHealthDown;
				enemyMisses++;
				vocalsP2.volume = 0;
				killCombo(2);

				switch (direction)
				{
					case 0:
						daun.playAnim('singLEFTmiss', true);
					case 1:
						daun.playAnim('singDOWNmiss', true);
					case 2:
						daun.playAnim('singUPmiss', true);
					case 3:
						daun.playAnim('singRIGHTmiss', true);
				}
		}
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'songs'), FlxG.random.float(0.1, 0.2));
	}

	function goodNoteHit(note:Note):Void {
		if (!note.wasGoodHit) {
			if (!note.isSustainNote) {
				combo += 1;
				popUpScore(note.strumTime, note);
			}

			switch (note.noteData) {
				case 0:
					eblan.playAnim('singLEFT', true);
				case 1:
					eblan.playAnim('singDOWN', true);
				case 2:
					eblan.playAnim('singUP', true);
				case 3:
					eblan.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite) {
				if (Math.abs(note.noteData) == spr.ID)
					spr.animation.play('confirm', true);
			});

			note.wasGoodHit = true;
			for (vocals in vocalArray)
				vocals.volume = 1;

			if (!note.isSustainNote) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	override function stepHit() {
		super.stepHit();
		for (vocals in vocalArray) {
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
				|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
				resyncVocals();
		}
	}

	override function beatHit() {
		super.beatHit();

		notes.forEachAlive(function(daNote:Note) {
			daNote.beatHit();
		});

		if (generatedMusic)
			notes.sort(sortNotes, FlxSort.DESCENDING);

		if (SONG.notes[Math.floor(curStep / 16)] != null) {
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
		}

		if (curSong.toLowerCase() == 'death-beat' && curBeat >= 204 && curBeat < 266 && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curSong.toLowerCase() == 'death-beat' && curBeat == 204) {
			defaultCamZoom = 0.5;
			camZooming = false;
		} else if (curSong.toLowerCase() == 'death-beat' && curBeat == 266) {
			defaultCamZoom = 0.45;
			camZooming = true;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curBeat % 2 == 0) {
			if (!eblan.animation.curAnim.name.startsWith("sing"))
				eblan.playAnim('idle');
			if (!daun.animation.curAnim.name.startsWith("sing"))
				daun.dance();
		}
	}
}
