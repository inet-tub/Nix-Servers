# Drive Setup
export NUM_DRIVES=3
export RAID_LEVEL="mirror" # possible values are `stripe`, `mirror`, `raidz1` or any option zfs supports
export ROOT_POOL_NAME="rpool"
export BOOT_POOL_NAME="bpool"
export SWAP_AMOUNT_GB=64
export NUM_HOT_SPARES=1  # The number of hot spares should be included in `NUM_DRIVES`. Set to 0 to disable hot spares.

# Host Setup
export HOST_TO_INSTALL="authentication"
export ROOT_PASSWORD="root"
export GIT_EMAIL="seebeckemily3403@gmail.com"
export GIT_UNAME="Emily3403"

export HOST_PRIVATE_SSH_KEY=""  # You may set the private key used for agenix decryption
