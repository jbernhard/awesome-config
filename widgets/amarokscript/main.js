//
// Awesome Amarok script
//


Importer.loadQtBinding("qt.core")


// variable for calling external commands
var process = new QProcess()


// function to call external script which updates the awesome widget
function widget(cmd)
{
	process.kill()
	process = new QProcess()
  process.start(Amarok.Info.scriptPath()+"/widget.sh", [cmd])
}


// updates all metadata
function update()
{
  var title = Amarok.Engine.currentTrack().title
  var cover = Amarok.Engine.currentTrack().imageUrl.replace('file://', '')
  var artist = Amarok.Engine.currentTrack().artist
  var genre = Amarok.Engine.currentTrack().genre
  var album = Amarok.Engine.currentTrack().album
  var year = Amarok.Engine.currentTrack().year
  
  widget('amarok.set("' + title + '","' + cover + '","' + artist + '","' + genre + '","' + album + '","' + year + '")')
}


// puts brackets around title to indicate pause
function pause()
{
  widget('amarok.pause()')
}


// track change
function onTrackChange() 
{
  if (Amarok.Engine.currentTrack().title == '')
  {
    onTrackFinished()
  } else {
    update()
  }
}


// pause
function onTrackPlayPause(paused)
{
	if (paused) {
    pause()
	}
	else {
    update()
	}
}


// stop
function onTrackFinished()
{
  widget('amarok.stop()')
}


// initialize on startup
onTrackChange()

// call functions on appropriate signals
Amarok.Engine.trackPlayPause.connect(onTrackPlayPause)
Amarok.Engine.trackChanged.connect(onTrackChange)
Amarok.Engine.trackFinished.connect(onTrackFinished)

// clean up before exit
QCoreApplication.instance().aboutToQuit.connect(onTrackFinished)
