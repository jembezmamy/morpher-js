class Gui.Views.Midpoint extends Gui.Views.Point
  className: 'midpoint'

  p1: null
  p2: null

  events:
    'click'     : 'add'
    'mouseover' : 'highlightHandler'
    'mouseout'  : 'highlightHandler'

  initialize: (params = {}) =>
    @p1 = params.p1
    @p2 = params.p2
    @p1.on 'change', @render
    @p2.on 'change', @render

  add: =>

  render: =>
    x = @p1.x + (@p2.x - @p1.x)/2
    y = @p1.y + (@p2.y - @p1.y)/2
    @$el.css
      left: "#{x}px",
      top: "#{y}px"
    this
    

  
