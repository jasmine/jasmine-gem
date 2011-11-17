// in spec/javascripts/phantom-js-runner.js:
if (phantom.state.length === 0) {
  if (phantom.args.length !== 1) {
    console.log('Usage: run-jasmine.js URL');
    phantom.exit();
  } else {
    phantom.state = 'run-jasmine';
    phantom.open(phantom.args[0]);
  }
} else {
  window.setInterval(function () {
    if (document.body.querySelector('.finished-at')) {
      console.log(document.body.querySelector('.description').innerText);
      var failed = document.body.querySelectorAll('div.jasmine_reporter .spec.failed .description');
      for (var i = 0, desc; desc = failed[i]; i++) {
        var message = [desc.title, desc.nextSibling.querySelector('.resultMessage.fail').innerText];
        console.log(message.join(' => '));
      }
      phantom.exit(failed.length);
    }
  }, 100);
}


