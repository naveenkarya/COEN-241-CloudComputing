for i in {1..5}
do
  if [ -z "$1" ]
    then
      sysbench --time=30 --cpu-max-prime=20000 cpu run | grep "events per second"
    else
      sysbench --time=30 --cpu-max-prime=20000 --threads="$1" cpu run | grep "events per second"
  fi
done
