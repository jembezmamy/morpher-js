class Morpher.Mesh extends Morpher.EventDispatcher
  points: null
  triangles: null
  selected: null

  parent: null
  canvas: null
  
  source: null
  destination: null
  destinationParent: null

  constructor: (params = {}) ->
    @points = []
    @triangles = []
    @selected = []

  bindWith: (mesh) =>
    mesh.bind('point:add point:remove', @pointHandler)
    mesh.bind('triangle:add', @triangleHandler)

  addTriangle: (p1, p2, p3) =>
    triangle = new Morpher.Triangle(p1, p2, p3)
    @triangles.push triangle
    @trigger 'triangle:add', @points.indexOf(p1), @points.indexOf(p2), @points.indexOf(p3)
    if @destination?
      triangle.draw(@source, @destinationParent, @destination.getTriangle(@triangles.length-1))
    triangle

  getTriangle: (i) =>
    @triangles[i]

  removeTriangle: (t) =>
    i = @triangles.indexOf(t)
    @triangles.splice i, 1 if i != -1

  addPoint: =>
    if arguments.length > 1
      p = new Morpher.Point(arguments[0], arguments[1])
    else
      p = arguments[0]
    p.bind 'select', @selectHandler
    p.bind 'deselect', @deselectHandler
    p.bind 'change', @changeHandler
    p.visualize(@parent, true)
    @points.push p
    @trigger 'point:add', p.x, p.y
    p

  removePoint: (p) =>
    i = @points.indexOf(p)
    @points.splice i, 1 if i != -1
    p.removeVisualization()
    triangles = []
    for t in @triangles
      triangles.push t if t.hasPoint(p)
    for t in triangles
      @removeTriangle(t)
    @redraw()
    @trigger 'point:remove', i

  visualize: (parent, editable = false) =>
    @parent = $(parent)
    @canvas = $('<canvas />').attr
      width: @parent.width(),
      height: @parent.height()
    .appendTo(@parent)
    if editable
      @canvas.click @mouseHandler
      $(window).bind 'keydown keyup', @keyboardHandler

  draw: (sourceBitmap, destinationParent, destinationMesh) =>
    @source = sourceBitmap
    @destinationParent = destinationParent
    @destination = destinationMesh
    for t, i in @triangles
      t.draw(@source, @destinationParent, @destination.getTriangle(i))

  redraw: =>
    ctx = @canvas.get(0).getContext('2d')
    @canvas.get(0).width = @canvas.get(0).width
    
    ctx.beginPath()
    ctx.lineWidth = 1
    ctx.strokeStyle = 'black'
    for t in @triangles
      ctx.moveTo t.p1.x, t.p1.y
      ctx.lineTo t.p2.x, t.p2.y
      ctx.lineTo t.p3.x, t.p3.y
      ctx.lineTo t.p1.x, t.p1.y
    ctx.stroke()

    ctx.beginPath()
    ctx.lineWidth = 3
    ctx.strokeStyle = 'red'
    for p, i in @selected
      method = if i then 'lineTo' else 'moveTo'
      ctx[method] p.x, p.y
    ctx.stroke()
    

  mouseHandler: (e) =>
    mouse = 
      x: e.pageX - @parent.offset().left,
      y: e.pageY - @parent.offset().top
    @addPoint(mouse.x, mouse.y)

  selectHandler: (target) =>
    @selected.push target
    if @selected.length == 3
      @addTriangle.apply this, @selected
      @parent.find('.selected').removeClass('selected')
      @selected = []
    @redraw()
  deselectHandler: (target) =>
    i = @selected.indexOf target
    @selected.splice i, 1 if i != -1
    @redraw()
  changeHandler: (target) =>
    @redraw()

  keyboardHandler: (e) =>
    switch e.keyCode
      when 17
        if e.type == 'keydown'
          @parent.addClass('select-mode')
        else
          @parent.removeClass('select-mode')
      when 46
        @removePoint(@selected.pop()) while @selected.length

  pointHandler: (args...) =>
    if args.length == 1
      @removePoint(@points[args[0]])
    else
      @addPoint(args[0], args[1])

  triangleHandler: (i, j, k) =>
    @addTriangle(@points[i], @points[j], @points[k])
    @redraw()
