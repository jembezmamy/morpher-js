class Gui.Views.Image extends Gui.Views.Tile
  className: 'tile image'
  template: JST['templates/image']

  canvas: null
  ctx: null
  pattern: null
  img: null

  pointViews: null
  midpointViews: null
  splitInProgress: false

  moveMode: false
  moveDelta: null

  events:
    'click [data-action]'             : 'clickHandler'
    'change input[name=file]'         : 'fileHandler'
    'change input[name=url]'          : 'changeHandler'
    'change input[name=targetWeight]' : 'changeHandler'
    'input input[name=targetWeight]'  : 'changeHandler'
    'click canvas'                    : 'canvasHandler'
    'mousedown canvas'                : 'moveHandler'

  initialize: =>
    @model.bind 'change:file', @renderFile
    @model.bind 'change:url', @renderUrl
    @model.bind 'change:weight', @renderWeight

    @pointViews = []
    @midpointViews = []

    @img = new window.Image()
    @img.onload = @draw

    @model.morpherImage.on 'point:add', @addPointView
    @model.morpherImage.on 'point:remove', @removePointView
    @model.morpherImage.on 'triangle:add', @addMidpointViews
    @model.morpherImage.on 'change triangle:add triangle:remove', @draw


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

  move: =>
    @moveMode = !@moveMode
    if @moveMode
      @$('button[data-action=move]').addClass('selected')
      @$('.artboard').addClass('move-mode')
    else
      @$('button[data-action=move]').removeClass('selected')
      @$('.artboard').removeClass('move-mode')


  # canvas interation

  canvasHandler: (e) =>
    return if @moveMode
    offset = @$canvas.offset()
    x = e.pageX-offset.left - @model.morpherImage.getX()
    y = e.pageY-offset.top - @model.morpherImage.getY()
    @model.addPoint x, y

  moveHandler: (e) =>
    return unless @moveMode
    switch e.type
      when 'mousedown'
        @moveDelta =
          x: e.pageX - @model.morpherImage.getX(),
          y: e.pageY - @model.morpherImage.getY()
        $(window).on 'mousemove mouseup', @moveHandler
      when 'mousemove'
        @model.morpherImage.moveTo e.pageX-@moveDelta.x, e.pageY-@moveDelta.y
      when 'mouseup'
        $(window).off 'mousemove mouseup', @moveHandler


  # model attributes

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

  addPointView: (image, point) =>
    view = new Gui.Views.Point(model: point, image: @model.morpherImage)
    @pointViews.push view
    view.on 'drag:stop', @dragStopHandler
    view.on 'highlight', @highlightHandler
    view.on 'select', @selectHandler
    @$el.find('.pane .artboard').append view.render().el
    if @splitInProgress
      @splitInProgress = false
      view.startDrag()

  addAllPointViews: =>
    for view in @pointViews
      view.remove()
    @pointViews = []
    @addPointView(null, point) for point in @model.morpherImage.mesh.points

  removePointView: (image, point, index) =>
    @pointViews[index].remove()
    delete @pointViews.splice index, 1

  dragStopHandler: =>
    @trigger 'drag:stop'

  # midpoints

  addMidpointView: (image, triangle, p1, p2) =>
    for point in @midpointViews
      if (point.p1 == p1 && point.p2 == p2) || (point.p1 == p2 && point.p2 == p1)
        point.addTriangle triangle
        return
    view = new Gui.Views.Midpoint(triangle: triangle, p1: p1, p2: p2, image: @model.morpherImage)
    view.on 'highlight', @highlightHandler
    view.on 'edge:split', @splitHandler
    view.on 'remove', @removeMidpointView
    @midpointViews.push view
    @$el.find('.pane .artboard').append view.render().el

  addMidpointViews: (image, i1, i2, i3, triangle) =>
    @addMidpointView image, triangle, triangle.p1, triangle.p2
    @addMidpointView image, triangle, triangle.p2, triangle.p3
    @addMidpointView image, triangle, triangle.p3, triangle.p1

  addAllMidpointViews: =>
    for view in @midpointViews
      view.remove()
    @midpointViews = []
    @addMidpointViews(null, 0, 0, 0, triangle) for triangle in @model.morpherImage.mesh.triangles

  removeMidpointView: (view) =>
    i = @midpointViews.indexOf view
    if i != -1
      delete @midpointViews.splice i, 1

  splitHandler: (p1, p2) =>
    @splitInProgress = true
    @model.splitEdge p1, p2

  # highlight

  highlightHandler: (point, state) =>
    index = @pointViews.indexOf point
    if index != -1
      @trigger 'highlight', index, state
      return
    index = @midpointViews.indexOf point
    if index != -1
      @trigger 'highlight', index, state, true

  highlightPoint: (index, state, midpoint = false) =>
    unless midpoint
      @pointViews[index].setHighlight state
    else
      @midpointViews[index].setHighlight state

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
    
  renderWeight: =>
    @$('input[name=targetWeight]').val @model.get('weight')

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
    @renderWeight()
    @renderFile()
    @addAllPointViews()
    @addAllMidpointViews()
    this


  # canvas drawing

  draw: =>
    @canvas.width = @canvas.width
    x0 = @model.morpherImage.getX()
    y0 = @model.morpherImage.getY()
    @ctx.drawImage @img, x0, y0 if @img.width > 0
    for triangle in @model.morpherImage.mesh.triangles
      @ctx.beginPath()
      @ctx.moveTo(x0+triangle.p1.x, y0+triangle.p1.y)
      @ctx.lineTo(x0+triangle.p2.x, y0+triangle.p2.y)
      @ctx.lineTo(x0+triangle.p3.x, y0+triangle.p3.y)
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
