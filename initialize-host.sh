# .devcontainer/initialize-host.sh

#!/bin/bash
# This script runs on the HOST machine before the container is created.

set -e # Exit immediately if a command exits with a non-zero status.

KEY_FILE=~/.ssh/devcontainer_id_rsa
PUB_KEY_FILE=${KEY_FILE}.pub
AUTHORIZED_KEYS_FILE=~/.ssh/authorized_keys

# 1. Ensure the .ssh directory exists.
mkdir -p ~/.ssh
chmod 700 ~/.ssh

echo "Checking for dev container SSH key..."

# 2. Create the SSH key if it doesn't exist.
if [ ! -f "$KEY_FILE" ]; then
    echo "  -> Key not found. Generating new key at ${KEY_FILE}"
    # Generate a new RSA key without a passphrase.
    ssh-keygen -t rsa -b 4096 -f "$KEY_FILE" -N ""
else
    echo "  -> Key already exists. Skipping generation."
fi

# 3. Add the public key to authorized_keys if it's not already there.
#    This makes the script safe to run multiple times (idempotent).
if ! grep -q -f "$PUB_KEY_FILE" "$AUTHORIZED_KEYS_FILE"; then
    echo "  -> Authorizing public key..."
    cat "$PUB_KEY_FILE" >> "$AUTHORIZED_KEYS_FILE"
else
    echo "  -> Public key already authorized."
fi

# 4. Ensure correct permissions for the authorized_keys file.
chmod 600 "$AUTHORIZED_KEYS_FILE"

echo "Host SSH setup complete."
