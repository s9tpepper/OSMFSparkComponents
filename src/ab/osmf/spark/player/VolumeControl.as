package ab.osmf.spark.player
{
	[SkinState("closed")]
	[SkinState("open")]
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.styles.CSSStyleDeclaration;
	
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
		public var ui_btn_volumeIcon:Button;
		
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
	}
}