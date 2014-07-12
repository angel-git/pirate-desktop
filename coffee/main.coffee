# Load native UI library
gui = require('nw.gui')

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

# start init
$ ->
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
  CalendarDownloader.getSeriesDate dateToSeach, (response) ->
    $('#series-list').removeClass('loading-serie')
    $('#current-day').html(today.getDate())
    serieHtml = ''
    for serie in response
      serieHtml += '<div class="serie-wrapper wrapper ' + serie.className + '" data-episode="' + serie.serie + ' ' + serie.episode + '">'
      serieHtml += '<div class="serie-title">' + serie.serie + '</div>'
      serieHtml += '<div class="serie-ep">' + serie.episode + '</div>'
      serieHtml += '</div>'
    $("#series-list").html(serieHtml)
    $("#series-list .serie-wrapper").click((event)->
      searchDataEpisode($(event.target))
    )





@searchDataEpisode = (target) ->
  $("#torrents-content").html('')
  $('#torrents-content').addClass('loading')
  if (target.hasClass("serie-wrapper"))
    episode = target.attr("data-episode")
    PirateDownloader.getTorrents episode, (response) ->
      $('#torrents-content').removeClass('loading')
      if response.length < 1
        alert('no result')
      else
        torrentsHtml = '<div class="torrents-list">'
        for torrent in response
          torrentsHtml += '<div class="torrent-wrapper wrapper">'
          torrentsHtml +=   '<span class="torrent-text">'
          torrentsHtml +=     '<div class="torrent-title"><a href="' +torrent.link + '">' + torrent.name + '</a></div>'
          torrentsHtml +=     '<div class="torrent-info">' + torrent.desc + '</div>'
          torrentsHtml +=   '</span>'
          torrentsHtml +=   '<span class="torrent-numbers">'
          torrentsHtml +=     '<span class="torrent-seed">' + torrent.seeds + '</span>'
          torrentsHtml +=     '<span class="torrent-leed">' + torrent.leeds + '</span>'
          torrentsHtml +=   '</span>'
          torrentsHtml += '</div>'
        torrentsHtml += '</div>'
      $("#torrents-content").html(torrentsHtml)
  else
    searchDataEpisode(target.parent())
