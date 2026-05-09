var i = 0;

function increment(a) {
  while (i < 10) {
    a = a + 1;
  }
  console.log(i + a);
  return i;
}

function main() {
  const some = 5;
  if (i < 10) {
    i = i + 1;
  } else if (i < 20) {
    return increment(some);
  } else {
    var result = increment(some) + 1;
    console.log(result);
  }
  return 0;
}

for (var j = 0; j < 3; j = j + 1) {
  main();
}












 