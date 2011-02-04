package ab.osmf.spark.player
{
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.styles.CSSStyleDeclaration;
	
	import org.osmf.events.TimeEvent;
	
	import spark.components.Button;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.primitives.Rect;
	
	
	/**
	 * The LoadableMediaScrubber is used to display the playback
	 * progress and download progress of a media item being displayed
	 * by a media player.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */	
	public class LoadableMediaScrubber extends SkinnableComponent
	{
		
		[SkinPart(required="true")]
		/**
		 * The scrubber track, a button type so the user can
		 * click the track to scrub.
		 */
		public var ui_btn_track:Button;
		
		[SkinPart(required="true")]
		/**
		 * The scrubber download progress bar skin.
		 */
		public var ui_rect_downloadProgress:Rect;
		
		[SkinPart(required="true")]
		/**
		 * The scrubber playback position bar skin
		 */
		public var ui_rect_playbackProgress:Rect;
		
		[SkinPart(required="false")]
		/**
		 * The scrubber thumb control, used to scrub media.
		 */
		public var ui_btn_thumb:Button;
		
		/**
		 * @private
		 */		
		private var _currentProgress:Number;
		/**
		 * @private
		 */		
		private var _currentProgressEvent:TimeEvent;
		/**
		 * @private
		 */		
		private var _mediaDuration:Number;
		/**
		 * @private
		 */		
		private var _isDragging:Boolean;

		/**
		 * Dictionary of initialization functions for the skin parts, reference by skin part name string.
		 */		
		protected var skinPartInitializers:Dictionary;
		
		/**
		 * @Constructor
		 */		
		public function LoadableMediaScrubber()
		{
			super();
			_init();
		}
		
		
		/**
		 * Updates the progress display.
		 * 
		 * @param progress
		 * @param event
		 * @param duration
		 * 
		 */
		public function updateProgress(progress:Number, event:TimeEvent, duration:Number):void
		{
			_currentProgress		= progress;
			_currentProgressEvent	= event;
			_mediaDuration			= duration;
			
			_setProgressDisplay();
		}

		/**
		 * @private
		 */	
		private function _setProgressDisplay():void
		{
			_updatePlaybackProgress();
			_updateThumbPosition();
		}
		/**
		 * @private
		 */	
		private function _updatePlaybackProgress():void
		{
			if (ui_rect_playbackProgress)
			{
				if (!isNaN(_currentProgress) && _currentProgress != Infinity)
					ui_rect_playbackProgress.scaleX = _currentProgress;
			}
		}
		/**
		 * @private
		 */	
		private function _updateThumbPosition():void
		{
			if (_isDragging)
				return;
			
			if (ui_btn_thumb)
			{
				var position:Number = (ui_rect_playbackProgress.width * _currentProgress) - (ui_btn_thumb.width * .5);
		
				ui_btn_thumb.x = position;
			}
		}
		/**
		 * @private
		 */	
		private function _init():void
		{
			mapSkinPartInitializers();
			
			checkSkin("ab.osmf.spark.player.LoadableMediaScrubber", LoadableMediaScrubberDefaultSkin);
		}
		/**
		 * Checks that the component has a skin declared, if not assigns the default skin.
		 *
		 * @param selector
		 * @param defaultSkin
		 *
		 */            
		private function checkSkin(selector:String, defaultSkin:Class):void
		{
			if (styleManager.selectors.lastIndexOf(selector) == -1)
			{
				const cssDeclaration:CSSStyleDeclaration        = new CSSStyleDeclaration(selector);
				cssDeclaration.setStyle("skinClass", defaultSkin);
				styleManager.setStyleDeclaration(selector, cssDeclaration, true);
			}
		}
		/**
		 * @private
		 */	
		private function _handleThumbDown(event:MouseEvent):void
		{
			_isDragging = true;
			ui_btn_thumb.startDrag(false, new Rectangle(ui_rect_playbackProgress.x + (ui_btn_thumb.width * .5), ui_btn_thumb.y, ui_rect_downloadProgress.width, 0));
			
			_dispatchStartedScrubbing();
		}
		/**
		 * @private
		 */	
		private function _dispatchStartedScrubbing():void
		{
			var event:ScrubberEvent = new ScrubberEvent(ScrubberEvent.STARTED_SCRUBBING);
			dispatchEvent(event);
		}
		/**
		 * @private
		 */	
		private function _handleThumbUp(event:MouseEvent):void
		{
			ui_btn_thumb.stopDrag();
			
			_isDragging = false;
			
			_dispatchStoppedScrubbing();
		}
		/**
		 * @private
		 */	
		private function _dispatchStoppedScrubbing():void
		{
			var event:ScrubberEvent			= new ScrubberEvent(ScrubberEvent.SCRUBBING_STOPPED);
				event.scrubToPercentage		= _getScrubPercentage();
			dispatchEvent(event);
		}
		/**
		 * @private
		 */	
		private function _handleThumbDownMove(event:MouseEvent):void
		{
			if (_isDragging)
				_dispatchScrubbing();
		}
		/**
		 * @private
		 */	
		private function _dispatchScrubbing():void
		{
			var event:ScrubberEvent			= new ScrubberEvent(ScrubberEvent.SCRUBBING);
				event.scrubToPercentage		= _getScrubPercentage();
			dispatchEvent(event);
		}
		/**
		 * @private
		 */	
		private function _getScrubPercentage():Number
		{
			return (ui_btn_thumb.x + (ui_btn_thumb.width * .5)) / ui_btn_track.width;
		}
		/**
		 * Maps skin part names to initialization functions used in partAdded().  Subclasses
		 * should call this method to initializa default skin parts and add custom skin
		 * part initialization functions to the skinPartInitializers Dictionary.
		 * 
		 */		
		protected function mapSkinPartInitializers():void
		{
			skinPartInitializers					= new Dictionary();
			skinPartInitializers["ui_btn_thumb"]	= initThumb;
		}
		/**
		 * Initializes the ui_btn_thumb skin part on partAdded().
		 * 
		 */		
		protected function initThumb():void
		{
			if (ui_btn_thumb)
			{
				ui_btn_thumb.addEventListener(MouseEvent.MOUSE_DOWN,_handleThumbDown,false,0,true);
				ui_btn_thumb.addEventListener(MouseEvent.MOUSE_UP,_handleThumbUp,false,0,true);
				addEventListener(MouseEvent.MOUSE_MOVE,_handleThumbDownMove,false,0,true);
			}
		}
		/**
		 * Override to initialize skin parts.
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
				skinPartInitializers[partName]();
			}
			catch (e:Error)
			{
				//trace("Skin part does not have an initializer: " + partName);
			}
		}
	}
}