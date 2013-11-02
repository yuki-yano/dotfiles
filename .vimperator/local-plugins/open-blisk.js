(function(){
    commands.addUserCommand(
      ['blisk', 'bl'],
      'Open the buffer URL in blisk',
      function(args){
        io.system('open -a "/Applications/Blisk.app" "' + buffer.URL + '"');
      }
    );
})();
