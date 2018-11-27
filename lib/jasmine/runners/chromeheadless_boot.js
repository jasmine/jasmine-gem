function ChromeHeadlessReporter() {
  this.jasmineDone = function(details) {
    console.log('jasmine_done', JSON.stringify(details));
  };

  this.specDone = function(results) {
    console.log('jasmine_spec_result', JSON.stringify([].concat(results)));
  };

  this.suiteDone = function(results) {
    console.log('jasmine_suite_result',JSON.stringify([].concat(results)));
  };
}

jasmine.getEnv().addReporter(new ChromeHeadlessReporter());
