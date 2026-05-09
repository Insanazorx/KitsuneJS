let item = 0;
let values = [1, 2, 3];
for await (item of values) {
  item = item;
}
