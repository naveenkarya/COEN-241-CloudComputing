for i in {1..5}
do
  sysbench fileio --verbosity=0 cleanup
  sysbench --file-total-size=4G --file-test-mode=rndrw --verbosity=0 fileio prepare
  if [ -z "$1" ]
    then
      sysbench --time=30 --file-test-mode=rndrw fileio run | grep -E "read, MiB/s|written, MiB/s|avg:"
    else
      sysbench --time=30 --file-test-mode=rndrw --threads="$1" fileio run | grep -E "read, MiB/s|written, MiB/s|avg:"
  fi
done
