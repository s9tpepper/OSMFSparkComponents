package ab.osmf.youtube
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import org.osmf.elements.loaderClasses.LoaderLoadTrait;
	import org.osmf.elements.loaderClasses.LoaderUtils;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaType;
	import org.osmf.media.MediaTypeUtil;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.URL;
	
	/**
	 * YouTubeLoader class handles loading up the YouTube API player.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class YouTubeLoader extends LoaderBase
	{
		public function YouTubeLoader(initYouTubePlayer:Function)
		{
			_initYouTubePlayer = initYouTubePlayer;
			super();
		}
		
		/**
		 * @private
		 * 
		 * Indicates whether this SWFLoader is capable of handling the specified resource.
		 * Returns <code>true</code> for URLResources with SWF extensions.
		 * @param resource Resource proposed to be loaded.
		 */ 
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
			if (rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
			{
				return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
			}			
			
			var urlResource:URLResource = resource as URLResource;
			if (urlResource != null &&
				urlResource.url != null)
			{
				var url:URL = new URL(urlResource.url);
				return true;
			}	
			return false;
		}
		
		/**
		 * @private
		 * 
		 * Loads content using a flash.display.Loader object. 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to LOADING
		 * while loading and to READY upon completing a successful load.</p> 
		 * 
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#load()
		 * @param loadTrait LoadTrait to be loaded.
		 */ 
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			_loadTrait = loadTrait;
			
			_loader = new Loader();
			LoaderLoadTrait(_loadTrait).loader = _loader;
			_loader.contentLoaderInfo.addEventListener(Event.INIT,_handleInit,false,0,true);
			var lc:LoaderContext = new LoaderContext();
			lc.applicationDomain = ApplicationDomain.currentDomain;
			
			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_loader.load(new URLRequest(YouTubeResource(loadTrait.resource).url), lc);
			
			updateLoadTrait(_loadTrait, LoadState.LOADING);			
		}

		private function onSecurityError(event:SecurityErrorEvent, securityEventDetail:String=null):void
		{
			updateLoadTrait(_loadTrait, LoadState.LOAD_ERROR);
			_loadTrait.dispatchEvent
				( new MediaErrorEvent
					( MediaErrorEvent.MEDIA_ERROR
						, false
						, false
						, new MediaError
						( MediaErrorCodes.IO_ERROR
							, event ? event.text : securityEventDetail
						)
					)
				);
		}

		private function onIOError(event:IOErrorEvent, ioEventDetail:String=null):void
		{
			updateLoadTrait(_loadTrait, LoadState.LOAD_ERROR);
			_loadTrait.dispatchEvent
				( new MediaErrorEvent
					( MediaErrorEvent.MEDIA_ERROR
						, false
						, false
						, new MediaError
						( MediaErrorCodes.IO_ERROR
							, event ? event.text : ioEventDetail
						)
					)
				);
		}

		private function onLoadComplete(event:Event):void
		{
			if (_loadTrait.loadState == LoadState.LOADING)
			{
					updateLoadTrait(_loadTrait, LoadState.READY);
			}
		}
		
		private function _handleInit(event:Event):void
		{
			_initYouTubePlayer(_loader);
		}
		
		/**
		 * @private
		 * 
		 * Unloads content using a flash.display.Loader object.  
		 * 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to UNLOADING
		 * while unloading and to UNINITIALIZED upon completing a successful unload.</p>
		 *
		 * @param loadTrait LoadTrait to be unloaded.
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#unload()
		 */ 
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			LoaderUtils.unloadLoadTrait(loadTrait, updateLoadTrait);
		}
		
		// Internals
		//
		
		/**
		 * @private
		 **/
		public static var allowValidationOfLoadedContent:Boolean = true;  
		
		/**
		 * @private
		 **/
		public function get validateLoadedContentFunction():Function
		{
			return allowValidationOfLoadedContent ? _validateLoadedContentFunction : null;
		}
		
		/**
		 * @private
		 **/
		public function set validateLoadedContentFunction(value:Function):void
		{
			_validateLoadedContentFunction = value;
		}
		
		private var useCurrentSecurityDomain:Boolean = false;
		private var _validateLoadedContentFunction:Function = null;
		
		private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["application/x-shockwave-flash"]);
		private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.SWF]);
		private var _loader:Loader;

		private var _loadTrait:LoadTrait;

		private var _initYouTubePlayer:Function;

	}
}