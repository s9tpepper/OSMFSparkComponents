package ab.osmf.spark.player
{
	import flash.events.Event;
	
	public class ScrubberEvent extends Event
	{
		static public const STARTED_SCRUBBING:String = "osmf_sparkcomponents_startedScrubbingEvent";
		static public const SCRUBBING:String = "osmf_sparkcomponents_scrubbingEvent";
		static public const SCRUBBING_STOPPED:String = "osmf_sparkcomponents_scrubbingStoppedEvent";
		
		public var scrubToPercentage:Number;
		
		public function ScrubberEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}