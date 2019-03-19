/**
 * Iterates the keys and values of an object.  Object.keys is used to extract the keys.
 * @param object The object to iterate
 * @param fn (value,key)=>{}
 */
function objectForEach(object, fn) {
  Object.keys(object).forEach(key => {
    fn(object[key],key, object)
  })
}

function remove_jquery_elementes(object) {
  objectForEach(object, (value, key, obj) => {
    if (value instanceof jQuery) {
      obj[key] = value.toArray()
    } else if (value instanceof Object){
      remove_jquery_elementes(value)
    } else if (value instanceof Array){
      for (var i = value.length - 1; i >= 0; i--) {
        remove_jquery_elementes(value[i]);
      }
    }
  })

  return object;
}

function json_stringify_result(object){
  let result_string;

  try {
    result_string = JSON.stringify([].concat(object));
  }
  catch(error) {
    if (window.jQuery !== undefined) {
      result_string = JSON.stringify([].concat(remove_jquery_elementes(object)));
    }
  }

  return result_string;
}

function ChromeHeadlessReporter() {
  this.jasmineDone = function(details) {
    console.log('jasmine_done', JSON.stringify(details));
  };

  this.specDone = function(results) {
    console.log('jasmine_spec_result', json_stringify_result(results));
  };

  this.suiteDone = function(results) {
    console.log('jasmine_suite_result',json_stringify_result(results));
  };
}

jasmine.getEnv().addReporter(new ChromeHeadlessReporter());
