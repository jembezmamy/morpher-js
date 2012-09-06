class Gui.Views.Midpoint extends Gui.Views.Point
  className: 'midpoint'

  p1: null
  p2: null
  triangles: null

  events:
    'mousedown'     : 'split'
    'mouseover' : 'highlightHandler'
    'mouseout'  : 'highlightHandler'

  initialize: (params = {}) =>
    @triangles = []
    @addTriangle params.triangle
    @p1 = params.p1
    @p2 = params.p2
    @p1.on 'change', @render
    @p2.on 'change', @render

  addTriangle: (triangle) =>
    triangle.on 'remove', @removeHandler
    @triangles.push triangle

  removeHandler: (triangle) =>
    i = @triangles.indexOf triangle
    if i != -1
      delete @triangles.splice i, 1
      if @triangles.length == 0
        @remove()

  remove: =>
    @trigger 'remove', this
    super

  split: =>
    @trigger 'edge:split', @p1, @p2

  render: =>
    x = @p1.x + (@p2.x - @p1.x)/2
    y = @p1.y + (@p2.y - @p1.y)/2
    @$el.css
      left: "#{x}px",
      top: "#{y}px"
    this
    

  
