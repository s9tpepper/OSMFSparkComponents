package ab.osmf.spark.player
{
	[SkinState("playing")]
	[SkinState("paused")]
	[SkinState("stopped")]
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.formatters.DateFormatter;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.TimeTrait;
	
	import spark.components.Button;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.TextBase;
	
	
	/**
	 * OSMFSparkPlayer is a Spark component that wraps the OSMF
	 * framework in a Spark style component API to easily skin an
	 * OSMF based media player.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class OSMFSparkPlayer extends SkinnableComponent
	{
		[SkinPart(required="false")]
		/**
		 * The button used to display the play button.
		 */
		public var ui_btn_play:Button;
		
		[SkinPart(required="false")]
		/**
		 * The button used to display the pause button.
		 */		
		public var ui_btn_pause:Button;
		
		[SkinPart(required="false")]
		/**
		 * The amount of time left in the currently playing media.
		 */
		public var ui_txt_remainingTimeDisplay:TextBase;

		[SkinPart(required="false")]
		/**
		 * The amount of time left in the currently playing media.
		 */
		public var ui_txt_elapsedTimeDisplay:TextBase;
		
		[SkinPart(required="false")]
		/**
		 * The volume control component to change the media's volume.
		 */
		public var ui_volumeControl:VolumeControl;
		
		[SkinPart(required="false")]
		/**
		 * The scrubber component for the media being displayed. 
		 */
		public var ui_loadableMediaScrubber:LoadableMediaScrubber;
		
		[SkinPart(required="false")]
		/**
		 * Skin part that houses the OSMF MediaContainer for the MediaPlayer.
		 */
		public var ui_mediaContainer:SparkMediaContainer;
		
		
		/**
		 * @private
		 */		
		private var _mediaPlayer:MediaPlayer;
		/**
		 * @private
		 */		
		private var _playOnStopScrubbing:Boolean = false;
		/**
		 * @private
		 */		
		private var _mediaElement:MediaElement;
		/**
		 * @private
		 */		
		private var _autoPlay:Boolean = true;
		/**
		 * @private
		 */		
		private var _isPlaying:Boolean;
		/**
		 * @private
		 */		
		private var _isPaused:Boolean;
		/**
		 * @private
		 */		
		private var _isStopped:Boolean = true;
		/**
		 * @private
		 */		
		private var _screenWidth:Number = 640;
		/**
		 * @private
		 */		
		private var _screenHeight:Number = 480;
		/**
		 * @private
		 */		
		private var _timeDisplayFormat:String = "J:NN:SS";
		
		/**
		 * Initialization function map for skin parts.
		 */		
		protected var skinPartInitializationClosures:Dictionary;
		/**
		 * Play state change function map for play state changes.
		 */
		protected var playStateChangeClosures:Dictionary;
		
		

		/**
		 * The display format to use for the time remaining/elapsed.  This string
		 * is documented in the Flex DateFormatter ASDoc with the supported
		 * time tokens.
		 * 
		 * @return 
		 * 
		 */
		public function get timeDisplayFormat():String
		{
			return _timeDisplayFormat;
		}
		public function set timeDisplayFormat(value:String):void
		{
			_timeDisplayFormat = value;
		}

		/**
		 * The width of the video screen, must be set to display media correctly.
		 * 
		 * @return 
		 * 
		 */		
		public function get screenWidth():Number
		{
			return _screenWidth;
		}
		public function set screenWidth(value:Number):void
		{
			_screenWidth = value;
			_setMediaContainerDimensions();
		}

		/**
		 * The height of the video screen, must be set to display media correctly.
		 * 
		 * @return 
		 * 
		 */	
		public function get screenHeight():Number
		{
			return _screenHeight;
		}
		public function set screenHeight(value:Number):void
		{
			_screenHeight = value;
			_setMediaContainerDimensions();
		}
		
		/**
		 * The MediaElement currently being played by the OSMFSparkPlayer.
		 * 
		 * @return 
		 * 
		 */		
		public function get mediaElement():MediaElement
		{
			return _mediaElement;
		}
		public function set mediaElement(value:MediaElement):void
		{
			if (_mediaElement && ui_mediaContainer)
			{
				ui_mediaContainer.removeMediaElement(_mediaElement);
			}
			
			_mediaElement = value;
			
			_setMediaElement();
		}
		
		/**
		 * Whether the media player auto plays when the media is set.
		 * 
		 * @return 
		 * 
		 */
		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}
		public function set autoPlay(value:Boolean):void
		{
			_autoPlay = value;
			if (_mediaPlayer)
				_mediaPlayer.autoPlay = _autoPlay;
		}
		/**
		 * Whether the media player is currently playing or not.
		 * 
		 * @return 
		 * 
		 */		
		public function get isPlaying():Boolean
		{
			return _mediaPlayer.playing;
		}

		/**
		 * @Constructor
		 */
		public function OSMFSparkPlayer()
		{
			super();
			_init();
		}
		
		/**
		 * Plays the media if playable.
		 * 
		 */		
		public function play():void
		{
			if (_mediaPlayer.canPlay)
				_mediaPlayer.play();
		}
		/**
		 * Pauses media if pausable.
		 * 
		 */		
		public function pause():void
		{
			if (_mediaPlayer.canPause)
				_mediaPlayer.pause();
		}
		/**
		 * Stops the media from playing if playing or paused.
		 * 
		 */		
		public function stop():void
		{
			if (_mediaPlayer.playing || _mediaPlayer.paused)
				_mediaPlayer.stop();
		}

		
		/**
		 * Sets the media element to the container and the media player.
		 */		
		private function _setMediaElement():void
		{
			if (ui_mediaContainer)
			{
				ui_mediaContainer.addMedia(_mediaElement);
				_mediaPlayer.media = _mediaElement;
			}
		}

		/**
		 * Initializes the player.
		 * 
		 */
		private function _init():void
		{
			_mediaPlayer			= new MediaPlayer();
			_mediaPlayer.autoPlay	= true;
			
			_attachListeners(_mediaPlayer);
			
			setStyle("skinClass", OSMFSparkPlayerDefaultSkin);
			
			mapPartInitializers();
			mapPlayStateChangeClosures();
		}
		/**
		 * @private 
		 */
		private function _seekToTime(time:Number):void
		{
			if (_mediaPlayer.canSeek && _mediaPlayer.canSeekTo(time))
			{
				_mediaPlayer.seek(time);
			}
		}
		/**
		 * @private 
		 */
		private function _handleScrubbing(event:ScrubberEvent):void
		{
			_scrubVideo(event);
		}
		/**
		 * @private 
		 */
		private function _scrubVideo(event:ScrubberEvent):void
		{
			const timeTrait:TimeTrait	= _mediaElement.getTrait(MediaTraitType.TIME) as TimeTrait;
			
			if (timeTrait)
			{
				const seekTime:Number		= event.scrubToPercentage * timeTrait.duration;
				_seekToTime(seekTime);
			}
		}
		/**
		 * @private 
		 */
		private function _handleStoppedScrubbing(event:ScrubberEvent):void
		{
			_scrubVideo(event);
			
			if (_playOnStopScrubbing)
			{
				_playOnStopScrubbing = false;
				play();
			}
		}
		/**
		 * @private 
		 */
		private function _handleStartedScrubbing(event:ScrubberEvent):void
		{
			if (isPlaying)
			{
				_playOnStopScrubbing = true;
				pause();
			}
		}
		/**
		 * Attaches event listeners.
		 * 
		 * @param mediaPlayer
		 * 
		 */		
		private function _attachListeners(mediaPlayer:MediaPlayer):void
		{
			mediaPlayer.addEventListener(PlayEvent.PLAY_STATE_CHANGE, _handlePlayStateChange);
			mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, _handleCurrentTimeChange);
		}
		/**
		 * @private 
		 */
		private function _formatTime(seconds:Number):String
		{
			const millisecs:Number	= seconds * 1000;
			const date:Date			= new Date("1/1/2010 12:00 AM");
			date.milliseconds		= millisecs;

			const df:DateFormatter	= new DateFormatter();
			df.formatString			= _timeDisplayFormat;
			return df.format(date);
		}
		/**
		 * @private 
		 */
		private function _handleCurrentTimeChange(event:TimeEvent):void
		{
			if (!ui_loadableMediaScrubber)
				return;
			
			const progress:Number = event.time / _mediaPlayer.duration;
			
			if (ui_txt_elapsedTimeDisplay)
				ui_txt_elapsedTimeDisplay.text = _formatTime(event.time);
			
			if (ui_txt_remainingTimeDisplay)
				ui_txt_remainingTimeDisplay.text = _formatTime(_mediaPlayer.duration - event.time);
			
			ui_loadableMediaScrubber.updateProgress(progress, event, _mediaPlayer.duration);
		}
		/**
		 * @private 
		 */
		private function _handlePlayStateChange(event:PlayEvent):void
		{
			const stateClosure:Function = playStateChangeClosures[event.playState];
			
			if (stateClosure is Function)
			{
				const playerEvent:OSMFSparkPlayerEvent = stateClosure();
				
				if (playerEvent)
				{
					playerEvent.urlResource = _mediaElement.resource as URLResource;

					dispatchEvent(playerEvent);

					invalidateSkinState();
				}
			}
		}
		/**
		 * @private 
		 */
		private function _onStoppedState():OSMFSparkPlayerEvent
		{
			_isPlaying = false;
			_isPaused = false;
			
			if (!_isStopped)
			{
				_isStopped = true;
				return new OSMFSparkPlayerEvent(OSMFSparkPlayerEvent.MEDIA_COMPLETED_PLAYING);
			}
			
			return null;
		}
		/**
		 * @private 
		 */
		private function _onPausedState():OSMFSparkPlayerEvent
		{
			_isPlaying = false;
			_isPaused = true;
			_isStopped = false;
			
			return new OSMFSparkPlayerEvent(OSMFSparkPlayerEvent.MEDIA_PAUSED);
		}
		/**
		 * @private 
		 */		
		private function _onPlayingState():OSMFSparkPlayerEvent
		{
			_isPlaying = true;
			_isPaused = false;
			_isStopped = false;
			
			return new OSMFSparkPlayerEvent(OSMFSparkPlayerEvent.MEDIA_PLAYING);
		}
		/**
		 * @private
		 * 
		 * @param event
		 * 
		 */
		private function _handleMuteChange(event:VolumeEvent):void
		{
			_mediaPlayer.muted = !_mediaPlayer.muted;
		}
		/**
		 * @private
		 * @param event
		 * 
		 */		
		private function _handleVolumeChange(event:VolumeEvent):void
		{
			_mediaPlayer.volume = event.volume;
		}
		/**
		 * @private
		 */		
		private function _playMedia(event:MouseEvent):void
		{
			if (_mediaPlayer.canPlay)
				_mediaPlayer.play();
		}
		/**
		 * @private
		 */		
		private function _pauseMedia(event:MouseEvent):void
		{
			if (_mediaPlayer.canPause)
				_mediaPlayer.pause();
		}
		/**
		 * Used to update the dimensions of the media container skin part.
		 * 
		 */		
		private function _setMediaContainerDimensions():void
		{
			if (ui_mediaContainer)
			{
				if (!isNaN(_screenHeight) && !isNaN(_screenWidth))
				{
					ui_mediaContainer.setSize(_screenWidth, _screenHeight);
				}
			}
		}
		
		
		/**
		 * Initializes the media container when the skin part is added.
		 * 
		 */		
		protected function initMediaContainer():void
		{
			_setMediaContainerDimensions();
			
			if (_mediaElement && ui_mediaContainer)
			{
				_setMediaElement();
			}
		}
		/**
		 * Maps the state change functions to the state strings for lookup.
		 * 
		 */		
		protected function mapPlayStateChangeClosures():void
		{
			playStateChangeClosures								= new Dictionary();
			playStateChangeClosures[PlayState.PLAYING]			= _onPlayingState;
			playStateChangeClosures[PlayState.PAUSED]			= _onPausedState;
			playStateChangeClosures[PlayState.STOPPED]			= _onStoppedState;
		}
		/**
		 * A Function map used in the partAdded override to initialize the
		 * different skin parts with event handlers, etc.
		 * 
		 */		
		protected function mapPartInitializers():void
		{
			skinPartInitializationClosures									= new Dictionary();
			skinPartInitializationClosures["ui_mediaContainer"]				= initMediaContainer;
			skinPartInitializationClosures["ui_btn_pause"]					= initPauseButton;
			skinPartInitializationClosures["ui_btn_play"]					= initPlayButton;
			skinPartInitializationClosures["ui_volumeControl"]				= initVolumeControl;
			skinPartInitializationClosures["ui_txt_remainingTimeDisplay"]	= initTimeRemainingDisplay;
			skinPartInitializationClosures["ui_txt_elapsedTimeDisplay"]		= initTimeElapsedDisplay;
			skinPartInitializationClosures["ui_loadableMediaScrubber"]		= initLoadableMediaScrubber;
		}
		/**
		 * Initializes the loadable media scrubber skin part.
		 * 
		 */		
		protected function initLoadableMediaScrubber():void
		{
			if (ui_loadableMediaScrubber)
			{
				ui_loadableMediaScrubber.addEventListener(ScrubberEvent.SCRUBBING, _handleScrubbing, false, 0, true);
				ui_loadableMediaScrubber.addEventListener(ScrubberEvent.SCRUBBING_STOPPED, _handleStoppedScrubbing, false, 0, true);
				ui_loadableMediaScrubber.addEventListener(ScrubberEvent.STARTED_SCRUBBING, _handleStartedScrubbing, false, 0, true);
			}
		}
		/**
		 * Initializes the _initPlayButton skin part when added.
		 * 
		 */
		protected function initPlayButton():void
		{
			ui_btn_play.addEventListener(MouseEvent.CLICK, _playMedia, false, 0, true);
		}
		/**
		 * Initializes the _initPauseButton skin part when added.
		 * 
		 */
		protected function initPauseButton():void
		{
			ui_btn_pause.addEventListener(MouseEvent.CLICK, _pauseMedia, false, 0, true);
		}
		/**
		 * Initializes the volumeControl skin part when added.
		 * 
		 */
		protected function initVolumeControl():void
		{
			if (ui_volumeControl)
			{
				ui_volumeControl.setVolume(_mediaPlayer.volume);
				ui_volumeControl.addEventListener(VolumeEvent.VOLUME_CHANGED, _handleVolumeChange, false, 0, true);
				ui_volumeControl.addEventListener(VolumeEvent.TOGGLE_MUTE, _handleMuteChange, false, 0, true);
			}
		}
		/**
		 * Initializes the time elapsed text skin part.
		 * 
		 */		
		protected function initTimeElapsedDisplay():void
		{
			if (ui_txt_elapsedTimeDisplay)
				ui_txt_elapsedTimeDisplay.text = "";
		}
		/**
		 * Initializes the time remaining text skin part.
		 * 
		 */		
		protected function initTimeRemainingDisplay():void
		{
			if (ui_txt_remainingTimeDisplay)
				ui_txt_remainingTimeDisplay.text = "";
		}
		
		/**
		 * Override to implement custom states.
		 * 
		 * @return 
		 * 
		 */		
		override protected function getCurrentSkinState():String
		{
			if (_isPlaying)
				return "playing";
			
			if (_isPaused)
				return "paused";
			
			if (_isStopped)
				return "stopped";
			
			return super.getCurrentSkinState();
		} 
		/**
		 * Override partAdded to initialize the skin parts.
		 * 
		 * @param partName
		 * @param instance
		 * 
		 */		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			try
			{
				skinPartInitializationClosures[partName]();
			}
			catch (e:Error)
			{
				//trace("Part does not have an initialization closure: " + partName);
			}
		}
	}
}