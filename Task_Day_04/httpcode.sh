#!/bin/bash

site="guvi.in"

STATUS=$(curl -s -L -o /dev/null -w "%{http_code}" "$site")

echo -e "The status code for site '$site' is: $STATUS"

if [ "$STATUS" -eq 200 ]; then
	echo "Success: The website is up and running!"
else
	echo "Failure: Something went wrong. Error code: $STATUS"
fi
