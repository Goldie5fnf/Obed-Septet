package;

import flixel.FlxG;
import flixel.FlxState;
import lime.app.Application;
import ui.PreferencesMenu;
import flixel.system.scaleModes.*;
#if windows
import DiscordClient.DiscordClient;
#end

class Init
{
	function new() {}

	public static function Initialize()
	{
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = [ZERO];
		FlxG.save.bind('obedseptet', 'kawaiisex');
		FlxG.scaleMode = new RatioScaleMode();
		PreferencesMenu.initPrefs();
		PlayerSettings.init();
		#if DISCORD
		DiscordClient.initialize();
		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end
	}
}
