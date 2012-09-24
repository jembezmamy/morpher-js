$ =>
  $('body.demos .demo').each (i, el) =>
    pre = $('<pre />').appendTo(el)
    pre.text $(el).find('script').text()


