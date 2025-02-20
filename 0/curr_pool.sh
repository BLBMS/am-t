
Starting on stratum+tcp://pool.verus.io:9998

Swith to stratum pool 1 

Reconnecting to 
Connected to

[2025-02-20 23:02:22] Starting on stratum+tcp://xxx.verus.io:9998
[2025-02-20 23:02:22] 8 miner threads started, using 'verus' algorithm.
[2025-02-20 23:02:22] Stratum connection failed: Could not resolve host: xxx.verus.io
[2025-02-20 23:02:22] ...retry after 10 seconds
[2025-02-20 23:02:23] API open in full access mode to 192.168.100.0/18 on port 4068
[2025-02-20 23:02:32] Stratum connection failed: Could not resolve host: xxx.verus.io
[2025-02-20 23:02:32] Stratum connect timeout, failover...
[2025-02-20 23:02:32] Switch to stratum pool 1: verus
[2025-02-20 23:02:33] Stratum difficulty set to 16383.8
[2025-02-20 23:02:35] CPU T3: Verus Hashing. (null), 253.90 kH/s
[2025-02-20 23:02:35] accepted: 1/1 (diff 53312.202), 253.90 kH/s yes!




./ccminer -c config.json --log-level 2 | tee /data/data/com.termux/files/home/ccminer_output.log

./ccminer -c config.json --log-level 2 | tee /data/data/com.termux/files/home/ccminer_output.log


  "api-allow": "192.168.100.0/18",
  "api-bind": "0.0.0.0:4068",
  "log-file": "/data/data/com.termux/files/home/logfile.log",
  "log-level": 2
}
