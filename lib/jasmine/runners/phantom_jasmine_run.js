(function() {
  var url = phantom.args[0];
  var showConsoleLog = phantom.args[1] === 'true';
  var configScript = phantom.args[2];
  var page = require('webpage').create();

  if (configScript !== '') {
    require(configScript).configure(page);
  }

  page.onCallback = function(data) {
    if(data.state === 'specDone') {
      console.log('jasmine_result' + JSON.stringify([].concat(data.results)));
    } else {
      phantom.exit(0);
    }
  };

  if (showConsoleLog) {
    page.onConsoleMessage = function(message) {
      console.log(message);
    };
  }

  page.open(url, function(status) {
    if (status !== "success") {
      phantom.exit(1);
    }
  });
}).call(this);
