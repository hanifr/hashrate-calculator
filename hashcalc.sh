# calculating port

LSCPU=`lscpu`
CPU_SOCKETS=`echo "$LSCPU" | grep "^Socket(s):" | cut -d':' -f2 | sed "s/^[ \t]*//"`
if [ -z $CPU_SOCKETS ]; then
  echo "WARNING: Can't get CPU sockets from lscpu output"
  export CPU_SOCKETS=1
fi
CPU_CORES_PER_SOCKET=`echo "$LSCPU" | grep "^Core(s) per socket:" | cut -d':' -f2 | sed "s/^[ \t]*//"`
if [ -z "$CPU_CORES_PER_SOCKET" ]; then
  echo "WARNING: Can't get CPU cores per socket from lscpu output"
  export CPU_CORES_PER_SOCKET=1
fi
CPU_THREADS=`echo "$LSCPU" | grep "^CPU(s):" | cut -d':' -f2 | sed "s/^[ \t]*//"`
if [ -z "$CPU_THREADS" ]; then
  echo "WARNING: Can't get CPU cores from lscpu output"
  export CPU_THREADS=1
fi
CPU_MHZ=`echo "$LSCPU" | grep "^CPU max MHz:" | cut -d':' -f2 | sed "s/^[ \t]*//"`
CPU_MHZ=${CPU_MHZ%.*}
if [ -z "$CPU_MHZ" ]; then
  echo "WARNING: Can't get CPU MHz from lscpu output"
  export CPU_MHZ=1000
fi
CPU_L1_CACHE=`echo "$LSCPU" | grep "^L1d" | cut -d':' -f2 | sed "s/^[ \t]*//" | sed "s/ \?K\(iB\)\?\$//"`
if echo "$CPU_L1_CACHE" | grep MiB >/dev/null; then
  CPU_L1_CACHE=`echo "$CPU_L1_CACHE" | sed "s/ MiB\$//"`
  CPU_L1_CACHE=$(( $CPU_L1_CACHE * 1024))
fi
if [ -z "$CPU_L1_CACHE" ]; then
  echo "WARNING: Can't get L1 CPU cache from lscpu output"
  export CPU_L1_CACHE=16
fi
CPU_L2_CACHE=`echo "$LSCPU" | grep "^L2" | cut -d':' -f2 | sed "s/^[ \t]*//" | sed "s/ \?K\(iB\)\?\$//"`
if echo "$CPU_L2_CACHE" | grep MiB >/dev/null; then
  CPU_L2_CACHE=`echo "$CPU_L2_CACHE" | sed "s/ MiB\$//"`
  CPU_L2_CACHE=$(( $CPU_L2_CACHE * 1024))
fi
if [ -z "$CPU_L2_CACHE" ]; then
  echo "WARNING: Can't get L2 CPU cache from lscpu output"
  export CPU_L2_CACHE=256
fi
CPU_L3_CACHE=`echo "$LSCPU" | grep "^L3" | cut -d':' -f2 | sed "s/^[ \t]*//" | sed "s/ \?K\(iB\)\?\$//"`
if echo "$CPU_L3_CACHE" | grep MiB >/dev/null; then
  CPU_L3_CACHE=`echo "$CPU_L3_CACHE" | sed "s/ MiB\$//"`
  CPU_L3_CACHE=$(( $CPU_L3_CACHE * 1024))
fi
if [ -z "$CPU_L3_CACHE" ]; then
  echo "WARNING: Can't get L3 CPU cache from lscpu output"
  export CPU_L3_CACHE=2048
fi

TOTAL_CACHE=$(( $CPU_THREADS*$CPU_L1_CACHE + $CPU_SOCKETS * ($CPU_CORES_PER_SOCKET*$CPU_L2_CACHE + $CPU_L3_CACHE)))
if [ -z $TOTAL_CACHE ]; then
  echo "ERROR: Can't compute total cache"
  exit 1
fi
EXP_MONERO_HASHRATE=$(( ($CPU_THREADS < $TOTAL_CACHE / 2048 ? $CPU_THREADS : $TOTAL_CACHE / 2048) * ($CPU_MHZ * 20 / 1000) ))
if [ -z $EXP_MONERO_HASHRATE ]; then
  echo "ERROR: Can't compute projected Monero hashrate"
  exit 1
fi

REAL_XMR_HASHRATE=$(($EXP_MONERO_HASHRATE * 10 ))
echo
echo "JFYI: This host has $CPU_THREADS CPU threads with $CPU_MHZ MHz and ${TOTAL_CACHE}KB data cache in total, so projected Monero hashrate is around $REAL_XMR_HASHRATE H/s."
echo