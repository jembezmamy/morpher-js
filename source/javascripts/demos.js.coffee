$ =>
  $('body.demos .demo').each (i, el) =>
    pre = $('<pre />').appendTo(el)
    code = $('<code />').addClass("javascript").appendTo(pre)
    text = $(el).find('script').text().replace /[ ]{8}/g, ""
    text = text.replace(/\s*\/\/<![CDATA[[\r\n]*/, "").replace(/\s*\/\/]][\r\n]*>/, "")
    code.text text
    
  hljs.initHighlighting()