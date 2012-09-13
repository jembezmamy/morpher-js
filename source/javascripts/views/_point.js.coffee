class Gui.Views.Point extends Backbone.View
  className: 'point'

  delta: null

  events:
    'mousedown'   : 'dragHandler'
    'contextmenu' : 'destroy'
    'mouseover'   : 'highlightHandler'
    'mouseout'    : 'highlightHandler'
    'dblclick'    : 'selectHandler'

  initialize: =>
    @model.on 'change', @render

  startDrag: (x = 0, y = 0)=>
    @delta = 
      x: @$el.offsetParent().offset().left - Math.round(x),
      y: @$el.offsetParent().offset().top - Math.round(y)
    $('body').addClass 'drag'
    $(window).on 'mousemove mouseup', @dragHandler
    @trigger 'drag:start'

  dragHandler: (e) =>
    switch e.type
      when 'mousedown'
        @startDrag -(e.pageX - @$el.offset().left - @$el.width()/2), -(e.pageY - @$el.offset().top - @$el.height()/2)
      when 'mousemove'
        @model.setX Math.round e.pageX - @delta.x
        @model.setY Math.round e.pageY - @delta.y
      when 'mouseup'
        $('body').removeClass 'drag'
        $(window).off 'mousemove mouseup', @dragHandler
        @trigger 'drag:stop'
        @delta = null
        @highlightHandler()

  destroy: (e) =>
    e.preventDefault()
    @model.remove()


  # Highlight

  highlightHandler: (e) =>
    return if @delta?
    if e? && e.type == 'mouseover'
      @trigger 'highlight', this, true
    else
      @trigger 'highlight', this, false

  setHighlight: (highlight) =>
    if highlight
      @$el.addClass 'highlighted'
    else
      @$el.removeClass 'highlighted'

  # Select

  selectHandler: (e) =>
    @trigger 'select', this

  setSelection: (selected) =>
    if selected
      @$el.addClass 'selected'
    else
      @$el.removeClass 'selected'

  # Render

  render: =>
    @$el.css
      left: "#{@model.getX()}px",
      top: "#{@model.getY()}px"
    this

  
