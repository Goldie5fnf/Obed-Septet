package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class LoadingScreen extends FlxTypedGroup<FlxSprite> {
	var loading:FlxSprite;
	var loadTxt:FlxText;

	public function new() {
		super();

		loading = new FlxSprite(1120, 550);
		loading.frames = Paths.getSparrowAtlas('loading', 'global');
		loading.animation.addByPrefix('loading', 'loading', 12, true);
		loading.animation.play('loading');
		loading.setGraphicSize(Std.int(loading.width * 0.2));
		add(loading);

		loadTxt = new FlxText(5, FlxG.height - 25, 0, "", 16);
		loadTxt.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadTxt);
	}

	override function update(elapsed:Float) {
		loading.angle += 3;

		super.update(elapsed);
	}

	public function setLoadingText(text:String) {
		loadTxt.text = text;
	}
}