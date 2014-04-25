jsApiReporter.jasmineDone = function () {
  window.callPhantom({state: 'jasmineDone'});
}

jsApiReporter.specDone = function (results) {
  window.callPhantom({state: 'specDone', results: results});
}