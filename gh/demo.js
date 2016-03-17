$(function(){
  // inject source & highlight script tags
  $('.demo script').each(function(){
    var $s = $(this);
    var script = $s.html().trim();
    if (script.length > 0){
      $s.before('<pre><code class="js">' + script + '</code></pre>')
    }
  })
  hljs.initHighlightingOnLoad();
})