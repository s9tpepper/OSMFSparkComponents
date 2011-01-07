package ab.osmf.spark.player.playlist
{
	import org.osmf.media.URLResource;

	/**
	 * URLType is used with OSMFPlaylist to create URLResource objects
	 * for media items fed into the playlist.  To create a URLResource
	 * subclass that should be used in conjunction with a MediaElement
	 * subclass you must subclass URLType and pass an instance of the
	 * subclass to OSMFPlaylist.addUrlType().
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class URLType
	{
		private var _url:String;
		
		public function URLType()
		{
		}
		
		public function canHandleUrl(url:String):Boolean
		{
			_url = url;
			return (url.lastIndexOf("http://") > -1)
		}
		
		public function createUrlResource():URLResource
		{
			return new URLResource(_url);
		}
	}
}