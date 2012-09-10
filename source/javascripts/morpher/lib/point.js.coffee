class MorpherJS.Point extends MorpherJS.EventDispatcher
  x: 0
  y: 0

  constructor: (x, y) ->
    @x = x
    @y = y
    

  # getters & setters

  getX: =>
    @x
  setX: (x, params = {}) =>
    unless @x == x
      @x = Math.round x
      @trigger 'change:x change' unless params.silent

  getY: =>
    @y
  setY: (y, params = {}) =>
    unless @y == y
      @y = Math.round y
      @trigger 'change:y change' unless params.silent

  # public methods

  remove: =>
    @trigger 'remove', this

  distanceTo: (point) =>
    Math.sqrt(Math.pow(point.x-@x, 2) + Math.pow(point.y-@y, 2))


  # JSON

  toJSON: =>
    {x: @x, y: @y}

  fromJSON: (json = {}, params = {}) =>
    @reset() if params.hard
    @setX x, params
    @setY y, params

  reset: =>
    @x = null
    @y = null
      

  # old

#  clone: =>
#    new MorpherJS.Point(@x, @y)

#  transform: (matrix) =>
#    tmpX = matrix.get(0,0)*@x + matrix.get(0,1)*@y + matrix.get(0,2)
#    tmpY = matrix.get(1,0)*@x + matrix.get(1,1)*@y + matrix.get(1,2)
#    @x = tmpX
#    @y = tmpY

#  visualize: (el) =>
#    dot = new MorpherJS.DraggableDot()
#    dot.bind 'change', @changeHandler
#    dot.bind 'select', @selectHandler
#    dot.bind 'deselect', @deselectHandler
#    dot.el.appendTo(el)
#    @dots.push dot
#    @updateDots()

#  removeVisualization: =>
#    for dot in @dots
#      dot.remove()
#    @dots = []

#  updateDots: =>
#    for dot in @dots
#      dot.moveTo(@x, @y)

#  changeHandler: (target) =>
#    @x = target.x
#    @y = target.y
#    @updateDots()
#    @trigger 'change', this

#  selectHandler: (target) =>
#    @trigger 'select', this
#  deselectHandler: (target) =>
#    @trigger 'deselect', this
