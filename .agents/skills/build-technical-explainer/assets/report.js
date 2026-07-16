(function () {
  "use strict";

  document.querySelectorAll("[data-findings]").forEach(function (block) {
    var selects = Array.prototype.slice.call(block.querySelectorAll("[data-facet-select]"));
    var items = Array.prototype.slice.call(block.querySelectorAll("[data-finding-item]"));
    var count = block.querySelector("[data-filter-count]");
    var reset = block.querySelector("[data-filter-reset]");

    function apply() {
      var visible = 0;
      items.forEach(function (item) {
        var show = selects.every(function (select) {
          return select.value === "" || item.getAttribute("data-facet-" + select.dataset.facetSelect) === select.value;
        });
        item.hidden = !show;
        if (show) visible += 1;
      });
      count.textContent = visible + " / " + items.length + " 件";
    }

    selects.forEach(function (select) {
      select.addEventListener("change", apply);
    });
    reset.addEventListener("click", function () {
      selects.forEach(function (select) { select.value = ""; });
      apply();
    });

    function revealHashTarget() {
      if (!location.hash) return;
      var target = document.getElementById(location.hash.slice(1));
      if (target && block.contains(target) && target.matches("[data-finding-item]") && target.hidden) {
        selects.forEach(function (select) { select.value = ""; });
        apply();
      }
    }

    apply();
    revealHashTarget();
    window.addEventListener("hashchange", revealHashTarget);
  });
}());
