# Create a CLTV script with a timestamp of 1495584032 and public key below:
# publicKey=02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277

TIMESTAMP=1495584032

PUBLIC_KEY="02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277"

# === Bitcoin Script Opcodes ===
OP_CHECKLOCKTIMEVERIFY="b1"
OP_DROP="75"
OP_DUP="76"
OP_HASH160="a9"
PUBKEY_HASH_PUSH="14" # Push 20 bytes (pubkey hash)
OP_EQUALVERIFY="88"
OP_CHECKSIG="ac"

# === Create optimized hex representation for blocks ===
# Convert to hex and strip unnecessary leading zeros
TIMESTAMP_HEX=$(printf '%08x\n' $TIMESTAMP | sed 's/^\(00\)*//')

# Check if the high bit is set (would be interpreted as negative)
# If so, add a padding zero to ensure positive interpretation
HEX_FIRST_CHAR=$(echo $TIMESTAMP_HEX | cut -c1)
[[ 0x$HEX_FIRST_CHAR -gt 0x7 ]] && TIMESTAMP_HEX="00"$TIMESTAMP_HEX

# Convert to little-endian format
TIMESTAMP_LE_HEX=$(echo $TIMESTAMP_HEX | grep -o .. | tac | tr -d '\n')

# Calculate the byte size for proper push operation
TIMESTAMP_BYTES=$(echo -n "$TIMESTAMP_LE_HEX" | wc -c | awk '{print $1/2}')
TIMESTAMP_PUSH=$(printf "%02x" $TIMESTAMP_BYTES)

# === Calculate HASH160 of the public key ===
PUBKEY_HASH=$(echo -n "$PUBLIC_KEY" | xxd -r -p | openssl dgst -sha256 -binary | openssl dgst -rmd160 -binary | xxd -p)

# === Assemble the complete script ===
# Format: <push><timestamp> OP_CLTV OP_DROP OP_DUP OP_HASH160 <push><pubkeyhash> OP_EQUALVERIFY OP_CHECKSIG
SCRIPT_HEX="${TIMESTAMP_PUSH}${TIMESTAMP_LE_HEX}${OP_CHECKLOCKTIMEVERIFY}${OP_DROP}${OP_DUP}${OP_HASH160}${PUBKEY_HASH_PUSH}${PUBKEY_HASH}${OP_EQUALVERIFY}${OP_CHECKSIG}"

echo "$SCRIPT_HEX"
