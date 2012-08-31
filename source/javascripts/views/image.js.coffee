class Gui.Views.Image extends Gui.Views.Tile
  className: 'tile image'
  template: JST['templates/image']

  canvas: null
  ctx: null
  img: null

  pointViews: null

  events:
    'click [data-action]'     : 'clickHandler'
    'change input[name=file]' : 'fileHandler'
    'change input[name=url]'  : 'changeHandler'
    'click canvas'            : 'canvasHandler'

  initialize: =>
    @model.bind 'change:file', @renderFile
    @model.bind 'change:url', @renderUrl  

    @pointViews = []

    @img = new window.Image()
    @img.onload = @draw

    @model.morpherImage.on 'point:add', @addPointView
    @model.morpherImage.on 'point:remove', @removePointView


  # public methods
  
  setSize: (w, h) =>
    @canvas.width = w
    @canvas.height = h
    @draw()


  # menu interaction

  clickHandler: (e) =>
    @[$(e.currentTarget).data('action')]()
    
  delete: =>
    if confirm("Are you sure you want to delete image '#{@model.get('url')}'?")
      @model.destroy()
      
  openFile: =>
    @$('input[name=file]').click()


  # canvas interation

  canvasHandler: (e) =>
    offset = @$canvas.offset()
    x = e.pageX-offset.left
    y = e.pageY-offset.top
    @model.addPoint x, y


  # file related methods

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


  # points

  addPointView: (point) =>
    view = new Gui.Views.Point(model: point)
    @pointViews.push view
    view.on 'drag:stop', @dragStopHandler
    @$el.find('.pane .artboard').append view.render().el

  addAllPointViews: =>
    @addPointView(point) for point in @model.morpherImage.points

  removePointView: =>

  dragStopHandler: =>
    @trigger 'drag:stop'


  # rendering
  
  renderUrl: =>
    @$('input[name=url]').val @model.get('url')

  renderFile: =>
    if @model.get('file')?
      @img.src = @model.get('file')

  render: =>
    @$el.html @template()
    @$canvas = @$('canvas')
    @canvas = @$canvas[0]
    @ctx = @canvas.getContext('2d')
    @renderUrl()
    @renderFile()    
    this


  # canvas drawing

  draw: =>
    @canvas.width = @canvas.width
    @ctx.drawImage @img, 0, 0
