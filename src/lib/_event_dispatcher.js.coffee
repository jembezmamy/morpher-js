# Based on Backbone.Events: http://backbonejs.org/

class MorpherJS.EventDispatcher
  eventSplitter: /\s+/

  on: (events, callback, context) =>
    return this if !callback
    
    events = events.split @eventSplitter
    calls = this._callbacks || (this._callbacks = {})

    while event = events.shift()
      list = calls[event] || (calls[event] = [])
      list.push(callback, context)

    this

    
  off: (events, callback, context) =>
    return this if !(calls = this._callbacks)
    if !(events || callback || context)
      delete this._callbacks
      return this

    events = if events then events.split(@eventSplitter) else _.keys(calls)

    while event = events.shift()
      if !(list = calls[event]) || !(callback || context)
        delete calls[event]
      else
        i = list.length-2
        while i >= 0
          if !(callback && list[i] != callback || context && list[i + 1] != context)
            list.splice(i, 2)
          i -= 2

    this


  trigger: (events) =>
    return this if !(calls = this._callbacks)

    rest = []
    events = events.split(@eventSplitter)

    i = 1
    length = arguments.length
    while i < length
      rest[i - 1] = arguments[i]
      i++

    while event = events.shift()
      all = all.slice() if all = calls.all
      list = list.slice() if list = calls[event]

      if list
        i = 0
        length = list.length
        while i < length
          list[i].apply(list[i + 1] || this, rest)
          i += 2

      if all
        args = [event].concat(rest)
        i = 0
        length = all.length
        while i < length
          all[i].apply(all[i + 1] || this, args)
          i += 2

    this
