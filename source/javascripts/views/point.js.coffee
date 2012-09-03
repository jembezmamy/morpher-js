class Gui.Views.Point extends Backbone.View
  className: 'point'

  delta: null

  events:
    'mousedown' : 'dragHandler'
    'contextmenu' : 'destroy'

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

  destroy: (e) =>
    e.preventDefault()
    @model.remove()

  render: =>
    @$el.css
      left: "#{@model.getX()}px",
      top: "#{@model.getY()}px"
    this

  
