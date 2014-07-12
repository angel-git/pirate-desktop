request = require('request');

{parseString} = require('xml2js')

calendarContent = ''

@getSeriesDate = (dateToSearch, success) ->
  month = dateToSearch.getMonth() + 1
  todayFormat = '#d_' + dateToSearch.getDate() + '_' + month + '_' + dateToSearch.getFullYear()
  if calendarContent is ''
    request.get 'http://www.pogdesign.co.uk/cat', (error, response, body) ->
      if response.statusCode == 200
        calendarContent = body
        parseCalendar(todayFormat, success)
      else
        alert('something went wrong with the calendar connection: ' + response.statusCode)
        calendarContent = ''
  else
    parseCalendar(todayFormat, success)

@parseCalendar = (todayFormat, success) ->
  divs = $(calendarContent).find(todayFormat).find('div');
  serieList = []
  for div in divs
    jdiv = $(div)
    className = jdiv.find('p')[0].className
    as = jdiv.find('a')
    serieTitleString = as[0].text
    serieEpisode = as[1]
    serieEpisodeString = parseEpisode(serieEpisode.text)
    serie = new Serie(serieTitleString, serieEpisodeString, className)
    serieList.push(serie)
  success? serieList

@getTorrents = (episode, success) ->
  episode = episode.replace /\s/g,'%20'
  urlRequest = 'http://thepiratebay.se/search/'+ episode + '/0/7/0'
  request.get urlRequest, (error, response, body) ->
    searchResult = $(body).find('#searchResult').find('tr')
    torrentList = []
    if searchResult.length == 0
      success? torrentList
    else
      for result in [1..searchResult.length - 1]
        jresult = $(searchResult[result])
        detLink = $(jresult.find(".detName")[0]).find(".detLink")[0]
        name = detLink.text
        link = $(jresult.find("a[href^=magnet]")[0]).attr("href")
        desc = $(jresult.find("td")[1]).find(".detDesc").eq(0).text()
        seeds = jresult.find("td").eq(2).text()
        leeds = jresult.find("td").eq(3).text()
        torrent = new Torrent(name, leeds, seeds, link, desc)
        torrentList.push(torrent)
      success? torrentList


@getSerieInfo = (serieTitle, success) ->
  urlRequest = 'http://www.imdb.com/find?q=' + serieTitle + '&s=tt'
  request.get urlRequest, (error, response, body) ->
    searchResult = $(body).find('#main .findList .findResult img').attr('src')
    success? searchResult



@parseEpisode = (epInput) ->
  episode = ''
  splitted = epInput.split(' ')
  season = splitted[1]
  ep = splitted[4]
  if season.length < 2
    episode += 's0' + season
  else
    episode += 's' + season
  if ep.length < 2
    episode += 'e0' + ep
  else
    episode += 'e' + ep
  return episode