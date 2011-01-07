package ab.flash.youtube
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.events.VideoEvent;
	/**
	 * YouTubePlayer is a wrapper to work with the YouTube chromeless player API.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */	
	public class YouTubePlayer extends EventDispatcher
	{
		private var _player:Object;
		private var _width:Number;
		private var _height:Number;
		private var _quality:String;
		private var _videoId:String;
		private var _autoPlay:Boolean;
		
		/**
		 * Boolean flag that indicates if the YouTube player is currently
		 * playing back video.
		 */		
		private var _isPlaying:Boolean;
		
		static public const STATE_UNSTARTED:Number = -1;
		static public const STATE_ENDED:Number = 0;
		static public const STATE_PLAYING:Number = 1;
		static public const STATE_PAUSED:Number = 2;
		static public const STATE_BUFFERING:Number = 3;
		static public const STATE_VIDEO_CUED:Number = 5;
		
		
		static public const QUALITY_SMALL:String = "small";
		static public const QUALITY_MEDIUM:String = "medium";
		static public const QUALITY_LARGE:String = "large";
		static public const QUALITY_HD_720:String = "hd720";
		
		/**
		 * The amount of milliseconds that pass between playback progress updates.
		 */		
		static public var playbackUpdateInterval:Number = 250;
		
		/**
		 * Timer object that keeps track of the cycles for dispatching progress updates.
		 */
		private var _playbackProgressTimer:Timer;
		
		/**
		 * The 100 error code is broadcast when the video requested is not found. 
		 * This occurs when a video has been removed (for any reason), or it has been marked as private.
		 */
		static public const ERROR_VIDEO_REQUEST_NOT_FOUND:Number = 100;
		/**
		 * The 101 error code is broadcast when the video requested does not allow playback in the embedded players.
		 */
		static public const ERROR_VIDEO_EMBEDDING_NOT_ALLOWED:Number = 101;
		/**
		 * This error is the same as ERROR_VIDEO_EMBEDDING_NOT_ALLOWED, but YouTube will
		 * occassionally return this code instead of 101.
		 */		
		static public const ERROR_VIDEO_NOT_ALLOWED:Number = 150;
		private var _isPaused:Boolean;
		private var _currentVolume:Number;
		
		public function YouTubePlayer( player:Object, width:Number, height:Number, quality:String="hd720", videoId:String="", autoPlay:Boolean=false )
		{
			_player = player;
			_width = width;
			_height = height;
			_quality = quality;
			_videoId = videoId;
			
			_init();
		}
		

		public function get isPaused():Boolean
		{
			return _isPaused;
		}

		/**
		 * Returns a Boolean indicating if the YouTube player
		 * is currently playing back video.
		 * 
		 * @return Boolean true when video is playing.
		 * 
		 */
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}

		private function _init():void
		{
			_addEventListeners();
		}
		
		private function _addEventListeners():void
		{
			_player.addEventListener("onReady", onPlayerReady);
			_player.addEventListener("onError", onPlayerError);
			_player.addEventListener("onStateChange", onPlayerStateChange);
			_player.addEventListener("onPlaybackQualityChange", onVideoPlaybackQualityChange);
		}
		
		private function onPlayerReady(event:Event):void {
			// Event.data contains the event parameter, which is the Player API ID 
			/**TRACEDISABLE:trace("player ready:", Object(event).data);*/
			
			// Once this event has been dispatched by the player, we can use
			// cueVideoById, loadVideoById, cueVideoByUrl and loadVideoByUrl
			// to load a particular YouTube video.
			
			// Set appropriate player dimensions for your application
			_player.setSize( _width, _height );
			
			// Set volume
			if (!isNaN(_currentVolume))
				setVolume(_currentVolume);
			
			if (_videoId != "" && !_autoPlay)
			{
				_player.cueVideoById( _videoId, 0, _quality );
			}
			else if (_videoId != "" && _autoPlay)
			{
				_player.loadVideoById( _videoId, 0, _quality );
			}
		}
		
		private function onPlayerError(event:Event):void 
		{
			// Event.data contains the event parameter, which is the error code
			/**TRACEDISABLE:trace("player error:", Object(event).data);*/
			var youTubeEvent:YouTubeEvent	= new YouTubeEvent(YouTubeEvent.ERROR);
				youTubeEvent.error			= Object(event).data;
			dispatchEvent( youTubeEvent );
		}
		
		private function onPlayerStateChange(event:Event):void 
		{
			var state:Number = Object(event).data;
			
			switch (state)
			{
				case STATE_PLAYING:
					_isPlaying = true;
					
					if (!_playbackProgressTimer)
					{
						_playbackProgressTimer = new Timer( playbackUpdateInterval );
						_playbackProgressTimer.addEventListener(TimerEvent.TIMER,_handleProgressUpdate,false,0,true);
					}
					
					_playbackProgressTimer.start();
					break;
				
				default:
					_isPlaying = false;
					if (_playbackProgressTimer && _playbackProgressTimer.running)
					{
						_playbackProgressTimer.stop();
					}
					break;
			}
			
			// Event.data contains the event parameter, which is the new player state
			var youTubeEvent:YouTubeEvent	= new YouTubeEvent(YouTubeEvent.STATE_CHANGE);
				youTubeEvent.state			= state;
			dispatchEvent( youTubeEvent );
		}

		private function _handleProgressUpdate(event:TimerEvent):void
		{
			var youTubeEvent:YouTubeEvent 	= new YouTubeEvent(YouTubeEvent.PLAYBACK_PROGRESS);
				youTubeEvent.timeElapsed	= _player.getCurrentTime();
				youTubeEvent.totalTime		= getDuration();
			dispatchEvent( youTubeEvent );
		}
		
		private function onVideoPlaybackQualityChange(event:Event):void 
		{
			// Event.data contains the event parameter, which is the new video quality
			/**TRACEDISABLE:trace("video quality:", Object(event).data);*/
			var youTubeEvent:YouTubeEvent	= new YouTubeEvent(YouTubeEvent.QUALITY_CHANGE);
				youTubeEvent.quality		= Object(event).data;
			dispatchEvent( youTubeEvent );
		}
		/**
		 * Pauses the currently playing video. The final player state after this function
		 * executes will be paused (2) unless the player is in the ended (0) state when the 
		 * function is called, in which case the player state will not change.
		 * 
		 */		
		public function pauseVideo():void
		{
			_player.pauseVideo();
			
			_isPaused = true;
		}
		/**
		 * Stops and cancels loading of the current video. This function should be reserved
		 * for rare situations when you know that the user will not be watching additional 
		 * video in the player. If your intent is to pause the video, you should just call 
		 * the pauseVideo function. If you want to change the video that the player is playing, 
		 * you can call one of the queueing functions without calling stopVideo first. 
		 * 
		 * Important: Unlike the pauseVideo function, which leaves the player in the paused (2) 
		 * state, the stopVideo function could put the player into any not-playing state, including
		 * ended (0), paused (2), video cued (5) or unstarted (-1).
		 * 
		 */
		public function stopVideo():void
		{
			_player.stopVideo();
		}
		/**
		 * This function destroys the player instance. It should be called before 
		 * unloading the player SWF from your parent SWF.
		 */
		public function destroy():void
		{
			_player.destroy();
		}
		/**
		 * Returns the embed code for the currently loaded/playing video.
		 * 
		 * @return String embed code for the YouTube player.
		 * 
		 */		
		public function getVideoEmbedCode():String
		{
			return _player.getVideoEmbedCode();
		}
		/**
		 * Returns the YouTube.com URL for the currently loaded/playing video.
		 * 
		 * @return String url of the YouTube.com location for the currently loaded/playing video.
		 * 
		 */
		public function getVideoUrl():String
		{
			return _player.getVideoUrl();
		}
		/**
		 * Returns the duration in seconds of the currently playing video. Note that 
		 * getDuration() will return 0 until the video's metadata is loaded, which 
		 * normally happens just after the video starts playing.
		 * 
		 * @return Number of seconds the video lasts before ending.
		 * 
		 */
		public function getDuration():Number
		{
			return _player.getDuration();
		}
		
		/**
		 * Sets the YouTube player dimensions.
		 * 
		 * @param width
		 * @param height
		 * 
		 */
		public function setSize( width:Number, height:Number ):void
		{
			_player.setSize( width, height );
		}
		/**
		 * Plays the currently cued/loaded video. The final player state after 
		 * this function executes will be playing (1).
		 * 
		 */
		public function playVideo():void
		{
			_player.playVideo();
			
			_isPaused = false;
		}
		/**
		 * Gets the volume of the YouTube player as a value from 0 to 1.
		 * YouTube uses 0-100, but AS3 uses 0 to 1 so this method translates
		 * those values for consistency.
		 * 
		 * @return 
		 * 
		 */		
		public function getVolume():Number
		{
			var playerVolume:Number = _player.getVolume();
			return playerVolume/100;
		}
		
		public function playVideoById( videoId:String, secondsToStart:Number, quality:String ):void
		{
			_player.loadVideoById( videoId, secondsToStart, quality );
		}
		
		public function setVolume( value:Number ):void
		{
			_currentVolume = value;
			
			if (_player)
			{
				try
				{
					_player.setVolume( value*100 );
				} 
				catch(error:Error) 
				{
				}
			}
		}
		
		public function seekTo(seconds:Number, allowSeekAhead:Boolean):void
		{
			_player.seekTo(seconds, allowSeekAhead);
		}
		
		public function getCurrentTime():Number
		{
			return _player.getCurrentTime();
		}
	}
}