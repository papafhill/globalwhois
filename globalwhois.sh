#!/bin/bash

# Color Options - Because color is good...
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
LGRAY="\e[38m"
GRAY="\e[90m"
LRED="\e[91m"
LGREEN="\e[92m"
LYELLOW="\e[93m"
LBLUE="\e[94m"
LMAGENTA="\e[95m"
LCYAN="\e[96m"
WHITE="\e[97m"
EC="\e[0m"
BOLD="\e[1m"
RED_BG="\e[0;101m"

# Check if a domain is provided
if [ -z "$1" ]; then
    echo "Usage: bash whoisglobal.sh example.com"
    exit 1
fi

# Extract the apex domain (removing the last .TLD part)
DOMAIN=$(echo "$1" | awk -F. '{OFS="."; $NF=""; print $0}' | sed 's/\.$//')

# List of common TLDs to iterate through
TLD_LIST=("com" "net" "org" "io" "co.uk" "de" "jp" "fr" "ca" "au" "nl" "ru" "br" "kr" "in" "za" "sg")

# Output file
OUTPUT_FILE="output.txt"
echo "WHOIS Lookup for variations of $DOMAIN" > "$OUTPUT_FILE"

# Iterate through each TLD
for TLD in "${TLD_LIST[@]}"; do
    FULL_DOMAIN="${DOMAIN}.${TLD}"
    echo -e "[${CYAN}INFO${EC}]Checking WHOIS for $FULL_DOMAIN" | tee -a "$OUTPUT_FILE"

    # Get the correct WHOIS server for the TLD
    WHOIS_SERVER=$(whois -h whois.iana.org "$TLD" 2>/dev/null | grep "whois:" | awk '{print $2}')
    
    if [ -z "$WHOIS_SERVER" ]; then
        WHOIS_SERVER="whois.nic.${TLD}" # Default fallback
    fi
    
    echo -e "[${RED}COMMAND${EC}] Running the following command: whois -h $WHOIS_SERVER $FULL_DOMAIN" | tee -a "$OUTPUT_FILE"

    # Perform WHOIS lookup
    WHOIS_OUTPUT=$(whois -h "$WHOIS_SERVER" "$FULL_DOMAIN" 2>/dev/null)
    echo "$WHOIS_OUTPUT"

    # Check for common patterns indicating domain availability
    if echo "$WHOIS_OUTPUT" | grep -qiE "No match|NOT FOUND|Status: free|available|is free|No Data Found|Domain not found|does not exist|No entries found for the selected source"; then
        STATUS="[${LGREEN}AVAILABLE${EC}]"
    else
        STATUS="[${LRED}REGISTERED${EC}]"
    fi
    
    echo -e "Domain: $FULL_DOMAIN - Status: $STATUS" | tee -a "$OUTPUT_FILE"
    echo "----------------------------------------" >> "$OUTPUT_FILE"
done

echo "WHOIS scan complete. Results saved in $OUTPUT_FILE."
