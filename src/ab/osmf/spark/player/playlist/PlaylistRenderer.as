package ab.osmf.spark.player.playlist
{
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import flash.utils.Dictionary;
	
	import mx.controls.Image;
	import mx.events.FlexEvent;
	import mx.utils.ObjectUtil;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.URLResource;
	
	import spark.components.supportClasses.ItemRenderer;
	import spark.components.supportClasses.TextBase;
	
	/**
	 * PlaylistRenderer is the default item renderer object used with the
	 * OSMFPlaylist.  You can create your own item renderer by making sure
	 * you implement IDataRenderer, IItemRenderer and IPlaylistRenderer.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class PlaylistRenderer extends SkinnableItemRenderer implements IPlaylistRenderer
	{
		[SkinPart(required="false")]
		/**
		 * The skin part used to display the title.
		 */		
		public var ui_txt_title:TextBase;
		
		[SkinPart(required="false")]
		/**
		 * The skin part used to display the description.
		 */		
		public var ui_txt_description:TextBase;
		
		[SkinPart(required="false")]
		/**
		 * The skin part used to display the thumbnail image.
		 */		
		public var ui_img_thumbnail:Image;
		
		/**
		 * The MediaElement instance used to display this playlist item in 
		 * the OSMFSparkPlayer component.
		 */		
		protected var mediaElement:MediaElement;
		
		// Item renderer field properties
		/**
		 * @private
		 */
		private var _urlField:String				= "url";
		/**
		 * @private
		 */
		private var _titleField:String				= "title";
		/**
		 * @private
		 */
		private var _descriptionField:String		= "description";
		/**
		 * @private
		 */
		private var _thumbnailField:String			= "thumbnail";
		/**
		 * Used to prevent the DATA_CHANGE event to slow down the list as this
		 * event is dispatched sporadically instead of _only_ when the actual
		 * data is changed. 
		 */		
		private var _lastSetData:Object;
		
		/**
		 * Dictionary of skin part initialization functions with skin part names as keys.
		 */		
		protected var skinPartInitializationClosures:Dictionary;
		
		/**
		 * The urlField setter defines which field on the data objects
		 * to use to retrieve the media URL for loading.
		 * 
		 * @param value
		 * 
		 */		
		public function set urlField(value:String):void
		{
			_urlField = value;
			updateMediaElement();
		}
		/**
		 * The titleField setter defines which field on the data objects
		 * to use to retrieve the media title for display.
		 * 
		 * @param value
		 * 
		 */		
		public function set titleField(value:String):void
		{
			_titleField = value;
			setTitle();
		}
		/**
		 * The descriptionField setter defines which field on the data objects
		 * to use to retrieve the media description for display.
		 * 
		 * @param value
		 * 
		 */	
		public function set descriptionField(value:String):void
		{
			_descriptionField = value;
			setDescription();
		}
		/**
		 * The thumbnailField setter defines which field on the data objects
		 * to use to retrieve the media thumbnail for display.
		 * 
		 * @param value
		 * 
		 */	
		public function set thumbnailField(value:String):void
		{
			_thumbnailField = value;
			setThumbnail();
		}
		
		/**
		 * @Constructor
		 */		
		public function PlaylistRenderer()
		{
			super();
			_init();
		}
		/**
		 * @private
		 */
		private function _init():void
		{
			setStyle("skinClass", PlaylistRendererDefaultSkin);
			
			addEventListener(FlexEvent.DATA_CHANGE, _handleDataChange,false,0,true);
			addEventListener(FlexEvent.CREATION_COMPLETE, _handleCreationComplete,false,0,true);
			
			mapSkinPartInitializationClosures();
		}
		/**
		 * @private
		 */
		private function _handleCreationComplete(event:FlexEvent):void
		{
			_setDisplay();
		}
		/**
		 * @private
		 */
		private function _handleDataChange(event:FlexEvent):void
		{
			_setDisplay();
		}
		/**
		 * @private
		 */
		private function _setDisplay():void
		{
			if (data && data !== _lastSetData)
			{
				_lastSetData = data;
				refreshUI();
			}
		}
		/**
		 * Initializes the media element from the data object.
		 * 
		 */
		protected function updateMediaElement():void
		{
			const url:String = data[ _urlField ];
			
			if (url && url.length)
				mediaElement = OSMFPlaylist.mediaFactory.createMediaElement(new URLResource(url));
		}
		/**
		 * Initializes the title text skin part component.
		 * 
		 */
		protected function setTitle():void
		{
			if (ui_txt_title)
			{
				try
				{
					ui_txt_title.text = data[ _titleField ];
				}
				catch (e:Error)
				{
					// field or skin part does not exist in data object, can not set display.
				}
			}
		}
		/**
		 * Initializes the description text skin part component.
		 * 
		 */
		protected function setDescription():void
		{
			if (ui_txt_description)
			{
				try
				{
					ui_txt_description.text = data[ _descriptionField ];
				}
				catch (e:Error)
				{
					// field or skin part does not exist in data object, can not set display.
				}
			}
		}
		/**
		 * Initializes the thumbnail skin part component.
		 * 
		 */		
		protected function setThumbnail():void
		{
			if (ui_img_thumbnail)
			{
				try
				{
					ui_img_thumbnail.source = data[ _thumbnailField ];
				}
				catch (e:Error)
				{
					// field or skin part does not exist in data object, can not set display.
				}
			}
		}
		/**
		 * Maps the skin parts by name to their initialization closures.  When overriding to
		 * add custom skin parts call this method to initialize the built in skin parts and
		 * add initialization closures for custom skin parts to skinPartInitializationClosures
		 * Dictionary property.
		 * 
		 */		
		protected function mapSkinPartInitializationClosures():void
		{
			skinPartInitializationClosures								= new Dictionary();
			skinPartInitializationClosures["ui_img_thumbnail"]			= setThumbnail;
			skinPartInitializationClosures["ui_txt_description"]		= setDescription;
			skinPartInitializationClosures["ui_txt_title"]				= setTitle;
		}
		/**
		 * Refreshes the data in the UI by calling the methods 
		 * that update the UI components.  This method should be called
		 * when subclassing PlaylistRenderer to update the built-in fields
		 * and add the updates for the custom UI components.
		 * 
		 */		
		protected function refreshUI():void
		{
			updateMediaElement();
			setDescription();
			setThumbnail();
			setTitle();
		}
		/**
		 * Override of partAdded() to initialize skin parts.
		 * 
		 * @param partName
		 * @param instance
		 * 
		 */		
		override protected function partAdded(partName:String, instance:Object):void
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