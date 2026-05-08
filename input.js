let a = 10
function foo() {
  console.log(a);
}
function bar() {
  let a = 20
  a = a + 1
}

while (a > 0) {
  foo()
  a = a - 1
}










 