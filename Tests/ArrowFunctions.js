// test-arrow-functions.js
// Arrow function parser stress test

const f1 = x => x;

const f2 = (x) => x;

const f3 = (x, y) => x + y;

const f4 = () => 42;

const f5 = () => {};

const f6 = x => { return x; };

const f7 = (x, y) => {
  const z = x + y;
  return z * 2;
};

const f8 = x => y => x + y;

const f9 = (x, y) => (z) => x + y + z;

const f10 = x => ({ value: x });

const f11 = (x, y) => ({ sum: x + y, diff: x - y });

const f12 = (x = 1) => x;

const f13 = (x, y = 2) => x + y;

const f14 = ({x, y}) => x + y;

const f15 = ([a, b]) => a + b;

const f16 = ({x: a, y: b}) => a + b;

const f17 = ([a, , b]) => a + b;

const f18 = (...args) => args.length;

const f19 = (x, ...rest) => rest[0] + x;

const f20 = ({a = 1, b = 2}) => a + b;

const f21 = ([a = 1, b = 2]) => a + b;

const f22 = ({a, b: {c}}) => a + c;

const f23 = ([a, [b, c]]) => a + b + c;

const f24 = async x => x;

const f25 = async (x, y) => x + y;

const f26 = async ({x, y}) => {
  return x + y;
};

const f27 = x => ({ nested: { value: x } });

const f28 = x => (x ? 1 : 2);

const f29 = x => x ? 1 : 2;

const f30 = x => x + 1 * 2;

const f31 = x => (x + 1) * 2;

const f35 = (x,) => x;

const f36 = (x, y,) => x + y;

const f37 = ({}) => 0;

const f38 = ([]) => 0;

const f39 = ({a, ...rest}) => rest;

const f40 = ([a, ...rest]) => rest;

const f41 = ({a: {b}}) => b;

const f42 = ([{a}, {b}]) => a + b;

const f43 = (x = () => 1) => x();

const f44 = (x = (y => y + 1)) => x(5);

const f45 = x => () => x;

const f46 = () => x => x + 1;

const f47 = (a, b) => ({ arrow: c => a + b + c });

const f48 = a => ({ b: c => ({ d: a + c }) });

const f49 = (a = {x: 1}) => a.x;

const f50 = ({a = () => 1}) => a();

foo(x => x);
foo((x, y) => x + y);
foo(() => {});
foo(({x, y}) => x + y);
foo(([a, b]) => a + b);

bar = x => x;
baz = (x, y) => ({ x, y });

const arr1 = [x => x, y => y + 1, () => 0];

const obj1 = {
  fn: x => x,
  g: (x, y) => x * y,
};

const nested1 = (a) => {
  return (b) => {
    return (c) => a + b + c;
  };
};

const nested2 =
  a =>
  b =>
  c =>
    a + b + c;

const mix1 = (a ? x => x : y => y);

const mix2 = foo ? (x => x + 1) : (y => y + 2);

const mix3 = (x => x)(10);

const mix4 = ((x, y) => x + y)(1, 2);

const mix5 = (x => y => x + y)(1)(2);

const retObj = () => ({ a: 1, b: 2 });

const retParen = () => ((1 + 2));

const withMember = x => x.y;

const withCall = x => x();

const withIndex = x => x[0];

const withNew = x => new Foo(x);

const withAwait = async x => await foo(x);

const withBlockAndInner = x => {
  const inner = y => y + x;
  return inner(5);
};

const tricky1 = (x = (a, b) => a + b) => x(1, 2);

const tricky2 = ({fn = x => x * 2}) => fn(3);

const tricky3 = ([fn = x => x + 10]) => fn(1);

const tricky4 = ({a: fn = x => x + 1}) => fn(5);

const tricky5 = ({a = ({b}) => b}) => a({b: 10});