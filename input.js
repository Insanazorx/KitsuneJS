
var a = 1;

function outerFn(f,g,h) {
    var outerVar = 0;
    const outerConst = b

    function innerBlockFn(p = 1, {x, z:y}) {
        var innerVar = outerVar + outerConst;
        var innerVar2 = a;
        const innerConst = f+g+h;
        return p + x + y + innerVar + innerVar2 + innerConst;
    }
}
let b = 2;