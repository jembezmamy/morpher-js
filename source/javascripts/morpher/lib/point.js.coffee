class Morpher.Point extends Morpher.EventDispatcher
  x: 0
  y: 0
  dots: null

  constructor: (x, y) ->
    @dots = []
    @x = x
    @y = y

  clone: =>
    new Morpher.Point(@x, @y)

  distanceTo: (point) =>
    Math.sqrt(Math.pow(point.x-@x, 2) + Math.pow(point.y-@y, 2))

  transform: (matrix) =>
    tmpX = matrix.get(0,0)*@x + matrix.get(0,1)*@y + matrix.get(0,2)
    tmpY = matrix.get(1,0)*@x + matrix.get(1,1)*@y + matrix.get(1,2)
    @x = tmpX
    @y = tmpY

  visualize: (el) =>
    dot = new Morpher.DraggableDot()
    dot.bind 'change', @changeHandler
    dot.bind 'select', @selectHandler
    dot.bind 'deselect', @deselectHandler
    dot.el.appendTo(el)
    @dots.push dot
    @updateDots()

  removeVisualization: =>
    for dot in @dots
      dot.remove()
    @dots = []

  updateDots: =>
    for dot in @dots
      dot.moveTo(@x, @y)

  changeHandler: (target) =>
    @x = target.x
    @y = target.y
    @updateDots()
    @trigger 'change', this

  selectHandler: (target) =>
    @trigger 'select', this
  deselectHandler: (target) =>
    @trigger 'deselect', this
