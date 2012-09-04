class Gui.Views.Image extends Gui.Views.Tile
  className: 'tile image'
  template: JST['templates/image']

  canvas: null
  ctx: null
  pattern: null
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
    @model.morpherImage.on 'change triangle:add', @draw


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
    view.on 'highlight', @highlightHandler
    view.on 'select', @selectHandler
    @$el.find('.pane .artboard').append view.render().el

  addAllPointViews: =>
    for view in @pointViews
      view.remove()
    @pointViews = []
    @addPointView(point) for point in @model.morpherImage.points

  removePointView: (point, index, image) =>
    @pointViews[index].remove()
    delete @pointViews.splice index, 1

  dragStopHandler: =>
    @trigger 'drag:stop'

  # highlight

  highlightHandler: (point, state) =>
    index = @pointViews.indexOf point
    if index != -1
      @trigger 'highlight', index, state

  highlightPoint: (index, state) =>
    @pointViews[index].setHighlight state

  # select

  selectHandler: (point, state) =>
    index = @pointViews.indexOf point
    if index != -1
      @trigger 'select', index

  selectPoint: (index, state) =>
    @pointViews[index].setSelection state


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
    @pattern = @buildPattern 10, 10
    @renderUrl()
    @renderFile()
    
    this


  # canvas drawing

  draw: =>
    @canvas.width = @canvas.width
    @ctx.drawImage @img, 0, 0
    for triangle in @model.morpherImage.triangles
      @ctx.beginPath()
      @ctx.moveTo(triangle.p1.x, triangle.p1.y)
      @ctx.lineTo(triangle.p2.x, triangle.p2.y)
      @ctx.lineTo(triangle.p3.x, triangle.p3.y)
      @ctx.closePath()
      @ctx.fillStyle = @pattern
      @ctx.fill()
      @ctx.lineWidth = 2
      @ctx.strokeStyle = "rgba(255,255,255,0.5)"
      @ctx.stroke()
      @ctx.lineWidth = 1
      @ctx.strokeStyle = "rgba(0,0,0,0.5)"
      @ctx.stroke()

  buildPattern: (w, h) =>
    canvas = document.createElement('canvas')
    canvas.width = w
    canvas.height = h
    ctx = canvas.getContext('2d')
    ctx.strokeStyle = "rgba(0,0,0,0.2)"
    ctx.lineWidth = 1
    ctx.lineCap = 'square'
    ctx.beginPath()
    ctx.moveTo(0,h/2)
    ctx.lineTo(w/2,h)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w/2,0)
    ctx.lineTo(w,h/2)
    ctx.stroke()
    ctx.strokeStyle = "rgba(255,255,255,0.2)"
    ctx.beginPath()
    ctx.moveTo(0,0)
    ctx.lineTo(w,h)
    ctx.stroke()
    @ctx.createPattern canvas, "repeat"
