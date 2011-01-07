package ab.osmf.spark.player
{
	
	import mx.core.UIComponent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.media.MediaElement;
	
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.core.SpriteVisualElement;
	
	
	/**
	 * SparkMediaContainer is a Spark component used in OSMFSparkPlayer
	 * to hold the OSMF MediaContainer instance on the Flex display list 
	 * while providing a means to skin the area in which the media is displayed.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class SparkMediaContainer extends SkinnableComponent
	{
		[SkinPart(required="true")]
		/** 
		 * Holds the OSMF MediaPlayer.
		 */
		public var ui_mediaPlayerContainer:SkinnableContainer;
		
		private var _sprite:SpriteVisualElement;
		private var _mediaContainer:MediaContainer;
		private var _screenWidth:Number;
		private var _screenHeight:Number;
		
		public function SparkMediaContainer()
		{
			super();
			_init();
		}

		private function _init():void
		{
			setStyle("skinClass", SparkMediaContainerDefaultSkin);
		}
		
		protected function get mediaContainer():MediaContainer
		{
			return _mediaContainer;
		}

		/**
		 * Adds a MediaElement to the MediaContainer.
		 * 
		 * @param mediaElement
		 */
		public function addMedia(mediaElement:MediaElement):void
		{
			mediaContainer.addMediaElement(mediaElement);
			
			/**TRACEDISABLE:trace("SparkMediaContainer :: addMedia()");*/
		}
		
		public function removeMediaElement(mediaElement:MediaElement):void
		{
			mediaContainer.removeMediaElement(mediaElement);
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
				case ui_mediaPlayerContainer:
					_sprite = new SpriteVisualElement();
					_mediaContainer = new MediaContainer();
					_sprite.addChild(_mediaContainer);
					ui_mediaPlayerContainer.addElement(_sprite);
					
					
					/**TRACEDISABLE:trace("***width = " + _screenWidth);*/
					/**TRACEDISABLE:trace("***height = " + _screenHeight);*/
					setSize(_screenWidth, _screenHeight);
//					_sprite.width = width;
//					_sprite.height = height;
//					_mediaContainer.width = width;
//					_mediaContainer.height = height;
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
		}

		public function setSize(screenWidth:Number, screenHeight:Number):void
		{
			_screenWidth = screenWidth;
			_screenHeight = screenHeight;
			
			if (_sprite)
				_sprite.width = _screenWidth;
			
			if (_mediaContainer)
				_mediaContainer.width = _screenWidth;
			
			if (_sprite)
				_sprite.height = _screenHeight;
			
			if (_mediaContainer)
				_mediaContainer.height = _screenHeight;
		}
		
	}
}