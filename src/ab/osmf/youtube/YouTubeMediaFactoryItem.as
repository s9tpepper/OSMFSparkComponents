package ab.osmf.youtube
{
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	
	/**
	 * YouTubeMediaFactoryItem class is used with a MediaFactory in order
	 * for the media factory to create the right type of resource when a
	 * YouTubeResource is going to be used in an OSMF player.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class YouTubeMediaFactoryItem extends MediaFactoryItem
	{
		private var _id:String = "youtube_element";
		private var _type:String = null;
		
		static public var defaultWidth:Number = 640;
		static public var defaultHeight:Number = 480;
		static public var quality:String = "480";
		
		public function YouTubeMediaFactoryItem()
		{
			super(_id, _canHandleResourceFunction, _mediaElementCreationFunction, _type);
		}
		
		private var _youTubeUrl:String;
		private function _canHandleResourceFunction(mediaResource:MediaResourceBase):Boolean
		{
			if (mediaResource is URLResource && URLResource(mediaResource).url.lastIndexOf("youtube.com") > -1)
			{
				_youTubeUrl = URLResource(mediaResource).url;
				return true;
			}
			
			return false;
		}
		
		private function _mediaElementCreationFunction():MediaElement
		{
			const mediaElement:YouTubeElement = new YouTubeElement(new YouTubeResource(_youTubeUrl, defaultWidth, defaultHeight, quality));
			return mediaElement;
		}
	}
}