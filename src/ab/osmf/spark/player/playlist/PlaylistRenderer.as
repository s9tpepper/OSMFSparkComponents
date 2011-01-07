package ab.osmf.spark.player.playlist
{
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import mx.controls.Image;
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
		[SkinPart(required="true")]
		/**
		 * The skin part used to display the title.
		 */		
		public var ui_txt_title:TextBase;
		
		
		[SkinPart(required="true")]
		/**
		 * The skin part used to display the description.
		 */		
		public var ui_txt_description:TextBase;
		
		[SkinPart(required="true")]
		/**
		 * The skin part used to display the thumbnail image.
		 */		
		public var ui_img_thumbnail:Image;
		
		
		private var _mediaElement:MediaElement;
		
		
		// Item renderer field properties
		private var _urlField:String				= "url";
		private var _titleField:String				= "title";
		private var _descriptionField:String		= "description";
		private var _thumbnailField:String			= "thumbnail";
		
		public function PlaylistRenderer()
		{
			super();
			_init();
		}

		private function _init():void
		{
			setStyle("skinClass", PlaylistRendererDefaultSkin);
		}

		private function _updateMediaElement():void
		{
			const url:String = data[ _urlField ];
			if (url && url.length)
			{
				_mediaElement = OSMFPlaylist.mediaFactory.createMediaElement(new URLResource(url));
//				_mediaElement = OSMFPlaylist.mediaFactory.createMediaElement();
				
				/**TRACEDISABLE:trace("_mediaElement = " + _mediaElement);*/
			}
		}
		
		private function _setTitle():void
		{
			if (ui_txt_title)
			{
				try
				{
					ui_txt_title.text = data[ _titleField ];
				}
				catch (e:Error)
				{
					/**TRACEDISABLE:trace("data = " + ObjectUtil.toString(data));*/
//					throw new Error("The title field: " + _titleField + ", does not exist on the data objects in the data set for the playlist.");
				}
			}
		}
		
		private function _setDescription():void
		{
			if (ui_txt_description)
			{
				try
				{
					ui_txt_description.text = data[ _descriptionField ];
				}
				catch (e:Error)
				{
//					throw new Error("The description field: " + _descriptionField + ", does not exist on the data objects in the data set for the playlist.");
				}
			}
		}
		
		private function _setThumbnail():void
		{
			if (ui_img_thumbnail)
			{
				try
				{
					ui_img_thumbnail.source = data[ _thumbnailField ];
				}
				catch (e:Error)
				{
//					throw new Error("The thumbnail field: " + _thumbnailField + ", does not exist on the data objects in the data set for the playlist.");
				}
			}
		}
		
		override protected function getCurrentRendererState():String
		{
			// TODO Auto Generated method stub
			return super.getCurrentRendererState();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case ui_img_thumbnail:
					_setThumbnail();
					break;
				
				case ui_txt_description:
					_setDescription();
					break;
				
				case ui_txt_title:
					_setTitle();
					break;
			}
		}

		override protected function partRemoved(partName:String, instance:Object):void
		{
			// TODO Auto Generated method stub
			super.partRemoved(partName, instance);
		}
		
		
		public function set urlField(value:String):void
		{
			_urlField = value;
			_updateMediaElement();
		}

		
		public function set titleField(value:String):void
		{
			_titleField = value;
			_setTitle();
		}
		
		public function set descriptionField(value:String):void
		{
			_descriptionField = value;
			_setDescription();
		}
		
		public function set thumbnailField(value:String):void
		{
			_thumbnailField = value;
			_setThumbnail();
		}
	}
}