class Gui.Views.Tile extends Backbone.View
  className: 'tile'
  
  setPosition: (x, y, width, height) =>
    @$el.css
      left: "#{x*100}%",
      top: "#{y*100}%",
      width: "#{width*100}%",
      height: "#{height*100}%"

  render: =>
    @$pane = $('<div />').addClass('pane').appendTo @el
    this
