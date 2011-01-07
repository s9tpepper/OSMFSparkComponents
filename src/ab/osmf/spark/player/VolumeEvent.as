package ab.osmf.spark.player
{
	import flash.events.Event;
	
	/**
	 * VolumeEvent defines volume events dispatched by OSMFSparkPlayer.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class VolumeEvent extends Event
	{
		static public const VOLUME_CHANGED:String = "osmfPlayer_volumeChangedEvent";
		static public const TOGGLE_MUTE:String = "osmfPlayer_toggleMuteEvent";
		
		public var volume:Number;
		
		public function VolumeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}