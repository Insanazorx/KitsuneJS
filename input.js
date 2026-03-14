function innerBlockFn(p = 1, [x, y] = [2, 3]) {
    var innerVar = 0;
    var innerVar2 = 0;
    const innerConst = 0;
    return p + x + y + innerVar + innerVar2 + innerConst;
}

let a = 1;