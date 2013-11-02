(function(){

  var defaultWidth = 150;
  var enabled = true;

  commands.addUserCommand(['toggletreetab'],'toggle tabbar view',
    function(args){
      TreeStyleTabService.setTabbarWidth(enabled ? 1 : width);
      enabled = !enabled;
    }
    );

   if (liberator.globalVariables.treetabwidth > 1) {
     width = liberator.globalVariables.treetabwidth;
   } else {
     width = defaultWidth;
   }
   TreeStyleTabService.setTabbarWidth(width);
})();
