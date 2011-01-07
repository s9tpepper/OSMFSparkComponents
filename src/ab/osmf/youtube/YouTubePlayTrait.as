package ab.osmf.youtube
{
	import ab.flash.youtube.YouTubeEvent;
	import ab.flash.youtube.YouTubePlayer;
	
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	/**
	 * YouTubePlayTrait adds play/pause capabilities to the YouTubeElement.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */	
	public class YouTubePlayTrait extends PlayTrait
	{
		private var _youTubePlayer:YouTubePlayer;
		private var _youTubeResource:YouTubeResource;
		private var _videoId:String;

		/**
		 * @Constructor
		 * 
		 * @param youTubePlayer
		 * @param youTubeResource
		 * 
		 */
		public function YouTubePlayTrait(youTubePlayer:YouTubePlayer, youTubeResource:YouTubeResource)
		{
			_youTubePlayer		= youTubePlayer;
			_youTubeResource	= youTubeResource;
			
			_youTubePlayer.addEventListener(YouTubeEvent.STATE_CHANGE, _handleVideoEnded, false, 0, true);
			
			super();
		}

		private function _handleVideoEnded(event:YouTubeEvent):void
		{
			if (event.state == YouTubePlayer.STATE_ENDED)
				stop();
		}
		
		/**
		 * Override to handle play state changes.
		 * 
		 * @param newPlayState
		 * 
		 */
		override protected function playStateChangeStart(newPlayState:String):void
		{
			if (newPlayState == PlayState.PLAYING)
			{
				if (_youTubePlayer.isPaused)
				{
					_youTubePlayer.playVideo();
				}
				else
				{
					const regExp:RegExp = /(v=)([A-Za-z0-9\-_]+)/g;
					const matches:Array = regExp.exec(_youTubeResource.youTubeAPIVideoURL);
					
					if (matches && matches.length == 3)
					{
						_videoId = matches[2];
						setTimeout(_startVideo, 250);
					}
				}
			}
			else
			{
				_youTubePlayer.pauseVideo();
			}
		}
		/**
		 * @private
		 */		
		private function _startVideo():void
		{
			try
			{
				_youTubePlayer.playVideoById(_videoId, 0, _youTubeResource.quality);
			}
			catch (e:Error)
			{
				setTimeout(_startVideo, 250);
			}
		}
		
	}
}