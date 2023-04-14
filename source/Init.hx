package;

import flixel.FlxG;
import flixel.FlxState;
import lime.app.Application;
import ui.PreferencesMenu;
#if windows
import Discord.DiscordClient;
#end

class Init {
	function new() {}

	public static function Initialize() {
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = [ZERO];
		FlxG.save.bind('funkin', 'ninjamuffin99');
		PreferencesMenu.initPrefs();
		PlayerSettings.init();
		Highscore.load();
		#if DISCORD
		DiscordClient.initialize();
		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end
	}
}
