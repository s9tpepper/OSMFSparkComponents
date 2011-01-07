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
	
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
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
		
		// Item renderer field properties
		private var _urlField:String				= "url";
		private var _titleField:String				= "title";
		private var _descriptionField:String		= "description";
		private var _thumbnailField:String			= "thumbnail";
		
		// Player properties
		private var _player:OSMFSparkPlayer;
		private var _data:Array;
		private var _autoPlay:Boolean							= true;
		private var _enablePlaylistCycling:Boolean				= true;
		private var _loopPlaylist:Boolean						= true;
		private var _enablePlaylistItemClickToPlay:Boolean		= true;


		public function get enablePlaylistItemClickToPlay():Boolean
		{
			return _enablePlaylistItemClickToPlay;
		}

		public function set enablePlaylistItemClickToPlay(value:Boolean):void
		{
			_enablePlaylistItemClickToPlay = value;
		}

		public function get enablePlaylistCycling():Boolean
		{
			return _enablePlaylistCycling;
		}

		public function set enablePlaylistCycling(value:Boolean):void
		{
			_enablePlaylistCycling = value;
		}

		public function get loopPlaylist():Boolean
		{
			return _loopPlaylist;
		}

		public function set loopPlaylist(value:Boolean):void
		{
			_loopPlaylist = value;
		}



		public function get urlField():String
		{
			return _urlField;
		}

		public function set urlField(value:String):void
		{
			_urlField = value;
		}

		public function get titleField():String
		{
			return _titleField;
		}

		public function set titleField(value:String):void
		{
			_titleField = value;
		}

		public function get descriptionField():String
		{
			return _descriptionField;
		}

		public function set descriptionField(value:String):void
		{
			_descriptionField = value;
		}

		public function get thumbnailField():String
		{
			return _thumbnailField;
		}

		public function set thumbnailField(value:String):void
		{
			_thumbnailField = value;
		}

		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}

		public function set autoPlay(value:Boolean):void
		{
			_autoPlay = value;
		}

		private var _dataProvider:ArrayCollection;
		
		public function OSMFPlaylist()
		{
			super();
			_preinit();
		}

		private function _preinit():void
		{
			setStyle("skinClass", OSMFPlaylistDefaultSkin);
			_initializePlayer();
			
			
			addEventListener(FlexEvent.CREATION_COMPLETE, _handleCreationComplete,false,0,true);
		}

		private function _handleCreationComplete(event:FlexEvent):void
		{
			_initializeList();
			_initializePlayer();
		}

		private function _clearList():void
		{
			_data						= null
			ui_list_media.dataProvider	= null;
		}

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
		
		public function set player(value:OSMFSparkPlayer):void
		{
			_player = value;
			
			_initializePlayer();
		}

		private function _initializePlayer():void
		{
			/**TRACEDISABLE:trace("_initializePlayer()");*/
			// TODO: Initialize the OSMFSparkPlayer instance to work with the playlist
			if (_player)
			{
				/**TRACEDISABLE:trace("_player = " + _player);*/
				/**TRACEDISABLE:trace("_player.autoPlay = " + _player.autoPlay);*/
				/**TRACEDISABLE:trace("_dataProvider = " + _dataProvider);*/
				
				_player.autoPlay = _autoPlay;
				if (_player.autoPlay && _dataProvider)
				{
					_setMediaElementFromPlaylistIndex(0);
				}
				
				_player.addEventListener(OSMFSparkPlayerEvent.MEDIA_COMPLETED_PLAYING, _handleMediaCompletePlaying,false,0,true);
			}
		}
		
		private function _setMediaElementFromPlaylistIndex(index:uint):void
		{
			const item:Object	= _dataProvider.getItemAt(index);
			
			if (item)
			{
				const element:MediaElement = OSMFPlaylist.mediaFactory.createMediaElement(_getUrlResource(item[_urlField]));
				_player.mediaElement = element;
			}
		}

		private function _handleMediaCompletePlaying(event:OSMFSparkPlayerEvent):void
		{
			/**TRACEDISABLE:trace("media finished playing");*/
			if (enablePlaylistCycling)
			{
				_playVideo(_cursor++);
			}
		}

		private function _playVideo(index:uint):void
		{
			if (!_data)
				return;
			
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
			//_player.play();
			
			setTimeout(_player.play, 1000);
		}
		
		private function _getUrlResource(url:String):URLResource
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
		
		static private var _customUrlKeys:Array = new Array();
		static private var _customUrls:Dictionary = new Dictionary();
		static public function addUrlType(type:String, urlType:URLType):void
		{
			_customUrls[type] = urlType;
			
			if (_customUrlKeys.lastIndexOf(type) == -1)
				_customUrlKeys.push(type);
		}
		
		private function _initializeList():void
		{
			if (ui_list_media)
			{
				ui_list_media.addEventListener(RendererExistenceEvent.RENDERER_ADD, _handleRendererAdd,false,0,true);
				ui_list_media.itemRenderer	= new ClassFactory(PlaylistRenderer);
				_setList();
				_setListHeight();
				_setListWidth();
			}
		}

		private function _handleRendererAdd(event:RendererExistenceEvent):void
		{
			// TODO: Set up the item renderer
			/**TRACEDISABLE:trace("event.renderer = " + event.renderer);*/
			
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
			
			playlistRenderer.descriptionField	= descriptionField;
			playlistRenderer.thumbnailField		= thumbnailField;
			playlistRenderer.titleField			= titleField;
			playlistRenderer.urlField			= urlField;
		}

		private function _handlePlaylistItemClick(event:MouseEvent):void
		{
			/**TRACEDISABLE:trace("_handlePlaylistItemClick()");*/
			/**TRACEDISABLE:trace("event.target = " + event.target);*/
			/**TRACEDISABLE:trace("event.currentTarget = " + event.currentTarget);*/
			if (_enablePlaylistItemClickToPlay)
			{
				const dataRenderer:IDataRenderer = event.currentTarget as IDataRenderer;
				/**TRACEDISABLE:trace("dataRenderer = " + dataRenderer);*/
				if (dataRenderer)
				{
					const mediaIndex:uint = _dataProvider.getItemIndex(dataRenderer.data);
					if (_player)
					{
						_playVideo(mediaIndex);
					}
				}
			}
		}
		
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
		
		private var _playlistHeight:Number;
		private var _playlistWidth:Number;
		private var _cursor:uint;

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

		private function _setListWidth():void
		{
			if (ui_list_media)
				ui_list_media.width = _playlistWidth;
		}

		private function _setListHeight():void
		{
			if (ui_list_media)
				ui_list_media.height = _playlistHeight;
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
				case ui_list_media:
					_initializeList();
					break;
			}
		}

		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
	}
}