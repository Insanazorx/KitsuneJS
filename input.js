let c = 31 + 31

function foo() {
    if (c > 50) {
        c = c - 10;
    } else {
        print("c is less than or equal to 50");
    }
    
}







/*
var global1 = 10

function outerfunc() {
    let outer1 = 5;
    let outer2 = 10 + global1;
    outer1 = outer2
    function middlerfunc() {
        console.log("Middle function called");
        var middle1 = outer1 * 2;
        middle1 = middle1 + 5 + global1;
        function innerfunc() {
            var inner1 = middle1 + 3;
            inner1 = inner1 * 2;
            let inner2 = middle1 + outer2 + global1;
        }
    }
}
*/
 