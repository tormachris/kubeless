module.exports = {
  handler: (event, context) => {
    num=event.data;
    if (num == 1) return "Not Prime";
  num += 2;

  var upper = Math.sqrt(num);
  var sieve = new Array(num)
    .join(',').split(',') // get values for map to work
    .map(function(){ return "Prime" });
  
  for (var i = 2; i <= num; i++) {
    if (sieve[i]) {
      for (var j = i * i; j < num; j += i) {
        sieve[j] = false;
      };
    };
  };
if (sieve[num-2]) {
  return "Prime";
  };
  else {
  return "Not Prime";
};
  },
};
