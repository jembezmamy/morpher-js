# Based on Backbone.Events: http://backbonejs.org/

class MorpherJS.EventDispatcher

  on: (events, callback, context) =>
    ev = null
    events = events.split(/\s+/)
    calls = @_callbacks || (@_callbacks = {})
    while ev = events.shift()
      list  = calls[ev] || (calls[ev] = {})
      tail = list.tail || (list.tail = list.next = {})
      tail.callback = callback
      tail.context = context
      list.tail = tail.next = {}
    this
  
  off: (events, callback, context) =>
    ev = calls = node = null
    unless events
      delete @_callbacks
    else if calls = @_callbacks
      events = events.split(/\s+/)
      while ev = events.shift()
        node = calls[ev]
        delete calls[ev]
        continue if !callback || !node
        while (node = node.next) && node.next
          continue if node.callback is callback && (!context || node.context is context)
          @bind(ev, node.callback, node.context)
    this
  
  trigger: (events) =>
    event = node = calls = tail = args = all = rest = null
    return this if !(calls = this._callbacks)
    all = calls['all']
    (events = events.split(/\s+/)).push(null)
    
    while event = events.shift()
      events.push({next: all.next, tail: all.tail, event: event}) if all
      continue unless node = calls[event]
      events.push({next: node.next, tail: node.tail})
    
    rest = Array.prototype.slice.call(arguments, 1)
    while node = events.pop()
      tail = node.tail
      args = if node.event then [node.event].concat(rest) else rest
      while (node = node.next) isnt tail
        node.callback.apply(node.context || this, args)
    this

