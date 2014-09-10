# Load native UI library
gui = require('nw.gui')

fs = require('fs')

# Get window object (!= $(window))
win = gui.Window.get()

# Debug flag
isDebug = true

# Set the app title (for Windows mostly)
win.title = gui.App.manifest.name + ' ' + gui.App.manifest.version

# Cancel all new windows (Middle clicks / New Tab)
win.on "new-win-policy", (frame, url, policy) ->
  policy.ignore()

# Prevent dragging/dropping files into/outside the window
preventDefault = (e) ->
  e.preventDefault()
window.addEventListener "dragover", preventDefault, false
window.addEventListener "drop", preventDefault, false
window.addEventListener "dragstart", preventDefault, false

today = new Date()
month = today.getMonth()

templates = {}
# start init
$ ->

  #load templates
  serieTemplate = fs.readFileSync "./tpl/serie-list.tpl"
  torrentTemplate = fs.readFileSync "./tpl/torrent-list.tpl"
  templates["serie-list"] = serieTemplate.toString()
  templates["torrent-list"] = torrentTemplate.toString()

  $("#searchButton").focus()

  $("#window-controls .maximize").click(()->
    if !$(this).hasClass("maximized")
      $(this).addClass("maximized")
      win.maximize()
    else
      $(this).removeClass("maximized")
      win.unmaximize()
  )

  $("#window-controls .close").click(()->
    win.close()
  )

  $("#WindowButtons .minimize").click(()->
    win.minimize()
  )

  $(".btn-wrapper .btn-prev").click(() ->
    today.setDate(today.getDate()-1)
    if month == today.getMonth()
      searchSeries(today)
    else
      today.setDate(today.getDate()+1)
  )

  $(".btn-wrapper .btn-next").click(() ->
    today.setDate(today.getDate()+1)
    if month == today.getMonth()
      searchSeries(today)
    else
      today.setDate(today.getDate()-1)
  )


  searchSeries(today)



  true

@searchSeries = (dateToSeach) ->
  $("#series-list").html('')
  $("#series-list").addClass('loading-serie')
  getSeriesDate dateToSeach, (response) ->
    $('#series-list').removeClass('loading-serie')
    $('#current-day').html(today.getDate())
    serieHtml = renderTemplate templates["serie-list"], response
    $("#series-list").html(serieHtml)
    $("#series-list .serie-wrapper").click((event)->
      searchDataEpisode($(event.target))
    )





@searchDataEpisode = (target) ->
  $('#torrents-content').addClass('loading')
  if (target.hasClass("serie-wrapper"))
    episode = target.attr("data-episode")
    getTorrents episode, (response) ->
      $('#torrents-content').removeClass('loading')
      if response.length < 1
        $("#torrent-body").html('')
        alert('no result')
      else
        torrentsHtml = renderTemplate templates["torrent-list"], response
      $("#torrent-body").html(torrentsHtml)

    serieTitle = target.attr('data-serie')
    $('#serie-title').html(serieTitle)
    $('#serie-cover').attr('src','')
    getSerieInfo serieTitle, (response) ->
      $('#serie-cover').attr('src',response)
  else
    searchDataEpisode(target.parent())
