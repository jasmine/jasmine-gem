(function(){
/* @return an object suitable for consumption by jscoverage.html, i.e. in the
 * following format;
 *
 *  { <file> : {
 *      coverage: [<hit_count>, <hit_count>, ...],
 *      source:   [<source_line>, <source_line>, ...]
 *    }
 *  }
 */
window.jasmine.coverageReport = function() {
  /* window._$jscoverage is an array with an added source property
   */
  var rv = {};
  for( var file_name in window._$jscoverage ) {
    var jscov = window._$jscoverage[ file_name ]; 
    var file_report = rv[ file_name ] = {
      coverage: new Array( jscov.length ),
      source:   new Array( jscov.length )
    };
    for( var i=0; i < jscov.length; ++i ) {
      var hit_count = jscov[ i ] !== undefined ? jscov[ i ] : null;

      file_report.coverage[ i ] = hit_count;
      file_report.source[ i ]   = jscov.source[ i ];
    }
  }
  return rv;
};
})();
