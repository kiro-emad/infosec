#!/bin/bash

LOG_FILE="acc.log"
REPORT_FILE="log_analysis_report.txt"


echo "Log File Analysis Report" > $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "===================================" >> $REPORT_FILE

# 1. Request Counts
echo -e "\n1. Request Counts" >> $REPORT_FILE
TOTAL_REQUESTS=$(wc -l < $LOG_FILE)
GET_REQUESTS=$(grep '"GET' $LOG_FILE | wc -l)
POST_REQUESTS=$(grep '"POST' $LOG_FILE | wc -l)
echo "Total Requests: $TOTAL_REQUESTS" >> $REPORT_FILE
echo "GET Requests: $GET_REQUESTS" >> $REPORT_FILE
echo "POST Requests: $POST_REQUESTS" >> $REPORT_FILE

# 2. Unique IP Addresses
echo -e "\n2. Unique IP Addresses" >> $REPORT_FILE
UNIQUE_IPS=$(awk '{print $1}' $LOG_FILE | sort | uniq)
UNIQUE_IP_COUNT=$(echo "$UNIQUE_IPS" | wc -l)
echo "Total Unique IPs: $UNIQUE_IP_COUNT" >> $REPORT_FILE
echo "IP Address | GET Requests | POST Requests" >> $REPORT_FILE
echo "---------------------------------------" >> $REPORT_FILE
for IP in $UNIQUE_IPS; do
    IP_GET=$(grep $IP $LOG_FILE | grep '"GET' | wc -l)
    IP_POST=$(grep $IP $LOG_FILE | grep '"POST' | wc -l)
    echo "$IP | $IP_GET | $IP_POST" >> $REPORT_FILE
done

# 3. Failure Requests
echo -e "\n3. Failure Requests" >> $REPORT_FILE
FAILED_REQUESTS=$(awk '$9 ~ /^[45]/' $LOG_FILE | wc -l)
FAILED_PERCENT=$(echo "scale=2; ($FAILED_REQUESTS / $TOTAL_REQUESTS) * 100" | bc)
echo "Failed Requests (4xx/5xx): $FAILED_REQUESTS" >> $REPORT_FILE
echo "Percentage of Failed Requests: $FAILED_PERCENT%" >> $REPORT_FILE

# 4. Top User
echo -e "\n4. Top User" >> $REPORT_FILE
TOP_IP=$(awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
TOP_IP_COUNT=$(awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
echo "Most Active IP: $TOP_IP with $TOP_IP_COUNT requests" >> $REPORT_FILE

# 5. Daily Request Averages
echo -e "\n5. Daily Request Averages" >> $REPORT_FILE
DAYS=$(awk -F'[' '{print $2}' $LOG_FILE | awk -F: '{print $1}' | sort | uniq)
DAY_COUNT=$(echo "$DAYS" | wc -l)
AVG_REQUESTS=$(echo "scale=2; $TOTAL_REQUESTS / $DAY_COUNT" | bc)
echo "Average Requests per Day: $AVG_REQUESTS" >> $REPORT_FILE

# 6. Failure Analysis
echo -e "\n6. Failure Analysis" >> $REPORT_FILE
echo "Days with Highest Failure Requests:" >> $REPORT_FILE
awk '$9 ~ /^[45]/ {print $0}' $LOG_FILE | awk -F'[' '{print $2}' | awk -F: '{print $1}' | sort | uniq -c | sort -nr | head -3 >> $REPORT_FILE

# 7. Request by Hour
echo -e "\n7. Request by Hour" >> $REPORT_FILE
echo "Hour | Requests" >> $REPORT_FILE
echo "----------------" >> $REPORT_FILE
awk -F: '{print $2}' $LOG_FILE | awk '{print $1}' | sort | uniq -c | awk '{printf "%02d | %d\n", $2, $1}' >> $REPORT_FILE

# 8. Status Codes Breakdown
echo -e "\n8. Status Codes Breakdown" >> $REPORT_FILE
echo "Status Code | Count" >> $REPORT_FILE
echo "-------------------" >> $REPORT_FILE
awk '{print $9}' $LOG_FILE | sort | uniq -c | awk '{print $2 " | " $1}' >> $REPORT_FILE

# 9. Most Active User by Method
echo -e "\n9. Most Active User by Method" >> $REPORT_FILE
TOP_GET_IP=$(awk '/"GET/ {print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
TOP_GET_COUNT=$(awk '/"GET/ {print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
TOP_POST_IP=$(awk '/"POST/ {print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
TOP_POST_COUNT=$(awk '/"POST/ {print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
echo "Most Active GET IP: $TOP_GET_IP with $TOP_GET_COUNT requests" >> $REPORT_FILE
echo "Most Active POST IP: $TOP_POST_IP with $TOP_POST_COUNT requests" >> $REPORT_FILE

# 10. Patterns in Failure Requests
echo -e "\n10. Patterns in Failure Requests" >> $REPORT_FILE
echo "Hours with Highest Failure Requests:" >> $REPORT_FILE
awk '$9 ~ /^[45]/ {print $0}' $LOG_FILE | awk -F: '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -nr | head -3 >> $REPORT_FILE

# 11. Analysis Suggestions
echo -e "\n11. Analysis Suggestions" >> $REPORT_FILE
echo "- Investigate IPs with high failure rates for potential malicious activity." >> $REPORT_FILE
echo "- Schedule maintenance during low-traffic hours (based on hourly request trends)." >> $REPORT_FILE
echo "- Monitor days with high failures for server or application issues." >> $REPORT_FILE
echo "- Implement rate-limiting for IPs with unusually high request counts." >> $REPORT_FILE

# pandoc $REPORT_FILE -o log_analysis_report.pdf

echo "Analysis complete. Report saved to $REPORT_FILE"
