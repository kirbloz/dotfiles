// user7334895 from quickshills discord server

// Credits: caelestia shell

pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQml.Models

Singleton {
  id: root

  property list<MprisPlayer> players: []
  property MprisPlayer currentPlayer: null

  readonly property int playerCount: players.length

  readonly property bool canControl: currentPlayer?.canControl ?? false
  readonly property bool canRaise: currentPlayer?.canRaise ?? false
  readonly property bool canPause: currentPlayer?.canPause ?? false
  readonly property bool canQuit: currentPlayer?.canQuit ?? false
  readonly property bool canSeek: currentPlayer?.canSeek ?? false
  readonly property bool canPlay: currentPlayer?.canPlay ?? false
  readonly property bool canGoNext: currentPlayer?.canGoNext ?? false
  readonly property bool canTogglePlaying: currentPlayer?.canTogglePlaying ?? false
  readonly property bool canGoPrevious: currentPlayer?.canGoPrevious ?? false

  readonly property bool positionSupported: currentPlayer?.positionSupported ?? false
  readonly property bool shuffleSupported: currentPlayer?.shuffleSupported ?? false
  readonly property bool loopSupported: currentPlayer?.loopSupported ?? false
  readonly property bool volumeSupported: currentPlayer?.volumeSupported ?? false
  readonly property bool lengthSupported: currentPlayer?.lengthSupported ?? false

  readonly property bool playing: currentPlayer?.isPlaying ?? false
  readonly property bool shuffle: currentPlayer?.shuffle ?? false
  readonly property real rate: currentPlayer?.rate ?? 0
  readonly property real length: currentPlayer?.length ?? 0
  readonly property real volume: currentPlayer?.volume ?? 1.0

  readonly property string currentPlayerName: currentPlayer?.identity ?? ""
  readonly property string artist: currentPlayer?.trackArtist ?? ""
  readonly property string albumCover: currentPlayer?.trackArtUrl ?? ""
  readonly property string album: currentPlayer?.trackAlbum ?? ""
  readonly property string albumArtist: currentPlayer?.trackAlbumArtist ?? ""
  readonly property string title: currentPlayer?.trackTitle ?? ""

  // readonly property MprisPlaybackState playbackState: currentPlayer?.playbackState ?? MprisPlaybackState.Stopped
  // readonly property MprisLoopState loopState: currentPlayer?.loopState ?? MprisLoopState.None

  property bool monitorPosition: false
  property real position: 0
  readonly property real progress: length > 0 ? Math.max(0, Math.min(position / length, 1)) : 0

  function updatePosition(): void {
    if (root.monitorPosition && root.currentPlayer) {
      root.position = root.currentPlayer.position;
    }
  }

  function next(player = root.currentPlayer): void {
    player?.next();
  }

  function pause(player = root.currentPlayer): void {
    player?.pause();
  }

  function play(player = root.currentPlayer): void {
    player?.play();
  }

  function previous(player = root.currentPlayer): void {
    if (player?.canGoPrevious) {
      player.previous();
    }
  }

  function quit(player = root.currentPlayer): void {
    if (player?.canQuit) {
      player.quit();
    }
  }

  function raise(player = root.currentPlayer): void {
    if (player?.canRaise) {
      player.raise();
    }
  }

  function seek(player = root.currentPlayer, offset): void {
    if (player?.canSeek) {
      player.seek(offset);
    }
  }

  function stop(player = root.currentPlayer): void {
    player?.stop();
  }

  function togglePlaying(player = root.currentPlayer): void {
    player?.togglePlaying();
  }

  function refreshPlayers(): void {
    root.players = Mpris.players.values;
    refreshCurrentPlayer();
  }

  function refreshCurrentPlayer(): void {
    const playing = root.players.find(p => p.isPlaying);

    if (playing) {
      root.currentPlayer = playing;
    } else if (!root.currentPlayer && root.players.length > 0) {
      root.currentPlayer = root.players[0];
    } else {
      root.currentPlayer = null;
    }

    root.position = root.currentPlayer?.position ?? 0;
  }

  // populate instantly
  Component.onCompleted: {
    refreshPlayers();
  }

  Connections {
    target: Mpris.players

    function onObjectInsertedPost(): void {
      root.refreshPlayers();
    }

    function onObjectRemovedPost(): void {
      root.refreshPlayers();
    }
  }

  Timer {
    interval: 250
    repeat: true
    running: root.monitorPosition && root.currentPlayer?.playbackState === MprisPlaybackState.Playing

    onTriggered: {
      root.updatePosition()
    }
  }

  Instantiator {
    model: root.players

    delegate: Connections {
      required property var modelData
      target: modelData

      function onTrackArtistChanged(): void {
        root.refreshCurrentPlayer();
      }

      function onTrackArtUrlChanged(): void {
        root.refreshCurrentPlayer();
      }

      function onTrackAlbumChanged(): void {
        root.refreshCurrentPlayer();
      }

      function onTrackAlbumArtistChanged(): void {
        root.refreshCurrentPlayer();
      }

      function onTrackTitleChanged(): void {
        root.refreshCurrentPlayer();
      }

      /*function onPlaybackStateChanged(): void {
        root.refreshCurrentPlayer(); 
      }*/
    }
  }
}