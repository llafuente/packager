#/bin/sh

set -ex

SWAP_FILE="/swapfile"

for i in "$@"
do
case $i in
  --permanent)
    PERMANENT=1
  ;;
  --file=*)
    SWAP_FILE="${i#*=}"
    shift # past argument=value
  ;;
  *)
    # unknown option
  ;;
esac
done


sudo dd if=/dev/zero of=${SWAP_FILE} count=4096 bs=1MiB
sudo chmod 600 ${SWAP_FILE}
ls -lh ${SWAP_FILE}

sudo mkswap ${SWAP_FILE}
sudo swapon ${SWAP_FILE}

if [ ! -z ${DOMAIN} ]; then
  echo -ne "\n${SWAP_FILE}   swap    swap    sw  0   0" | sudo tee -a /etc/fstab
fi

free -m

echo "OK"
