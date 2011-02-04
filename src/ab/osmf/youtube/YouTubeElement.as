package ab.osmf.youtube
{
	import ab.flash.youtube.YouTubeEvent;
	import ab.flash.youtube.YouTubePlayer;
	
	import flash.display.Loader;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.utils.ObjectUtil;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.loaderClasses.LoaderLoadTrait;
	import org.osmf.elements.loaderClasses.LoaderUtils;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.LoadableElementBase;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * YouTubeElement is used to play YouTubeResource objects
	 * in an OSMF video player.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class YouTubeElement extends LoadableElementBase
	{
		private var _loader:Loader;
		private var _loadTrait:LoaderLoadTrait;
		private var _youTubeResource:YouTubeResource;
		private var _youTubePlayer:YouTubePlayer;
		private var _uic:MediaContainer;

		public function YouTubeElement(youTubeResource:YouTubeResource=null)
		{
			Security.allowDomain("http://www.youtube.com");
			Security.allowDomain("http://s.ytimg.com");
			Security.allowDomain("http://t.ytimg.com");
			Security.allowInsecureDomain("http://www.youtube.com");
			Security.allowInsecureDomain("http://s.ytimg.com");
			Security.allowInsecureDomain("http://t.ytimg.com");
			
			_youTubeResource = youTubeResource;
			
			super(youTubeResource, new YouTubeLoader(_initYouTubePlayer));
			
			resource = youTubeResource;

			if (!(resource == null || resource is YouTubeResource))
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
		}
		

		public function get youTubeResource():YouTubeResource
		{
			return _youTubeResource;
		}

		public function set youTubeResource(value:YouTubeResource):void
		{
			_youTubeResource = value;
			
			super.resource = _youTubeResource;
		}

		private function _initYouTubePlayer(loader:Loader):void
		{
			_loader = loader;
			
			_youTubePlayer = new YouTubePlayer(_loader.content, _youTubeResource.defaultWidth, _youTubeResource.defaultHeight, _youTubeResource.quality);
			
			// Give it a display object trait so it appears on stage.
			addTrait(MediaTraitType.DISPLAY_OBJECT, new YouTubeDisplayObjectTrait(_loader, _youTubeResource.defaultWidth, _youTubeResource.defaultHeight));
		}


		/**
		 * Creates the traits for a YouTubeElement so it can do things.
		 * 
		 */
		private function _finishLoading():void
		{
			// Add play trait so it has play/pause capabilities
			addTrait(MediaTraitType.PLAY, new YouTubePlayTrait(_youTubePlayer, _youTubeResource));
			
			// Add audio trait so OSMF can change the volume
			addTrait(MediaTraitType.AUDIO, new YouTubeAudioTrait(_youTubePlayer));
			
			// Add time trait so OSMF can get YouTube's time
			addTrait(MediaTraitType.TIME, new YouTubeTimeTrait(_youTubePlayer));
			
			// Listen for duration change so the seek trait can be added.
			const youTubeTimeTrait:YouTubeTimeTrait = getTrait(MediaTraitType.TIME) as YouTubeTimeTrait;
			youTubeTimeTrait.addEventListener(TimeEvent.DURATION_CHANGE, _handleDurationChange,false,0,true);
		}

		private function _handleDurationChange(event:TimeEvent):void
		{
			const youTubeTimeTrait:YouTubeTimeTrait = getTrait(MediaTraitType.TIME) as YouTubeTimeTrait;
			if (youTubeTimeTrait && youTubeTimeTrait.hasEventListener(TimeEvent.DURATION_CHANGE))
				youTubeTimeTrait.removeEventListener(TimeEvent.DURATION_CHANGE, _handleDurationChange);
			
			// Add seek trait so OSMF can seek YouTube video
			addTrait(MediaTraitType.SEEK, new YouTubeSeekTrait(_youTubePlayer, getTrait(MediaTraitType.TIME) as YouTubeTimeTrait));
//			addTrait(MediaTraitType.SEEK, new SeekTrait(getTrait(MediaTraitType.TIME) as YouTubeTimeTrait));
		}
		
		override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase):LoadTrait
		{
			return new LoaderLoadTrait(loader, resource);
		}
		
		override protected function processReadyState():void
		{
			_loadTrait			= getTrait(MediaTraitType.LOAD) as LoaderLoadTrait;
			_youTubeResource	= _loadTrait.resource as YouTubeResource;
			_loader				= _loadTrait.loader;
			
			_finishLoading();
		}
		
		override protected function setupTraits():void
		{
			
		}
	}
}