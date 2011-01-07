package ab.osmf.spark.player.playlist
{
	import flash.events.IEventDispatcher;
	/**
	 * IPlaylistRenderer is the interface required to create
	 * item renderers for the OSMFPlaylist component.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public interface IPlaylistRenderer extends IEventDispatcher
	{
		function set urlField(value:String):void;
		
		function set titleField(value:String):void;
		
		function set descriptionField(value:String):void;
		
		function set thumbnailField(value:String):void;
	}
}