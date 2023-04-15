package;

#if DISCORD
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import sys.thread.Thread;

class DiscordClient
{
	public function new():Void
	{
		trace("Discord Client starting...");

		var handlers:DiscordEventHandlers = DiscordEventHandlers.create();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize("1096370715017629746", cpp.RawPointer.addressOf(handlers), 1, null);

		trace("Discord Client started.");

		while (true)
		{
			#if DISCORD_DISABLE_IO_THREAD
			Discord.UpdateConnection();
			#end
			Discord.RunCallbacks();
			Sys.sleep(2);
		}

		Discord.Shutdown();
	}

	public static function shutdown():Void
	{
		Discord.Shutdown();
	}

	public static function initialize():Void
	{
		Thread.create(function()
		{
			new DiscordClient();
		});

		trace("Discord Client initialized");
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;
		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		var discordPresence:DiscordRichPresence = DiscordRichPresence.create();
		discordPresence.details = details;
		discordPresence.details = state;
		discordPresence.largeImageKey = "icon";
		discordPresence.largeImageText = "Friday Night Funkin'";
		discordPresence.smallImageKey = smallImageKey;
		// Obtained times are in milliseconds so they are divided so Discord can use it
		discordPresence.startTimestamp = Std.int(startTimestamp / 1000);
		discordPresence.endTimestamp = Std.int(endTimestamp / 1000);
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		var requestPtr:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;

		trace('Discord: Connected to User (' + cast(requestPtr.username, String) + '#' + cast(requestPtr.discriminator, String) + ')');

		var discordPresence:DiscordRichPresence = DiscordRichPresence.create();
		discordPresence.details = "Starting";
		discordPresence.largeImageKey = "icon";
		discordPresence.largeImageText = "Friday Night Funkin'";
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Disconnected (' + errorCode + ': ' + cast(message, String) + ')');
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Error (' + errorCode + ': ' + cast(message, String) + ')');
	}
}
#end