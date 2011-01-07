package ab.osmf.spark.player
{
	
	import spark.components.Button;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.primitives.Rect;
	
	
	/**
	 * The LoadableMediaScrubber is used to display the playback
	 * progress and download progress of a media item being displayed
	 * by a media player.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */	
	public class LoadableMediaScrubber extends SkinnableComponent
	{
		
		[SkinPart(required="true")]
		/**
		 * The scrubber track, a button type so the user can
		 * click the track to scrub.
		 */
		public var ui_btn_track:Button;
		
		[SkinPart(required="true")]
		/**
		 * The scrubber download progress bar skin.
		 */
		public var ui_rect_downloadProgress:Rect;
		
		[SkinPart(required="true")]
		/**
		 * The scrubber playback position bar skin
		 */
		public var ui_rect_playbackProgress:Rect;
		
		[SkinPart(required="false")]
		/**
		 * The scrubber thumb control, used to scrub media.
		 */
		public var ui_btn_thumb:Button;
		
		/**
		 * @Constructor
		 */		
		public function LoadableMediaScrubber()
		{
			super();
			_init();
		}

		private function _init():void
		{
			setStyle("skinClass", LoadableMediaScrubberDefaultSkin);
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
	}
}