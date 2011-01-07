package ab.osmf.spark.player
{
	import flash.events.Event;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	
	/**
	 * OSMFSparkPlayerEvent defines general media events dispatched by OSMFSparkPlayer.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class OSMFSparkPlayerEvent extends Event
	{
		static public const MEDIA_COMPLETED_PLAYING:String = "osmfplayer_mediaCompletePlayingEvent";
		
		static public const MEDIA_PAUSED:String = "osmf_mediaPausedEvent";
		
		static public const MEDIA_PLAYING:String = "osmf_mediaPlayingEvent";
		
		public var urlResource:URLResource;
		
		public function OSMFSparkPlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}