/**
	Do not add this system directly, it is included automatically when using -Dprofiler.
	The profile system gives you a look at how much time each system is using. Hit P
	to dump to the log the current profile results. You can change the dump key by 
	setting ProfileSystem.dumpKey at your application boostrap.

	TODO:
		- Remove dependence on other Systems
		- Add overall frame rate logging.
		- Add percentage of app time not tracked by ProfileSystems 
 */
package flaxen.system;

import com.haxepunk.HXP;
import com.haxepunk.utils.Key;
import flaxen.core.Flaxen;
import flaxen.core.Log;
import flaxen.core.FlaxenSystem;
import flaxen.service.InputService;

class ProfileSystem extends FlaxenSystem
{
	private static var stats:ProfileStats = new ProfileStats();
	public static var triggerKey:Int = Key.P;

	public var profile:Profile;
	public var opener:Bool;

	public function new(flaxen:Flaxen, name:String, opener:Bool)
	{
		super(flaxen);

		profile = stats.getOrCreate(name);
		this.opener = opener;
	}

	override public function update(_)
	{	
		if(opener)
			profile.open();
		else profile.close();

		if(InputService.lastKey() == triggerKey)
		{
			InputService.clearLastKey();
			stats.dump();
		}
	}
}

class ProfileStats
{
	private var stats:Map<String,Profile>;

	public function new()
	{
		stats = new Map<String, Profile>();
	}

	public function create(name:String): Profile
	{
		var profile = new Profile(name);
		stats.set(name, profile);

		if(stats.get(name) == null)
			Log.error("Creation didn't stick!");

		return profile;
	}

	public function get(name:String): Profile
	{
		return stats.get(name);
	}

	public function getOrCreate(name:String): Profile
	{
		var profile = get(name);
		if(profile == null)
			profile = create(name);
		return profile;
	}

	public function reset(): Void
	{
		for(profile in stats)
		{
			profile.startTime = -1;
			profile.totalTime = 0;
			profile.totalCalls = 0;
		}		
	}

	public function dump()
	{
		var totalTime:Int = 0;
		for(profile in stats)
			totalTime += profile.totalTime;
		
		Log.log("PROFILE:");
		for(name in stats.keys())
			logProfile(name, totalTime);
	}

	public function logProfile(name:String, totalTime:Int)
	{
		var profile = stats.get(name);
		Log.log(name + ": " + 
			format(profile.totalTime / 1000) + 
			" sec overall (" + format(profile.totalTime / totalTime * 100)  +  "%), " + profile.totalCalls + 
			" calls, " + 
			format(profile.totalTime / profile.totalCalls) + 
			"ms/call, " +
			format(profile.totalCalls / profile.totalTime * 1000) +
			" calls/sec");
	}

	public function format(time:Float): String
	{
		return cast HXP.round(time, 2);
	}
}

class Profile
{
	public var startTime:Int = -1;
	public var totalTime:Int = 0;	
	public var totalCalls:Int = 0;
	public var name:String;

	public function new(name:String)
	{
		this.name = name;
	}

	public function open(): Profile
	{
		startTime = flash.Lib.getTimer();
		return this;
	}

	public function close(): Profile
	{
		// Damn you for trying to close a closed profile; you think you're funny wise guy? 
		if(startTime == -1)
			return this;

		var endTime = flash.Lib.getTimer();
		totalTime += (endTime - startTime);
		totalCalls++;
		startTime = -1;
		return this;
	}
}