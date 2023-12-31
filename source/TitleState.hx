package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.ui.Window;
import openfl.Assets;
import openfl.events.AsyncErrorEvent;
import openfl.events.AsyncErrorEvent;
import openfl.events.Event;
import openfl.events.MouseEvent;
import ui.PreferencesMenu;

using StringTools;

#if DISCORD
import DiscordClient.DiscordClient;
#end
#if desktop
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
#end

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var startedIntro:Bool;

	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];
	var lastBeat:Int = 0;

	override public function create():Void
	{
		#if DISCORD
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		startedIntro = false;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(0, 0),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(0, 0),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
		}

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.sound('freakyMenu', 'menus'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo', 'menus'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		startedIntro = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.onComplete = null;

			FlxG.camera.flash(FlxColor.WHITE, 1);

			transitioning = true;

			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (!startedIntro)
			return;
		
		if (curBeat > lastBeat)
		{
			for (i in lastBeat...curBeat)
			{
				switch (i + 1)
				{
					case 1:
						createCoolText(['project']);
					case 3:
						addMoreText('ellipsis');
					case 4:
						deleteCoolText();
					case 5:
						createCoolText(['Not in association', 'with']);
					case 7:
						addMoreText('newgrounds');
						ngSpr.visible = true;
					case 8:
						deleteCoolText();
						ngSpr.visible = false;
					case 9:
						createCoolText([curWacky[0]]);
					case 11:
						addMoreText(curWacky[1]);
					case 12:
						deleteCoolText();
					case 13:
						addMoreText('NeforFunk');
					case 14:
						addMoreText('...');
					case 16:
						skipIntro();
				}
			}
		}
		lastBeat = curBeat;
	}

	function skipIntro():Void
	{
		if (!transitioning)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.onComplete = null;

			FlxG.camera.flash(FlxColor.WHITE, 1);

			transitioning = true;

			FlxG.switchState(new MainMenuState());
		}
	}
}
