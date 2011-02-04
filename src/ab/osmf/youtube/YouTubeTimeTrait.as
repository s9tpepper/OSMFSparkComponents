package ab.osmf.youtube
{
	import ab.flash.youtube.YouTubeEvent;
	import ab.flash.youtube.YouTubePlayer;
	
	import flash.utils.setTimeout;
	
	import org.osmf.events.TimeEvent;
	import org.osmf.traits.TimeTrait;
	
	/**
	 * YouTubeTimeTrait is used to implement TimeTrait using the
	 * YouTube chromeless API to display playback progress.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class YouTubeTimeTrait extends TimeTrait
	{
		private var _youTubePlayer:YouTubePlayer;

		public function YouTubeTimeTrait(youTubePlayer:YouTubePlayer)
		{
			super();
			
			_youTubePlayer = youTubePlayer;
			_setDuration();
		}

		private function _setDuration():void
		{
			try
			{
				if (isNaN(_youTubePlayer.getDuration()) == false)
				{
					const duration:Number = _youTubePlayer.getDuration();
					setDuration(duration);
					
					if (duration == 0)
					{
						setTimeout(_setDuration, 250);
					}
				}
			}
			catch (e:Error)
			{
				// getDuration() is not available yet.
				setTimeout(_setDuration, 250);
			}
		}

		
		override public function get currentTime():Number
		{
			var currentTime:Number = 0;
			try
			{
				currentTime = _youTubePlayer.getCurrentTime();
			}
			catch (e:Error)
			{
				currentTime = 0;
			}

			return currentTime;
		}
	}
}