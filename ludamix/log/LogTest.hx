package ludamix.log;

class LogTest {

    public static function run() {

        var l = new Log();

        var hello_idx = l.addString("hello");
        if (l.addString("hello") != hello_idx) throw "string reuse failed";

        var tester = new Array<Array<Int>>();
        for (n in 0...1000) {
            var d = [Std.int(Math.random()*10000),Std.int(Math.random()*10000),Std.int(Math.random()*10000),Std.int(Math.random()*10000)];
            tester.push(d);
            l.log(d[0],d[1],d[2],d[3]);
        }
        for (i in 0...tester.length) {
            var t = tester[i];
            var d0 = l.time(i);
            var d1 = l.type(i);
            var d2 = l.v0(i);
            var d3 = l.v1(i);
            if (d0 != t[0] || d1 != t[1] || d2 != t[2] || d3 != t[3]) {
                throw "failed: $d0 $d1 $d2 $d3 != $t";
            }
        }

    }

}