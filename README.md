# cl-tbnl-gserver-tmgr
Hunchentoot Gserver based taskmanager

## Some benchmarks

### Multi-threaded (default hunchentoot):
(CCL)
wrk -t4 -c100 -d10 "http://localhost:4242/yo"
Running 10s test @ http://localhost:4242/yo
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    19.60ms   38.20ms 700.72ms   92.76%
    Req/Sec     2.83k   389.81     3.75k    71.50%
  112829 requests in 10.01s, 15.82MB read
  Socket errors: connect 0, read 108, write 0, timeout 0
Requests/sec:  11269.13
Transfer/sec:      1.58MB
(SBCL)
wrk -t4 -c100 -d10 "http://localhost:4242/yo"
Running 10s test @ http://localhost:4242/yo
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    33.63ms   64.77ms 580.44ms   86.79%
    Req/Sec    12.16k    10.56k   54.88k    75.28%
  470142 requests in 10.08s, 65.91MB read
  Socket errors: connect 0, read 85, write 0, timeout 0
Requests/sec:  46635.24
Transfer/sec:      6.54MB

(CCL)
wrk -t4 -c10 -d10 "http://localhost:4242/yo"
Running 10s test @ http://localhost:4242/yo
  4 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   225.58us  110.91us   2.25ms   95.05%
    Req/Sec     9.10k   200.38     9.44k    73.51%
  365861 requests in 10.10s, 51.29MB read
Requests/sec:  36226.08
Transfer/sec:      5.08MB
(SBCL)
wrk -t4 -c10 -d10 "http://localhost:4242/yo"
Running 10s test @ http://localhost:4242/yo
  4 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   233.03us  759.27us  13.93ms   96.07%
    Req/Sec    19.09k   556.09    20.40k    67.33%
  767444 requests in 10.10s, 107.59MB read
Requests/sec:  75961.66
Transfer/sec:     10.65MB
---------- Can't handle ------------
wrk -t16 -c400 -d10 "http://localhost:4242/yo"
Running 10s test @ http://localhost:4242/yo
  16 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    28.71ms   80.52ms 750.72ms   90.82%
    Req/Sec     3.90k     3.99k   32.81k    87.00%
  571817 requests in 10.10s, 80.66MB read
  Socket errors: connect 165, read 3371, write 80, timeout 1
  Non-2xx or 3xx responses: 2972
Requests/sec:  56635.62
Transfer/sec:      7.99MB


### gserver (8 workers random order):
(CCL)
wrk -t4 -c100 -d10 "http://localhost:4242/yo"
Running 10s test @ http://localhost:4242/yo
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   205.72us   96.43us   1.75ms   97.49%
    Req/Sec    11.38k     4.73k   18.49k    62.00%
  339612 requests in 10.08s, 47.61MB read
  Socket errors: connect 0, read 48, write 0, timeout 1
Requests/sec:  33698.51
Transfer/sec:      4.72MB
(SBCL)
wrk -t4 -c100 -d10 "http://localhost:4242/yo"
Running 10s test @ http://localhost:4242/yo
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   163.33us    1.37ms 101.71ms   99.26%
    Req/Sec    18.52k    11.51k   40.69k    74.25%
  737186 requests in 10.01s, 103.35MB read
  Socket errors: connect 0, read 112, write 0, timeout 0
Requests/sec:  73647.69
Transfer/sec:     10.32MB

(CCL)
wrk -t4 -c10 -d10 "http://localhost:4242/yo"
Running 10s test @ http://localhost:4242/yo
  4 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   170.32us   81.20us   4.30ms   98.24%
    Req/Sec     7.83k     2.75k   12.07k    66.00%
  233702 requests in 10.04s, 32.76MB read
Requests/sec:  23277.04
Transfer/sec:      3.26MB
(SBCL)
wrk -t4 -c10 -d10 "http://localhost:4242/yo"
Running 10s test @ http://localhost:4242/yo
  4 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   457.93us    3.52ms  96.69ms   97.21%
    Req/Sec    19.16k     6.69k   27.72k    58.75%
  763236 requests in 10.01s, 107.00MB read
Requests/sec:  76257.12
Transfer/sec:     10.69MB
---------------------------------------
wrk -t16 -c400 -d10 "http://localhost:4242/yo"
Running 10s test @ http://localhost:4242/yo
  16 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   106.74us  651.85us  98.07ms   99.86%
    Req/Sec    19.41k    16.96k   70.09k    74.31%
  774766 requests in 10.10s, 108.61MB read
  Socket errors: connect 165, read 242, write 0, timeout 0
Requests/sec:  76711.31
Transfer/sec:     10.75MB

