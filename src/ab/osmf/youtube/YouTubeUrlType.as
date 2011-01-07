package ab.osmf.youtube
{
	import ab.osmf.spark.player.playlist.URLType;
	
	import org.osmf.media.URLResource;
	
	/**
	 * YouTubeUrlType is used with OSMFPlaylist.addUrlType so the playlist will
	 * make YouTubeResource objects for any URLs containing youtube.com.  This works
	 * to properly work with the YouTubeElement in an OSMF player.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class YouTubeUrlType extends URLType
	{
		private var _url:String;
		public function YouTubeUrlType()
		{
			super();
		}
		
		override public function canHandleUrl(url:String):Boolean
		{
			_url = url;
			
			return (url.lastIndexOf("youtube.com") > -1);
		}
		
		override public function createUrlResource():URLResource
		{
			return new YouTubeResource(_url);
		}
		
	}
}