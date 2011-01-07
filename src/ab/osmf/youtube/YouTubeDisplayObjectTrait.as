package ab.osmf.youtube
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	
	import org.osmf.traits.DisplayObjectTrait;
	/**
	 * Extends the DisplayObjectTrait class to properly set up the YouTube
	 * API player by calling the setSize() method when it becomes available
	 * from the SWFProxy class that is at the base of the API player.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */	
	public class YouTubeDisplayObjectTrait extends DisplayObjectTrait
	{
		/**
		 * @Constructor
		 * 
		 * @param displayObject
		 * @param mediaWidth
		 * @param mediaHeight
		 * 
		 */
		public function YouTubeDisplayObjectTrait(displayObject:Loader, mediaWidth:Number=0, mediaHeight:Number=0)
		{
			displayObject.addEventListener(Event.ADDED_TO_STAGE, _handleAddedToStage);
			displayObject.addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
			
			super(displayObject, mediaWidth, mediaHeight);
		}

		/**
		 * @private
		 */		
		private function _handleAddedToStage(event:Event):void
		{
			displayObject.removeEventListener(Event.ADDED_TO_STAGE, _handleAddedToStage);
		}

		/**
		 * @private
		 */
		private function _handleEnterFrame(event:Event):void
		{
			const loader:Loader = displayObject as Loader;
			if (loader)
			{
				try
				{
					Object(loader.content).setSize(mediaWidth, mediaHeight);
					
					loader.width	= mediaWidth;
					loader.height	= mediaHeight;
					
					loader.content.width = mediaWidth;
					loader.content.height = mediaHeight;
					
					displayObject.removeEventListener(Event.ENTER_FRAME, _handleEnterFrame);
				} 
				catch (e:Error)
				{ 
					/* setSize() is not yet available. */ 
				}
			}
		}
	}
}