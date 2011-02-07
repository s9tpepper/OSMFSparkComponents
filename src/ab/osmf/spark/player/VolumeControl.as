package ab.osmf.spark.player
{
	[SkinState("closed")]
	[SkinState("open")]
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.Button;
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.SliderBase;
	import spark.events.TrackBaseEvent;
	
	
	/**
	 * VolumeControl is a Spark component used in OSMFSparkPlayer to
	 * provide volume controls.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class VolumeControl extends SkinnableComponent
	{
		/**
		 * @private
		 */
		private static const _MINIMUM_VOLUME:Number = 0;
		/**
		 * @private
		 */
		private static const _MAXIMUM_VOLUME:Number = 1;

		public static const SLIDER_SNAP_INTERVAL:Number = .05;
		[SkinPart(required="true")]
		/**
		 * Doubles as the "speaker" icon for the volume control as well as a mute
		 * button when clicked.
		 */
		public var ui_btn_volumeIcon:ButtonBase;
		
		[SkinPart(required="true")]
		/**
		 * The volume slider component.
		 */
		public var ui_volumeSlider:SliderBase;
		
		/**
		 * @private
		 */		
		private var _currentVolume:Number;
		
		/**
		 * Dictionary mapping skin part names to initialization functions for partAdded().
		 */		
		protected var skinPartInitializationClosures:Dictionary;

		private var _autoHideVolumeSlider:Boolean = false;
		private var _rolledOutStateChangeDelay:Timer;
		private var _currentSkinState:String = "open";
		
		/**
		 * @Constructor
		 */
		public function VolumeControl()
		{
			super();
			_init();
		}
		/**
		 * @private
		 */
		public function setVolume(number:Number):void
		{
			_currentVolume = number;
			
			_setSlider();
		}

		public function get autoHideVolumeSlider():Boolean
		{
			return _autoHideVolumeSlider;
		}

		public function set autoHideVolumeSlider(value:Boolean):void
		{
			_autoHideVolumeSlider = value;
			
			_updateAutoHideHandling();
		}
		
		private function _updateAutoHideHandling():void
		{
			if (_autoHideVolumeSlider)
				_enableAutoHideVolumeSliderStates();
			else
				_disableAutoHideVolumeSliderStates();
		}
		
		private function _disableAutoHideVolumeSliderStates():void
		{
			_removeAutoHideHandlers();
			_switchToOpenState();
		}

		private function _switchToOpenState():void
		{
			_currentSkinState = "open";
			invalidateSkinState();
		}


		private function _removeAutoHideHandlers():void
		{
			if (hasEventListener(MouseEvent.ROLL_OVER))
				removeEventListener(MouseEvent.ROLL_OVER,_handleVolumeControlsRollOver);
		
			if (hasEventListener(MouseEvent.ROLL_OUT))
				removeEventListener(MouseEvent.ROLL_OUT, _handleVolumeControlsRollOut);
		}

		
		private function _enableAutoHideVolumeSliderStates():void
		{
			if (!hasEventListener(MouseEvent.ROLL_OVER))
			{
				addEventListener(MouseEvent.ROLL_OVER,_handleVolumeControlsRollOver,false,0,true);
				addEventListener(MouseEvent.ROLL_OUT, _handleVolumeControlsRollOut,false,0,true);
			}
			
			_switchToClosedState();
		}
		
		private function _handleVolumeControlsRollOver(event:MouseEvent):void
		{
			if (_rolledOutStateChangeDelay != null)
			{
				_rolledOutStateChangeDelay.reset();
			}
			
			_switchToOpenState();
		}
		
		private function _handleVolumeControlsRollOut(event:MouseEvent):void
		{
			if (!_rolledOutStateChangeDelay)
			{
				_rolledOutStateChangeDelay = new Timer(1500);
				_rolledOutStateChangeDelay.addEventListener(TimerEvent.TIMER, _switchToClosedState, false, 0, true);
			}
			
			_rolledOutStateChangeDelay.start();
		}

		private function _switchToClosedState(event:TimerEvent=null):void
		{
			_currentSkinState = "closed";
			invalidateSkinState();
		}
		
		
		
		/**
		 * @private
		 */
		private function _setSlider():void
		{
			if (ui_volumeSlider)
				ui_volumeSlider.value = _currentVolume;
		}
		/**
		 * @private
		 */
		private function _init():void
		{
			checkSkin("ab.osmf.spark.player.VolumeControl", VolumeControlDefaultSkin);
			mapSkinPartInitializationClosures();
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
		private function _handleMuteClick(event:MouseEvent):void
		{
			const volumeEvent:VolumeEvent = new VolumeEvent(VolumeEvent.TOGGLE_MUTE);
			dispatchEvent(volumeEvent);
		}
		/**
		 * @private
		 */		
		private function _handleThumbDrag(event:TrackBaseEvent):void
		{
			const volumeEvent:VolumeEvent	= new VolumeEvent(VolumeEvent.VOLUME_CHANGED);
			volumeEvent.volume				= ui_volumeSlider.value;
			dispatchEvent(volumeEvent);
		}
		/**
		 * Maps the skin part names to initialization functions.
		 * 
		 */		
		protected function mapSkinPartInitializationClosures():void
		{
			skinPartInitializationClosures							= new Dictionary();
			skinPartInitializationClosures["ui_volumeSlider"]		= initializeSlider;
			skinPartInitializationClosures["ui_btn_volumeIcon"]		= initializeVolumeIcon;
		}
		/**
		 * Initializes the volume icon/button.
		 * 
		 */		
		protected function initializeVolumeIcon():void
		{
			ui_btn_volumeIcon.addEventListener(MouseEvent.CLICK, _handleMuteClick, false, 0, true);
		}
		/**
		 * Initializes the volume slider component.
		 * 
		 */		
		protected function initializeSlider():void
		{
			ui_volumeSlider.minimum			= _MINIMUM_VOLUME;
			ui_volumeSlider.maximum			= _MAXIMUM_VOLUME;
			ui_volumeSlider.snapInterval	= SLIDER_SNAP_INTERVAL;
			
			ui_volumeSlider.addEventListener(TrackBaseEvent.THUMB_DRAG, _handleThumbDrag, false, 0, true);
			
			_setSlider();
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
				skinPartInitializationClosures[partName]();
			}
			catch (e:Error)
			{
				//trace("Skin part does not have an initialization closure: " + partName);
			}
		}
		
		protected override function getCurrentSkinState():String
		{
			return _currentSkinState;
		}
	}
}