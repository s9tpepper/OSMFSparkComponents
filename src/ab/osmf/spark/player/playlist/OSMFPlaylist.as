package ab.osmf.spark.player.playlist
{
	
	import ab.osmf.spark.player.OSMFSparkPlayer;
	import ab.osmf.spark.player.OSMFSparkPlayerEvent;
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.IDataRenderer;
	import mx.events.FlexEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.utils.ObjectUtil;
	
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	
	import spark.components.List;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.RendererExistenceEvent;
	
	
	/**
	 * OSMFPlaylist is a Spark component used in conjunction with an 
	 * OSMFSparkPlayer instance to create a playlist of OSMF supported
	 * media to display.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class OSMFPlaylist extends SkinnableComponent
	{
		// Skins
		[SkinPart(required="true")]
		/**
		 * Skin part used to display a list of media items.
		 */		
		public var ui_list_media:List;
		
		static public var mediaFactory:MediaFactory	= new DefaultMediaFactory();
		
		static private var _customUrlKeys:Array		= new Array();
		static private var _customUrls:Dictionary	= new Dictionary();
		
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
		
		// Player properties
		/**
		 * @private
		 */
		private var _player:OSMFSparkPlayer;
		
		// Playlist properties
		/**
		 * @private
		 */
		private var _data:Array;
		/**
		 * @private
		 */
		private var _autoPlay:Boolean							= true;
		/**
		 * @private
		 */
		private var _enablePlaylistCycling:Boolean				= true;
		/**
		 * @private
		 */
		private var _loopPlaylist:Boolean						= true;
		/**
		 * @private
		 */
		private var _enablePlaylistItemClickToPlay:Boolean		= true;
		/**
		 * @private
		 */
		private var _playlistHeight:Number;
		/**
		 * @private
		 */
		private var _playlistWidth:Number;
		/**
		 * @private
		 */
		private var _cursor:uint;
		/**
		 * @private
		 */
		private var _dataProvider:ArrayCollection;
		/**
		 * @private
		 */
		private var _playlistItemRenderer:Class					= PlaylistRenderer;
		/**
		 * @private
		 */
		protected var skinPartInitializationClosures:Dictionary;





		/**
		 * The IPlaylistItemRenderer class to use for the playlist.  This property
		 * defaults to the PlaylistRenderer class.
		 * 
		 * @return 
		 * 
		 */		
		public function get playlistItemRenderer():Class
		{
			return _playlistItemRenderer;
		}
		public function set playlistItemRenderer(value:Class):void
		{
			_playlistItemRenderer = value;
			
			if (ui_list_media)
			{
				ui_list_media.itemRenderer = new ClassFactory(_playlistItemRenderer);
			}
		}

		/**
		 * Whether the playlist component allows the user to click an item to
		 * advance to the clicked media item.
		 * 
		 * @return 
		 * 
		 */		
		public function get enablePlaylistItemClickToPlay():Boolean
		{
			return _enablePlaylistItemClickToPlay;
		}
		public function set enablePlaylistItemClickToPlay(value:Boolean):void
		{
			_enablePlaylistItemClickToPlay = value;
		}

		/**
		 * Whether the playlist should cycle to the next item in the playlist
		 * when a media item has completed playing.
		 * 
		 * @return 
		 * 
		 */		
		public function get enablePlaylistCycling():Boolean
		{
			return _enablePlaylistCycling;
		}
		public function set enablePlaylistCycling(value:Boolean):void
		{
			_enablePlaylistCycling = value;
		}

		/**
		 * Whether the playlist should loop to the beginning of the playlist
		 * when the enablePlaylistCycling is set to true, when enablePlaylistCycling
		 * is set to false this property has no effect.
		 * 
		 * @return 
		 * 
		 */		
		public function get loopPlaylist():Boolean
		{
			return _loopPlaylist;
		}
		public function set loopPlaylist(value:Boolean):void
		{
			_loopPlaylist = value;
		}

		/**
		 * The field on the data objects to use for the media
		 * URL in the playlist item renderer.
		 * 
		 * @return 
		 * 
		 */		
		public function get urlField():String
		{
			return _urlField;
		}
		public function set urlField(value:String):void
		{
			_urlField = value;
		}

		/**
		 * The field on the data objects to use for the media
		 * title in the playlist item renderer.
		 * 
		 * @return 
		 * 
		 */		
		public function get titleField():String
		{
			return _titleField;
		}
		public function set titleField(value:String):void
		{
			_titleField = value;
		}

		/**
		 * The field on the data objects to use for the media
		 * description in the playlist item renderer.
		 * 
		 * @return 
		 * 
		 */		
		public function get descriptionField():String
		{
			return _descriptionField;
		}
		public function set descriptionField(value:String):void
		{
			_descriptionField = value;
		}

		/**
		 * The field on the data objects to use for the media
		 * thumbnail in the playlist item renderer.
		 * 
		 * @return 
		 * 
		 */		
		public function get thumbnailField():String
		{
			return _thumbnailField;
		}
		public function set thumbnailField(value:String):void
		{
			_thumbnailField = value;
		}

		/**
		 * Whether the playlist component should auto play media.
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
		}
		
		/**
		 * The array of objects to display as the playlist contents, the field properties
		 * are used to pick display info from the data objects.
		 * 
		 * @param value
		 * 
		 */		
		public function set data(value:Array):void
		{
			_clearList();
			
			_data			= value;
			_dataProvider	= new ArrayCollection(_data);
			
			_setList();
			_initializePlayer();
		}
		public function get data():Array
		{
			return _data;
		}
		
		/**
		 * OSMFSparkPlayer instance setter to configure the playlist component to use
		 * the correct player instance.
		 * 
		 * @param value
		 * 
		 */		
		public function set player(value:OSMFSparkPlayer):void
		{
			_player = value;
			
			_initializePlayer();
		}
		
		public function get player():OSMFSparkPlayer
		{
			return _player;
		}

		/**
		 * @Constructor
		 * 
		 */		
		public function OSMFPlaylist()
		{
			super();
			_init();
		}
		
		/**
		 * Static helpter method used to get instances of URLResource.  Also uses
		 * custom URLResource subclasses registered with addUrlType() method, for 
		 * example the YouTubeUrlType class that comes with the YouTube OSMFSparkComponents
		 * set of classes for YouTube.
		 * 
		 * @param url
		 * @return 
		 * 
		 */		
		static public function getUrlResource(url:String):URLResource
		{
			var type:String;
			var urlType:URLType;
			for each (type in _customUrlKeys)
			{
				urlType = _customUrls[type];
				
				if (urlType.canHandleUrl(url))
				{
					return urlType.createUrlResource();
				}
			}
			
			return new URLResource(url);
		}
		/**
		 * Used to add URLResource sub-classes to handle specific types of medis
		 * URLs, such as the YouTube element.
		 * 
		 * @param type
		 * @param urlType
		 * 
		 */		
		static public function addUrlType(type:String, urlType:URLType):void
		{
			_customUrls[type] = urlType;
			
			if (_customUrlKeys.lastIndexOf(type) == -1)
				_customUrlKeys.push(type);
		}

		/**
		 * @private
		 */		
		private function _init():void
		{
			mapSkinPartInitializationClosures();
			
			checkSkin("ab.osmf.spark.player.playlist.OSMFPlaylist", OSMFPlaylistDefaultSkin);
			
			addEventListener(FlexEvent.CREATION_COMPLETE, _handleCreationComplete,false,0,true);
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
		private function _handleCreationComplete(event:FlexEvent):void
		{
			_initializeList();
			_initializePlayer();
		}
		/**
		 * @private
		 */	
		private function _clearList():void
		{
			_data						= null
			ui_list_media.dataProvider	= null;
		}
		/**
		 * @private
		 */	
		private function _setList():void
		{
			if (ui_list_media)
			{
				ui_list_media.dataProvider	= _dataProvider;
				if (_dataProvider)
					_dataProvider.refresh();
				
				/**TRACEDISABLE:trace("Set list...");*/
			}
		}
		/**
		 * @private
		 */	
		private function _initializePlayer():void
		{
			if (_player)
			{
				_player.autoPlay = _autoPlay;
				
				if (_player.autoPlay && _dataProvider)
				{
					_setMediaElementFromPlaylistIndex(0);
				}
				
				_player.addEventListener(OSMFSparkPlayerEvent.MEDIA_COMPLETED_PLAYING, _handleMediaCompletePlaying,false,0,true);
			}
		}
		/**
		 * @private
		 */	
		private function _setMediaElementFromPlaylistIndex(index:uint):void
		{
			const item:Object	= _dataProvider.getItemAt(index);
			
			if (item)
			{
				updateMediaElement(item);
			}
		}
		
		protected function updateMediaElement(item:Object):void
		{
			var itemUrl:String = "";
			try
			{
				itemUrl = item[_urlField];
			}
			catch (e:Error){}
		
			if (itemUrl && itemUrl.length)
			{
				const mediaResourceBase:MediaResourceBase = createMediaResource(itemUrl);
		
				if (mediaResourceBase)
				{
					const element:MediaElement = createMediaElement(mediaResourceBase);
		
					if (element)
						_player.mediaElement = element;
				}
			}
		}
		
		protected function createMediaElement(mediaResourceBase:MediaResourceBase):MediaElement
		{
			return OSMFPlaylist.mediaFactory.createMediaElement(mediaResourceBase);
		}
		
		protected function createMediaResource(itemUrl:String):MediaResourceBase
		{
			return getUrlResource(itemUrl);
		}


		/**
		 * @private
		 */	
		private function _handleMediaCompletePlaying(event:OSMFSparkPlayerEvent):void
		{
			if (enablePlaylistCycling)
			{
				var nextIndex:Number = _cursor + 1;
				_playVideo(nextIndex);
			}
		}
		/**
		 * @private
		 */	
		private function _playVideo(index:uint):void
		{
			if (!_data)
				return;
			
			_cursor = index;
			
			if (loopPlaylist)
			{
				if (_cursor > _data.length - 1)
				{
					_cursor = 0;
				}
			}
			else if (_cursor > _data.length - 1)
			{
				// Tried to play an index that is out of bounds, set to highest index and do not play anything.
				_cursor = _data.length - 1;
				return;
			}
			
			_setMediaElementFromPlaylistIndex(_cursor);
			
			_player.play();
		}
		/**
		 * @private
		 */	
		private function _initializeList():void
		{
			if (ui_list_media)
			{
				ui_list_media.addEventListener(RendererExistenceEvent.RENDERER_ADD, _handleRendererAdd,false,0,true);
				ui_list_media.itemRenderer	= new ClassFactory(_playlistItemRenderer);
				_setList();
				_setListHeight();
				_setListWidth();
			}
		}
		/**
		 * @private
		 */	
		private function _handleRendererAdd(event:RendererExistenceEvent):void
		{
			try
			{
				const playlistRenderer:IPlaylistRenderer = event.renderer as IPlaylistRenderer;
				
				if (_enablePlaylistItemClickToPlay)
				{
					playlistRenderer.addEventListener(MouseEvent.CLICK, _handlePlaylistItemClick, false, 0, true);
				}
			} 
			catch(error:Error) 
			{
				throw new Error("The item renderer for the List component must implement the IPlaylistRenderer interface.");
			}
			
			configureRendererInstance(playlistRenderer);
		}
		/**
		 * @private
		 */	
		private function _handlePlaylistItemClick(event:MouseEvent):void
		{
			if (_enablePlaylistItemClickToPlay)
			{
				if (_player.isPlaying)
				{
					// Set _cursor to the index before the selection and trigger end of video by calling stop().
					// MediaPlayer set STOPPED state when it reaches the end of the video or if you call stop().
					// This is the most reliable way to get it to stop and have the media player work properly
					// when the next media element is set.
					_cursor = ui_list_media.selectedIndex - 1;
					_player.stop();
				}
				else
				{
					_playVideo(ui_list_media.selectedIndex);
				}
			}
		}
		/**
		 * @private
		 */	
		private function _setListWidth():void
		{
			if (ui_list_media)
				ui_list_media.width = _playlistWidth;
		}
		/**
		 * @private
		 */	
		private function _setListHeight():void
		{
			if (ui_list_media)
				ui_list_media.height = _playlistHeight;
		}
		
		/**
		 * When a IPlaylistRenderer object is created by the list component, this method
		 * is called during the RendererExistenceEvent.RENDERER_ADDED event, here is where
		 * the data field properties are configured on the renderer so when it receives
		 * its data object it can retrieve the data fields and assign them to the proper
		 * skin parts in the renderer.  This method should be called in OSMFPlaylist
		 * subclasses to customize the renderer data fields.
		 * 
		 * @param playlistRenderer
		 * 
		 */		
		protected function configureRendererInstance(playlistRenderer:IPlaylistRenderer):void
		{
			playlistRenderer.descriptionField	= descriptionField;
			playlistRenderer.thumbnailField		= thumbnailField;
			playlistRenderer.titleField			= titleField;
			playlistRenderer.urlField			= urlField;
		}
		/**
		 * Maps the skin parts by name to an initialization function used in partAdded() override.
		 * OSMFPlaylist subclasses should call this method to initialize the default skin parts
		 * and add initialization closures for custom skin parts.
		 * 
		 */		
		protected function mapSkinPartInitializationClosures():void
		{
			skinPartInitializationClosures						= new Dictionary();
			skinPartInitializationClosures["ui_list_media"]		= _initializeList;
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
		
		override public function set height(value:Number):void
		{
			_playlistHeight = value;
			
			super.height = value;
			
			_setListHeight();
		}
		
		override public function set width(value:Number):void
		{
			_playlistWidth = value;
			
			super.width = value;
			
			_setListWidth();
		}
		
	}
}