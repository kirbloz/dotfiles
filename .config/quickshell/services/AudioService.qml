pragma Singleton
import QtQuick
import qs
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property int percentage: sink?.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted: sink?.audio ? sink.audio.muted : false


      function setVolume(pct: real): void{
        if (sink?.ready && sink?.audio) {
          sink.audio.muted = false; sink.audio.volume = pct/100;
        }
      } 

      function toggleMute(): void {
        if (sink?.ready && sink?.audio)
          sink.audio.muted = !sink.audio.muted;
      }

      function adjustVolume(volStep): void{
         // TODO implement correctly with a cooldown
      }

      PwObjectTracker {
        objects: [root.sink]
      }
}
