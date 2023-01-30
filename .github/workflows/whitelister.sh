#!/bin/bash

echo "Starting Script..."
echo "Downloading gov.txt..."
wget https://raw.githubusercontent.com/cisagov/dotgov-data/main/gov.txt

echo "Cleaning Data..."
WORDLIST=gov.txt

for TARGET in $(cat $WORDLIST); do
    echo "$TARGET" | grep -oE "\w*\.gov" | sort -u >> cleanedgov.txt
done


echo "Processing Data..."
WORDLIST=cleanedgov.txt

for TARGET in $(cat $WORDLIST); do

    curl -s "https://crt.sh/?q=${TARGET}&output=json" | jq -r '.[] | "\(.name_value)"' | grep -v *. | sort -u >> processed_gov.txt
done

echo "Running NSLOOKUP..."
WORDLIST=processed_gov.txt
echo "domain,ip" >> final_results.csv

for TARGET in $(cat $WORDLIST); do
    nslookup -querytype=A $TARGET  | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v '127' | sed "s/^/$TARGET,/g" >> rita_gov_whitelist.csv
done

echo "Script Complete!"
