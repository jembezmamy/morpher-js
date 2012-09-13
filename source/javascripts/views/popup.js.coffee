Gui.Views.Popup =
  popup: null
  
  getInstance: ->
    unless @popup?
      @popup = new Gui.Views.PopupWindow()
      $('body').append @popup.render().el
    @popup

  show: (template, params = {})->
    @getInstance().show(template, params)
    @popup


class Gui.Views.PopupWindow extends Backbone.View
  className: 'popup'
  template: JST["templates/popup"]

  events:
    'click [data-action=close]' : 'hide'

  show: (template, params = {})=>
    if template?
      @$('.window > .content').html JST[template](params)
    @$el.addClass 'visible'

  hide: =>
    @$el.removeClass 'visible'

  render: =>
    @$el.html @template()
    this
