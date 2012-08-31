class MorpherJS.DraggableDot extends Backbone.Model
  el: null
  x: 0
  y: 0
  delta: null

  constructor: () ->
    @delta = {x: 0, y: 0}
    @el = $('<div />').addClass('dot').bind('mousedown', @mouseHandler)

  moveTo: (x, y) =>
    @x = x
    @y = y
    @update()

  remove: =>
    @el.remove()

  update: =>
    @el.css left: @x, top: @y

  mouseHandler: (e) =>
    e.preventDefault()
    if e.ctrlKey
      if @el.is('.selected')
        @el.removeClass('selected')
        @trigger 'deselect', this
      else
        @el.addClass('selected')
        @trigger 'select', this
    else
      switch e.type
        when 'mousedown'
          @delta.x = e.pageX - @el.position().left 
          @delta.y = e.pageY - @el.position().top
          $(window).bind('mousemove mouseup', @mouseHandler)
        when 'mousemove'
          @moveTo e.pageX-@delta.x, e.pageY-@delta.y
          @trigger 'change', this
        when 'mouseup'
          $(window).unbind('mousemove mouseup', @mouseHandler)
