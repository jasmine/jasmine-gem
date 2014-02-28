(function() {
  var url = phantom.args[0];
  var page = require('webpage').create();

  page.onCallback = function(data) {
    if(data.state === 'specDone') {
      console.log('jasmine_result' + JSON.stringify([].concat(data.results)));
    } else {
      phantom.exit(0);
    }
  };

  page.open(url, function(status) {
    if (status !== "success") {
      phantom.exit(1);
    }
  });
}).call(this);
