(() => {
  const zwUrl = 'http://www.nicovideo.jp/my#ZenzaWatch'
  const zw = () => { return zwBrowser.contentWindow.wrappedJSObject.ZenzaWatch; }
  let zwBrowser;
  const subCommands = [
    // new Command([''], '', (args) => {}, {}, true),
    new Command(['executeCommand', 'exec'], '', (args) => {
      let table = {
        '%TITLE%': () => { return zw().debug.dialog._videoInfo.getTitle(); },
        '%URL%': () => { return `http://www.nicovideo.jp/watch/${zw().debug.dialog._watchId}`; },
        '%VIDEO_ID%': () => { return zw().debug.dialog._watchId; }
      }
      let arg = args.literalArg;
      for (ph in table) {
        arg = arg.replace(ph, table[ph]());
      }
      setTimeout(() => commandline.open(':', arg + ' ', modes.EX), 0);
    }, {
      literal: 0
    }, true),
    new Command(['seek'], '', (args) => {
      zw().debug.nicoVideoPlayer.setCurrentTime(zw().debug.nicoVideoPlayer.getCurrentTime() + parseInt(args.literalArg, 10));
    }, {
      literal: 0
    }, true),
    new Command(['mute'], '', (args) => {
      zw().config.setValue('mute', !zw().config.getValue('mute'));
    }, {}, true),
    new Command(['volume'], '', (args) => {
      let volume = zw().debug.nicoVideoPlayer._videoPlayer.getVolume();
      if (/^(\+|-)/.test(args.literalArg)) {
          volume += args.literalArg * 0.1
        } else {
          volume = args.literalArg * 0.1
        }
      zw().debug.nicoVideoPlayer._videoPlayer.setVolume(volume);
    }, {
      literal: 0
    }, true),
    new Command(['showComment'], '', (args) => {
      zw().config.setValue('showComment', !zw().config.getValue('showComment'));
    }, {}, true),
    new Command(['close'], '', (args) => {
      zw().debug.dialog.close();
    }, {}, true),
    new Command(['togglePlay'], '', (args) => {
      zw().debug.nicoVideoPlayer.togglePlay();
    }, {}, true),
    new Command(['open'], '', (args) => {
      let zwTab;
      const init = (zwBrowser) => {
        const document = zwBrowser.contentDocument;
        const jso = zwBrowser.contentWindow.wrappedJSObject;
        document.title = 'ZenzaWatch Player';
        const intervalId = setInterval(() => {
          if (jso.ZenzaWatch && jso.ZenzaWatch.debug && jso.ZenzaWatch.debug.dialog) {
            clearInterval(intervalId);
            jso.ZenzaWatch.debug.dialog.open(videoId);
            zwBrowser.contentWindow.history.pushState(null, null, `http://www.nicovideo.jp/watch/${videoId}`);
          }
        }, 100);
      }
      const videoId = args[0];
      for (let tab of gBrowser.tabs) {
        if (zwUrl === tab.linkedBrowser.currentURI.spec){
          zwTab = tab;
        }
      }
      if (zwTab) {
        zwBrowser = zwTab.linkedBrowser;
        gBrowser.selectedTab = zwTab;
        init(zwBrowser);
      } else {
        if (TreeStyleTabService) { TreeStyleTabService.readyToOpenChildTabNow(gBrowser.selectedTab); }
        zwBrowser = gBrowser.loadOneTab(zwUrl, { inBackground: args.bang }).linkedBrowser;
        zwBrowser.addEventListener('DOMContentLoaded', function onload() {
          zwBrowser.removeEventListener('DOMContentLoaded', onload, false);
          init(zwBrowser);
        }, false);
      }
    }, {
      bang: true
    }, true)
  ];

  commands.addUserCommand(['zenzaWatch'], 'ZenzaWatchを呼び出す', (args) => {
  }, {
    subCommands: subCommands,
  }, true);
})();