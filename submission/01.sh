# Create a wallet with the name "btrustwallet".
WALLET_NAME=$(bitcoin-cli -regtest createwallet "btrustwallet" | jq .name)
echo "$WALLET_NAME"
