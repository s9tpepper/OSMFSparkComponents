package ab.osmf.spark.player
{
	[SkinState("playing")]
	[SkinState("paused")]
	[SkinState("stopped")]
	
	import flash.events.MouseEvent;
	
	import mx.formatters.DateFormatter;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.traits.PlayState;
	
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
		
		private var _mediaElement:MediaElement;
		
		private var _autoPlay:Boolean = true;
		private var _isPlaying:Boolean;
		private var _isPaused:Boolean;
		private var _isStopped:Boolean = true;
		
		private var _screenWidth:Number = 640;

		public function get screenWidth():Number
		{
			return _screenWidth;
		}

		public function set screenWidth(value:Number):void
		{
			_screenWidth = value;
			_setMediaContainerDimensions();
		}

		public function get screenHeight():Number
		{
			return _screenHeight;
		}

		public function set screenHeight(value:Number):void
		{
			_screenHeight = value;
			_setMediaContainerDimensions();
		}


		private var _screenHeight:Number = 480;
		
		/**
		 * @Constructor
		 */
		public function OSMFSparkPlayer()
		{
			super();
			_init();
		}

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

		public function play():void
		{
			_mediaPlayer.play();
		}
		
		public function pause():void
		{
			_mediaPlayer.pause();
		}
		
		public function stop():void
		{
			_mediaPlayer.stop();
		}
		
		public function get isPlaying():Boolean
		{
			return _mediaPlayer.playing;
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
			
			var mediaFactory:MediaFactory = new DefaultMediaFactory();
			
			setStyle("skinClass", OSMFSparkPlayerDefaultSkin);
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
		
		private function _formatTime(seconds:Number):String
		{
			const millisecs:Number	= seconds * 1000;
			const date:Date			= new Date("1/1/2010 12:00 AM");
			date.milliseconds		= millisecs;

			const df:DateFormatter	= new DateFormatter();
			df.formatString			= "J:NN:SS";
			return df.format(date);
		}

		private function _handleCurrentTimeChange(event:TimeEvent):void
		{
			if (ui_loadableMediaScrubber)
			{
				const progress:Number = event.time / _mediaPlayer.duration;
				
				if (!isNaN(progress) && progress != Infinity)
					ui_loadableMediaScrubber.ui_rect_playbackProgress.scaleX = progress;
			}
			
			if (ui_txt_elapsedTimeDisplay)
				ui_txt_elapsedTimeDisplay.text = _formatTime(event.time);
			
			if (ui_txt_remainingTimeDisplay)
				ui_txt_remainingTimeDisplay.text = _formatTime(_mediaPlayer.duration - event.time);
			
			// Update thumb position
			if (ui_loadableMediaScrubber.ui_btn_thumb)
			{
				var position:Number = (ui_loadableMediaScrubber.ui_rect_playbackProgress.width * progress) - ui_loadableMediaScrubber.ui_btn_thumb.width;
				if (position < ui_loadableMediaScrubber.ui_btn_thumb.width)
					position = 0;
				ui_loadableMediaScrubber.ui_btn_thumb.x = position;
			}
		}

		private function _handlePlayStateChange(event:PlayEvent):void
		{
			var playerEvent:OSMFSparkPlayerEvent;
			switch (event.playState)
			{
				case (PlayState.PLAYING):
					_isPlaying = true;
					_isPaused = false;
					_isStopped = false;
					playerEvent = new OSMFSparkPlayerEvent(OSMFSparkPlayerEvent.MEDIA_PLAYING);
					break;
				
				case (PlayState.PAUSED):
					_isPlaying = false;
					_isPaused = true;
					_isStopped = false;
					playerEvent = new OSMFSparkPlayerEvent(OSMFSparkPlayerEvent.MEDIA_PAUSED);
					break;
				
				case (PlayState.STOPPED):
				default:
					_isPlaying = false;
					_isPaused = false;
					_isStopped = true;
					playerEvent = new OSMFSparkPlayerEvent(OSMFSparkPlayerEvent.MEDIA_COMPLETED_PLAYING);
					break;
			}
			
			if (playerEvent)
			{
				playerEvent.urlResource = _mediaElement.resource as URLResource;
				if (playerEvent)
					dispatchEvent(playerEvent);
			}
			
			invalidateSkinState();
		}
		
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
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case ui_mediaContainer:
					_initMediaContainer();
					break;
				
				case ui_btn_pause:
					ui_btn_pause.addEventListener(MouseEvent.CLICK, _handleClicks, false, 0, true);
					break;
				
				case ui_btn_play:
					ui_btn_play.addEventListener(MouseEvent.CLICK, _handleClicks, false, 0, true);
					break;
				
				case ui_volumeControl:
					_initVolumeControl();
					break;
				
			}
		}

		private function _initVolumeControl():void
		{
			if (ui_volumeControl)
			{
				ui_volumeControl.setVolume(_mediaPlayer.volume);
				ui_volumeControl.addEventListener(VolumeEvent.VOLUME_CHANGED, _handleVolumeChange, false, 0, true);
				ui_volumeControl.addEventListener(VolumeEvent.TOGGLE_MUTE, _handleMuteChange, false, 0, true);
			}
		}

		private function _handleMuteChange(event:VolumeEvent):void
		{
			_mediaPlayer.muted = !_mediaPlayer.muted;
		}

		private function _handleVolumeChange(event:VolumeEvent):void
		{
			_mediaPlayer.volume = event.volume;
		}

		private function _handleClicks(event:MouseEvent):void
		{
			switch (event.target)
			{
				case ui_btn_pause:
					_pauseMedia();
					break;
				
				case ui_btn_play:
					_playMedia();
					break;
			}
		}

		/**
		 * @private
		 */		
		private function _playMedia():void
		{
			if (_mediaPlayer.canPlay)
				_mediaPlayer.play();
		}


		/**
		 * @private
		 */		
		private function _pauseMedia():void
		{
			if (_mediaPlayer.canPause)
				_mediaPlayer.pause();
		}

		
		private function _initMediaContainer():void
		{
			/**TRACEDISABLE:trace("_initMediaContainer();");*/
			_setMediaContainerDimensions();
			
			if (_mediaElement && ui_mediaContainer)
			{
				_setMediaElement();
			}
		}

		private function _setMediaContainerDimensions():void
		{
			/**TRACEDISABLE:trace("_setMediaContainerDimensions();");*/
			/**TRACEDISABLE:trace("Going to set size now...")*/
			/**TRACEDISABLE:trace("_screenWidth = " + _screenWidth);*/
			/**TRACEDISABLE:trace("_screenHeight = " + _screenHeight);*/
			/**TRACEDISABLE:trace("ui_mediaContainer = " + ui_mediaContainer);*/
			if (ui_mediaContainer)
			{
//				ui_mediaContainer.width = _screenWidth;
//				ui_mediaContainer.height = _screenHeight;
				if (!isNaN(_screenHeight) && !isNaN(_screenWidth))
				{
					ui_mediaContainer.setSize(_screenWidth, _screenHeight);
				}
				
			}
		}
		
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
	}
}