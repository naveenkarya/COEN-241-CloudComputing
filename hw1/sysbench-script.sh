echo -e "\nRunning CPU Test\n"
if [ -z "$1" ]
  then
    sysbench --time=30 --cpu-max-prime=20000 cpu run
  else
    sysbench --time=30 --cpu-max-prime=20000 --threads="$1" cpu run
fi
echo -e "\nRunning FileIO Test\n"
echo -e "\nFileIO Test - Cleanup\n"
sysbench fileio cleanup
echo -e "\nFileIO Test - Prepare\n"
sysbench --file-total-size=4G --file-test-mode=rndrw fileio prepare
echo -e "\nFileIO Test - Run\n"
if [ -z "$1" ]
  then
    sysbench --time=30 --file-test-mode=rndrw fileio run
  else
    sysbench --time=30 --file-test-mode=rndrw --threads="$1" fileio run
fi


