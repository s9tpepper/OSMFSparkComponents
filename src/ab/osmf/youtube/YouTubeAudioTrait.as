package ab.osmf.youtube
{
	import ab.flash.youtube.YouTubePlayer;
	
	import org.osmf.traits.AudioTrait;
	
	/**
	 * YouTubeAudioTrait class handles implementing the AudioTrait into the 
	 * YouTube chromeless API.
	 * 
	 * @author Omar Gonzalez
	 * 
	 */
	public class YouTubeAudioTrait extends AudioTrait
	{
		private var _youTubePlayer:YouTubePlayer;

		public function YouTubeAudioTrait(youTubePlayer:YouTubePlayer)
		{
			super();
			_init(youTubePlayer);
		}
		
		private function _init(youTubePlayer:YouTubePlayer):void
		{
			_youTubePlayer = youTubePlayer;
		}
		
		override protected function volumeChangeStart(newVolume:Number):void
		{
			newVolume = muted ? 0 : newVolume;
			_youTubePlayer.setVolume(newVolume);
		}
		
		override protected function mutedChangeStart(newMuted:Boolean):void
		{
			const newVolume:Number = newMuted ? 0 : volume;
			_youTubePlayer.setVolume(newVolume);
		}
		
		override protected function panChangeStart(newPan:Number):void
		{
			// No access to panning in _youTubePlayer
		}
	}
}