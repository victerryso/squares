root = exports ? this

newColor = ->
  color = ''
  until color.length == 7
    color = '#' + _.random(16777215).toString(16)
  color

root.round = 1
root.rows  = 2
root.cols  = 2
root.start = new Date
root.times = []
root.color = newColor()

Template.home.helpers
  round: ->
    round

  rows: ->
    i = 0
    array = []
    while i < rows
      array.push i
      i++

Template.row.helpers
  cols: ->
    i = 0
    array = []
    while i < cols
      array.push i
      i++

Template.square.helpers
  color: -> color

Template.home.rendered = ->
  root.timer = new Date

  square = _.sample $('.square')
  square.id = 'square'
  color = $(square).css 'background-color'

  regex = /rgb\((\d{1,3}), (\d{1,3}), (\d{1,3})\)/
  matches = regex.exec color

  matches = _.map matches, (match) ->
    number = parseInt match
    if number < 50
      number = number + _.random(50)
    else if number > 200
      number = number - _.random(50)
    else
      number = number + _.random(-50, 50)

  rgb = "rgb(#{matches[1]}, #{matches[2]}, #{matches[3]})"
  $(square).css 'background-color', rgb

  bounce = -> $(square).toggleClass('animated bounce')
  if root.repeatBounce then clearInterval(repeatBounce)
  root.repeatBounce = setInterval(bounce, 5000)

  # Stopwatch
  unless Session.get('startTime') then Session.set('startTime', new Date)
  startTime = Session.get('startTime') || new Date

  startWatch = ->
    time = new Date
    difference = time - startTime

    m = parseInt(difference / 60000)
    s = parseInt(difference / 1000)
    ms = parseInt(difference % 1000)

    until s < 60  then s = s - 60
    until "#{m}".length is 2 then m = '0' + m
    until "#{s}".length is 2 then s = '0' + s
    until "#{ms}".length is 3 then ms = '0' + ms

    $('.stopwatch').text(m + ':' + s + ':' + ms)

  if root.stopwatch then clearInterval(stopwatch)
  root.stopwatch = setInterval(startWatch, 5)

Template.home.events
  'click #square': (event, template) ->

    setTimes = ->
      time = new Date - timer
      times.push (Math.ceil time) / 1000
      root.fastest = _.min times
      total = _.reduce(times, ((memo, num) -> memo + num), 0)
      root.average = (Math.ceil 1000 * total / times.length) / 1000

    refreshTemplate = ->
      root.round++
      root.color = newColor()
      $('body').empty()
      Blaze.render(Template.home, $('body')[0])

    width = $(window).width()
    maxRounds = 10

    switch
      when width < 386 then maxRounds = 6
      when width < 459 then maxRounds = 8
      when width < 532 then maxRounds = 10

    if round < maxRounds
      if rows == cols then rows++ else cols++
      setTimes()
      refreshTemplate()
    else
      setTimes()
      finish = (new Date - start) / 1000

      root.round = 0
      root.rows  = 2
      root.cols  = 2
      root.timer = []
      root.start = new Date
      Session.set('startTime', new Date)
      root.color = newColor()

      refreshTemplate()
      swal("Good job!", "Fastest Time: #{fastest}s\nAverage Time: #{average}s\nTotal Time: #{finish}s", "success")

