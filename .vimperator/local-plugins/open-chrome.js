(function(){
    commands.addUserCommand(
      ['chrome', 'ch'],
      'Open the buffer URL in chrome',
      function(args){
        io.system('open -a "/Applications/Google\ Chrome.app" "' + buffer.URL + '"');
      }
    );
})();
