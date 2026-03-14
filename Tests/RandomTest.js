let func = function() {
  function test(c,d) {
    let x = 1;
    if (true) {
      let x = ((a,b) => {
        function a(){return 1};
        return 2;
      })(x,this);
      console.log(x);
    }
    console.log((()=>{
        x = 2;
        return x;
      })(a,c)
    );
  }
}