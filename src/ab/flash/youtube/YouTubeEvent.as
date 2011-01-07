package ab.flash.youtube
{
	import flash.events.Event;
	
	/**
	 * Defines events dispatched by the YouTubePlayer class.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */	
	public class YouTubeEvent extends Event
	{
		static public const STATE_CHANGE:String = "youTube_stateChangeEvent";
		static public const ERROR:String = "youTube_errorEvent";
		static public const QUALITY_CHANGE:String = "youTube_qualityChangeEvent";
		/**
		 * This event is dispatched to notify about playback progress.  The property
		 * timeElapsed will contained how many seconds have elapsed since the video
		 * started playing and totalTime will be the amount of seconds of the
		 * video duration.
		 */		
		static public const PLAYBACK_PROGRESS:String = "youTube_playbackProgressEvent";
		
		public var state:Number;
		public var error:Number;
		public var quality:String;
		
		public var timeElapsed:Number;
		public var totalTime:Number;
		
		public function YouTubeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}