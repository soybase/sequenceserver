/* */ 
var $def = require('./$.def'),
    exp = Math.exp;
$def($def.S, 'Math', {cosh: function cosh(x) {
    return (exp(x = +x) + exp(-x)) / 2;
  }});
