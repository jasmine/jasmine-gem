(function() {
  /**
   * Wait until the test condition is true or a timeout occurs. Useful for waiting
   * on a server response or for a ui change (fadeIn, etc.) to occur.
   *
   * @param testFx javascript condition that evaluates to a boolean,
   * it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
   * as a callback function.
   * @param onReady what to do when testFx condition is fulfilled,
   * it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
   * as a callback function.
   */
  function waitFor(testFx, onReady) {
    var condition = false,
    interval = setInterval(function() {
      if (!condition) {
        condition = (typeof(testFx) === 'string' ? eval(testFx) : testFx());
      } else {
        if (typeof(onReady) === 'string') {
          eval(onReady);
        } else {
          onReady();
        }
        clearInterval(interval);
      }
    }, 100);
  }

  var url = phantom.args[0];
  var batchSize = parseInt(phantom.args[1], 10);
  var page = require('webpage').create();

  page.open(url, function(status) {
    if (status !== "success") {
      phantom.exit(1);
    } else {
      waitFor(function() {
        return page.evaluate(function() {
          return jsApiReporter && jsApiReporter.finished
        });
      }, function() {
        var index = 0, results;
        do {
          results = page.evaluate(function(index, batchSize) {
            return jsApiReporter.specResults(index, batchSize)
          }, index, batchSize);
          console.log(JSON.stringify(results));
          index += batchSize;
        } while (results && results.length == batchSize)
        phantom.exit(0);
      });
    }
  });
}).call(this);
