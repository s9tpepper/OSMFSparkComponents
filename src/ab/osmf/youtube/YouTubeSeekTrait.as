package ab.osmf.youtube
{
	import ab.flash.youtube.YouTubePlayer;
	
	import org.osmf.events.SeekEvent;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;

	/**
	 * YouTubeSeekTrait is used to implement the SeekTrait using the
	 * YouTube chromeless API.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class YouTubeSeekTrait extends SeekTrait
	{
		private var _youTubePlayer:YouTubePlayer;

		public function YouTubeSeekTrait(youTubePlayer:YouTubePlayer, timeTrait:YouTubeTimeTrait)
		{
			super(timeTrait);
			
			_youTubePlayer = youTubePlayer;
			
		}
		
		override public function canSeekTo(time:Number):Boolean
		{
			// Always returns true because YouTube lets you scrub ahead.
			return true;
		}
		
		override protected function seekingChangeStart(newSeeking:Boolean, time:Number):void
		{
			if (newSeeking)
			{
				_youTubePlayer.seekTo(time, true);
			}
		}
		
		override protected function seekingChangeEnd(time:Number):void
		{
			super.seekingChangeEnd(time);

			if (seeking)
				setSeeking(false, time);
		}
	}
}