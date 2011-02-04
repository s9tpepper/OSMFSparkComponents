package ab.osmf.spark.player
{
	[SkinState("closed")]
	[SkinState("open")]
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import spark.components.Button;
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

		private static const _MINIMUM_VOLUME:Number = 0;

		private static const _MAXIMUM_VOLUME:Number = 1;

		public static const SLIDER_SNAP_INTERVAL:Number = .05;
		[SkinPart(required="true")]
		/**
		 * Doubles as the "speaker" icon for the volume control as well as a mute
		 * button when clicked.
		 */
		public var ui_btn_volumeIcon:Button;
		
		[SkinPart(required="true")]
		/**
		 * The volume slider component.
		 */
		public var ui_volumeSlider:SliderBase;
		
		private var _currentVolume:Number;
		protected var skinPartInitializationClosures:Dictionary;
		
		/**
		 * @Constructor
		 */
		public function VolumeControl()
		{
			super();
			_init();
		}

		public function setVolume(number:Number):void
		{
			_currentVolume = number;
			
			_setSlider();
		}

		private function _setSlider():void
		{
			if (ui_volumeSlider)
				ui_volumeSlider.value = _currentVolume;
		}


		private function _init():void
		{
			setStyle("skinClass", VolumeControlDefaultSkin);
			mapSkinPartInitializationClosures();
		}
		
		protected function mapSkinPartInitializationClosures():void
		{
			skinPartInitializationClosures							= new Dictionary();
			skinPartInitializationClosures["ui_volumeSlider"]		= initializeSlider;
			skinPartInitializationClosures["ui_btn_volumeIcon"]		= initializeVolumeIcon;
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
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

		private function _handleMuteClick(event:MouseEvent):void
		{
			const volumeEvent:VolumeEvent = new VolumeEvent(VolumeEvent.TOGGLE_MUTE);
			dispatchEvent(volumeEvent);
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

		private function _handleThumbDrag(event:TrackBaseEvent):void
		{
			const volumeEvent:VolumeEvent	= new VolumeEvent(VolumeEvent.VOLUME_CHANGED);
			volumeEvent.volume				= ui_volumeSlider.value;
			dispatchEvent(volumeEvent);
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
	}
}