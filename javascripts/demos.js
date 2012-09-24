(function() {
  var _this = this;

  $(function() {
    return $('body.demos .demo').each(function(i, el) {
      var pre;
      pre = $('<pre />').appendTo(el);
      return pre.text($(el).find('script').text());
    });
  });

}).call(this);
