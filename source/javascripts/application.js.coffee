#= require ./vendor/jquery
#= require ./vendor/underscore
#= require ./vendor/backbone
#= require_tree ./vendor
#= require_self
#= require_tree ./models
#= require_tree ./templates
#= require_tree ./views

window.Gui =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {
    Popups: {}
  }

$ =>
  if $('body').is('.gui')
    gui = new Gui.Views.Main()
    $('body').append(gui.el)
