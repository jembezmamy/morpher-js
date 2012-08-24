class Gui.Views.Image extends Backbone.View
  className: 'image'
  template: JST['templates/image']

  events:
    'click [data-action]'     : 'clickHandler'
    'change input[name=file]' : 'fileHandler'
    'change input[name=url]'  : 'changeHandler'

  initialize: =>
    @model.bind 'change:file', @renderFile
    @model.bind 'change:url', @renderUrl

  setPosition: (x, y, width, height) =>
    @$el.css
      left: "#{x*100}%",
      top: "#{y*100}%",
      width: "#{width*100}%",
      height: "#{height*100}%"
      


  clickHandler: (e) =>
    @[$(e.currentTarget).data('action')]()
    
  delete: =>
    if confirm("Are you sure you want to delete image '#{@model.get('url')}'?")
      @model.destroy()
      
  openFile: =>
    @$('input[name=file]').click()



  fileHandler: (e) =>
    file = e.target.files[0]
    return unless file.type.match('image.*')
    reader = new FileReader()
    reader.onload = (e) =>
      params = file: e.target.result
      unless @model.get('url')?
        url = @$('input[name="file"]').val()
        match = url.match(/[^\\/]+$/)
        params.url = match[0] if match
      @$('input[name="file"]').val ''
      @model.save params
    reader.readAsDataURL(file)        

  changeHandler: (e) =>
    @model.save $(e.currentTarget).attr('name'), $(e.currentTarget).val()


  renderUrl: =>
    @$('input[name=url]').val @model.get('url')

  renderFile: =>
    @$('.pane > img').remove()
    if @model.get('file')?
      $('<img />').attr(src: @model.get('file')).appendTo @$('.pane')

  render: =>
    @$el.html @template()
    @renderUrl()
    @renderFile()    
    this
