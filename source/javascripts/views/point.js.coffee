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

  dragHandler: (e) =>
    switch e.type
      when 'mousedown'
        @delta =
          x: e.pageX - @$el.position().left,
          y: e.pageY - @$el.position().top
        $('body').addClass 'drag'
        $(window).on 'mousemove mouseup', @dragHandler
        @trigger 'drag:start'
      when 'mousemove'
        @model.setX e.pageX - @delta.x
        @model.setY e.pageY - @delta.y
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

  
