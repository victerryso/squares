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


Template.home.events
  'click #square': (event, template) ->

    setTimes = ->
      time = new Date - timer
      times.push (Math.ceil time) / 1000
      root.fastest = _.min times
      $('#fastest').text(fastest)
      total = _.reduce(times, ((memo, num) -> memo + num), 0)
      length = times.length
      root.average = (Math.ceil 1000 * total / length) / 1000
      $('#average').text(average)

    refreshTemplate = ->
      root.round++
      root.color = newColor()
      $('body').empty()
      Blaze.render(Template.home, $('body')[0])


    if round < 15
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
      root.color = newColor()

      refreshTemplate()
      swal("Good job!", "Fastest Time: #{fastest}s\nAverage Time: #{average}s\nTotal Time: #{finish}s", "success")

