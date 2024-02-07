package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.FPS;
import openfl.display.Sprite;
import flixel.FlxG;

class Main extends Sprite {
	var framerate:Int = 144;

	public static var self:Main;
	public static var fpsCounter:FPS;

	public function new() {
		super();

		self = this;

		FlxG.signals.gameResized.add(onResizeGame);

		#if linux
		var icon = lime.graphics.Image.fromFile("icon.png");
		openfl.Lib.current.stage.window.setIcon(icon);
		#end

		addChild(new FlxGame(1280, 720, LoadingState, framerate, framerate, true));
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);

		Init.Initialize();
		
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

	}

	private function onResizeGame(width:Int, height:Int):Void {
		if (FlxG.cameras == null)
			return;

		for (cam in FlxG.cameras.list) {
			@:privateAccess
			if (cam != null && (cam._filters != null && cam._filters.length > 0)) {
				var sprite:Sprite = cam.flashSprite;
				if (sprite != null) {
					sprite.__cacheBitmap = null;
					sprite.__cacheBitmapData = null;
					sprite.__cacheBitmapData2 = null;
					sprite.__cacheBitmapData3 = null;
					sprite.__cacheBitmapColorTransform = null;
				}
			}
		}
	}
}
