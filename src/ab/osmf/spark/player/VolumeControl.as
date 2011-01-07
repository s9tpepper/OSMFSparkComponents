package ab.osmf.spark.player
{
	[SkinState("closed")]
	[SkinState("open")]
	
	import flash.events.MouseEvent;
	
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
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case ui_volumeSlider:
					_initSlider();
					_setSlider();
					break;
				
				case ui_btn_volumeIcon:
					ui_btn_volumeIcon.addEventListener(MouseEvent.CLICK, _handleMuteClick, false, 0, true);
					break;
			}
		}

		private function _handleMuteClick(event:MouseEvent):void
		{
			const volumeEvent:VolumeEvent = new VolumeEvent(VolumeEvent.TOGGLE_MUTE);
			dispatchEvent(volumeEvent);
		}

		private function _initSlider():void
		{
			ui_volumeSlider.minimum = 0;
			ui_volumeSlider.maximum = 1;
			ui_volumeSlider.snapInterval = .05;
			
			ui_volumeSlider.addEventListener(TrackBaseEvent.THUMB_DRAG, _handleThumbDrag, false, 0, true);
		}

		private function _handleThumbDrag(event:TrackBaseEvent):void
		{
			const volumeEvent:VolumeEvent = new VolumeEvent(VolumeEvent.VOLUME_CHANGED);
			volumeEvent.volume = ui_volumeSlider.value;
			dispatchEvent(volumeEvent);
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
	}
}