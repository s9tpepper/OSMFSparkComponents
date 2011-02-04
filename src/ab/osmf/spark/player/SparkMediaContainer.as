package ab.osmf.spark.player
{
	
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	
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
		
		
		/**
		 * @private
		 */
		private var _sprite:SpriteVisualElement;
		/**
		 * @private
		 */
		private var _mediaContainer:MediaContainer;
		/**
		 * @private
		 */
		private var _screenWidth:Number;
		/**
		 * @private
		 */
		private var _screenHeight:Number;
		
		/**
		 * Dictionary of initialization functions for skin parts.
		 */		
		protected var skinPartInitializationClosures:Dictionary;
		
		/**
		 * @Constructor
		 */		
		public function SparkMediaContainer()
		{
			super();
			_init();
		}
		
		/**
		 * Initializes the SparkMediaContainer component.
		 * 
		 */
		private function _init():void
		{
			checkSkin("ab.osmf.spark.player.SparkMediaContainer", SparkMediaContainerDefaultSkin);
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
		 * Maps the initialization functions to skin part names for use in partAdded.
		 * 
		 */
		protected function mapSkinPartInitializationClosures():void
		{
			skinPartInitializationClosures									= new Dictionary();
			skinPartInitializationClosures["ui_mediaPlayerContainer"]		= initializeMediaPlayerContainer;
		}
		
		/**
		 * @private 
		 */		
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
		/**
		 * Removes a MediaElement from the MediaContainer.
		 * 
		 * @param mediaElement
		 * 
		 */		
		public function removeMediaElement(mediaElement:MediaElement):void
		{
			mediaContainer.removeMediaElement(mediaElement);
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
			catch(error:Error) 
			{
				//trace("Skin part does not have an initialization closure: " + partName);
			}
		}
		/**
		 * Initializes the media player container skin part.
		 * 
		 */		
		protected function initializeMediaPlayerContainer():void
		{
			_sprite					= new SpriteVisualElement();
			_mediaContainer			= new MediaContainer();
			_sprite.addChild(_mediaContainer);
			ui_mediaPlayerContainer.addElement(_sprite);
			setSize(_screenWidth, _screenHeight);
		}
		/**
		 * Sets the correct size to the media container and its Flex 4 parent holder container.
		 * 
		 * @param screenWidth
		 * @param screenHeight
		 * 
		 */		
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