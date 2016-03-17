$ =>
  
  $('body.demos .demo').each (i, el) =>
    pre = $('<pre />').appendTo(el)
    code = $('<code />').addClass("javascript").appendTo(pre)
    text = $(el).find('script').text().replace /([\r\n]+)[ ]{8}/g, "$1"
    text = text.replace(/\s*\/\/<![CDATA[[\r\n]*/, "").replace(/\s*\/\/]][\r\n]*>/, "")
    code.text text
   
  if window.hljs 
    hljs.initHighlighting()