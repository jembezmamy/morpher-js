class Gui.Models.Image extends Backbone.Model
  morpherImage: null

  constructor: ->
    @morpherImage = new MorpherJS.Image()
    super

  set: (attr) =>
    if attr.file?
      @morpherImage.setSrc attr.file
    super

  addPoint: (x, y) =>
    @morpherImage.addPoint x: x, y: y

  splitEdge: (p1, p2) =>
    @morpherImage.splitEdge p1, p2
  

class Gui.Collections.Images extends Backbone.Collection
  model: Gui.Models.Image
