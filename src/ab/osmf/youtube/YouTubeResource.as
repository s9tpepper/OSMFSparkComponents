package ab.osmf.youtube
{
	import org.osmf.media.MediaType;
	import org.osmf.media.URLResource;

	/**
	 * The resource object to use to create a YouTubeElement.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */	
	public class YouTubeResource extends URLResource
	{
		private const _YOU_TUBE_PLAYER:String = "http://www.youtube.com/apiplayer?version=3";
		private const _YOU_TUBE_BASE:String = "http://www.youtube.com";
		private var _videoUrl:String = "/watch?v="
		private var _defaultWidth:Number;
		private var _defaultHeight:Number;
		private var _quality:String;
		
		/**
		 * @Constructor
		 * 
		 * @param url
		 * @param defaultWidth
		 * @param defaultHeight
		 * @param quality
		 * 
		 */
		public function YouTubeResource(url:String=null, defaultWidth:Number = 640, defaultHeight:Number = 480, quality:String = "hd480")
		{
			super(_YOU_TUBE_PLAYER);
			_init(url, defaultWidth, defaultHeight, quality);
		}


		public function get videoUrl():String
		{
			return _videoUrl;
		}

		public function set defaultWidth(value:Number):void
		{
			_defaultWidth = value;
		}

		public function set defaultHeight(value:Number):void
		{
			_defaultHeight = value;
		}

		public function set quality(value:String):void
		{
			_quality = value;
		}

		/**
		 * Gets the desired default width.
		 * 
		 * @return 
		 * 
		 */
		public function get defaultWidth():Number
		{
			return _defaultWidth;
		}
		/**
		 * Gets the desired default height.
		 * 
		 * @return 
		 * 
		 */
		public function get defaultHeight():Number
		{
			return _defaultHeight;
		}

		/**
		 * Initializes the resource.
		 * 
		 * @param url
		 * @param defaultWidth
		 * @param defaultHeight
		 * @param quality
		 * 
		 */
		private function _init(url:String=null, defaultWidth:Number = 640, defaultHeight:Number = 480, quality:String = "hd480"):void
		{
			_defaultWidth = defaultWidth;
			_defaultHeight = defaultHeight;
			_quality = quality;
			
			_initURL(url);
			
			mimeType = "application/x-shockwave-flash";
			mediaType = MediaType.SWF;
		}

		private function _initURL(newURL:String):void
		{
			if (!newURL)
				return;
			
			// Prepare url
			if (newURL.lastIndexOf(_YOU_TUBE_BASE) == -1)
			{
				_videoUrl = _YOU_TUBE_BASE + _videoUrl + newURL;
			}
			else
			{
				_videoUrl = newURL;
			}
		}


		/**
		 * Returns the YouTube url.
		 * 
		 * @return 
		 * 
		 */		
		public function get youTubeAPIVideoURL():String
		{
			return _videoUrl;
		}
		/**
		 * Returns the desired quality to start with.
		 * 
		 * @return 
		 * 
		 */		
		public function get quality():String
		{
			return _quality;
		}
		/**
		 * Override of the url property to return the YouTube api
		 * player and init the player.
		 * 
		 * @return 
		 * 
		 */		
		override public function get url():String
		{
			return _YOU_TUBE_PLAYER;
		}
		
		public function set url(value:String):void
		{
			_initURL(value);
		}
	}
}