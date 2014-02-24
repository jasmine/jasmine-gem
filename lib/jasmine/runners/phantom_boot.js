function PhantomReporter() {
  this.jasmineDone = function() {
    window.callPhantom({ state: 'jasmineDone'  });
  };

  this.specDone = function(results) {
    window.callPhantom({ state: 'specDone', results: results});
  };
}

jasmine.getEnv().addReporter(new PhantomReporter());
