package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.input.mouse.FlxMouseEventManager;
import ui.OptionsState;

using StringTools;

#if DISCORD
import DiscordClient.DiscordClient;
#end

class MainMenuState extends MusicBeatState {
	var playedAnim:Bool = false;
	var stopSpamming:Bool = false;
	
	var logo:FlxSprite;
	var logoBump:Bool = false;

	var story:FlxSprite;
	var freeplay:FlxSprite;
	var options:FlxSprite;

	var camButtons:FlxCamera;
	
	var mouseEvent:FlxMouseEventManager;
	var mouseEventLogo:FlxMouseEventManager;

	var camtoMouse:FlxObject;
	var camCorners:Array<Dynamic> = [[416, 900], [300, 570]];
	
	function onMouseDown(balls:FlxSprite) {
		if (balls == story) {
			goToState(0);
		} else if (balls == freeplay) {
			goToState(1);
		} else if (balls == options) {
			goToState(2);
		} else if (balls == logo) {
			goToState(3);
		}
	}

	override function create() {
		#if DISCORD
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.sound('freakyMenu', 'menus'));

		persistentUpdate = persistentDraw = true;

		camButtons = new FlxCamera();
		camButtons.bgColor.alpha = 0;
		FlxG.cameras.add(camButtons, false);

		FlxG.cameras.reset(new SwagCamera());

		camtoMouse = new FlxObject(0, 0, 1, 1);
		FlxG.camera.follow(camtoMouse, LOCKON, 0.05);

		FlxG.mouse.visible = true;

		mouseEvent = new FlxMouseEventManager();
		add(mouseEvent);

		mouseEventLogo = new FlxMouseEventManager();
		add(mouseEventLogo);

		var bg:FlxSprite = new FlxSprite(Paths.image('bg', 'menus'));
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		logo = new FlxSprite(-285, -290);
		logo.frames = Paths.getSparrowAtlas('mainmenu/logo', 'menus');
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.antialiasing = true;
		logo.setGraphicSize(Std.int(logo.width * 0.6));
		add(logo);

		story = new FlxSprite(0, 320).loadGraphic(Paths.image('mainmenu/story_static', 'menus'));
		story.antialiasing = true;
		story.setGraphicSize(Std.int(story.width * 0.8));
		story.updateHitbox();
		story.screenCenter(X);
		add(story);
		
		freeplay = new FlxSprite(0, 480).loadGraphic(Paths.image('mainmenu/freeplay_static', 'menus'));
		freeplay.antialiasing = true;
		freeplay.setGraphicSize(Std.int(freeplay.width * 0.8));
		freeplay.updateHitbox();
		freeplay.screenCenter(X);
		add(freeplay);
		
		options = new FlxSprite(0, 620).loadGraphic(Paths.image('mainmenu/options_static', 'menus'));
		options.antialiasing = true;
		options.setGraphicSize(Std.int(options.width * 0.8));
		options.updateHitbox();
		options.screenCenter(X);
		add(options);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Obed Engine v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		#if mobile
		addVirtualPad(UP_DOWN, A_B);
		#end

		for (penis in [story, freeplay, options]) {
			mouseEvent.add(penis, onMouseDown);
			penis.cameras = [camButtons];
		}

		mouseEventLogo.add(logo, onMouseDown);
		logo.cameras = [camButtons];

		super.create();
	}

	function goToState(sex:Int)
	{
		switch (sex) {
			case 0:
				FlxG.switchState(new StoryMenuState());
			case 1:
				FlxG.switchState(new FreeplayState());
			case 2:
				FlxG.switchState(new ui.OptionsState());
			case 3:
				//
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		camtoMouse.x = FlxG.mouse.x;
		camtoMouse.y = FlxG.mouse.y;

		if (camtoMouse.x < camCorners[0][0])
			camtoMouse.x = camCorners[0][0];
		else if (camtoMouse.x > camCorners[0][1])
			camtoMouse.x = camCorners[0][1];

		if (camtoMouse.y < camCorners[1][0])
			camtoMouse.y = camCorners[1][0];
		if (camtoMouse.y > camCorners[1][1])
			camtoMouse.y = camCorners[1][1];

		super.update(elapsed);
	}

	override function beatHit() {
		super.beatHit();
		
		if (logoBump)
			logo.animation.play('bump', true);
		else
			logo.animation.curAnim = null;
	}
}