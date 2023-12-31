# Drive Setup
export NUM_DRIVES=6
export RAID_LEVEL="raidz2" # possible values are `stripe`, `mirror`, `raidz1` or any option zfs supports
export ROOT_POOL_NAME="rpool"
export BOOT_POOL_NAME="bpool"
export SWAP_AMOUNT_GB=64

# Host Setup
export HOST_TO_INSTALL="enbackup"
export ROOT_PASSWORD="root"
export GIT_EMAIL="seebeckemily3403@gmail.com"
export GIT_UNAME="Emily3403"
export HOST_PRIVATE_SSH_KEY=""  # You may set the private key used for agenix decryption
# TODO: Detect ed25519 and link accordingly or just never use rsa again
