#!/bin/bash -e
#
# XSKY License generator
# Copyright XSKY.com all rights reserved
#


# Generated params
AGENT='zstack'
TOKEN='7aa3c501-1e4e-4866-b8ad-f0dda60794a3'
URL='https://license-service.xsky.com:10086'
#URL='http://localhost:8000'

# Cli params
CAPACITY=0
DAYS=0
HOSTS=0
KEYFILE=''
PRODUCT=''


show_help() {
    cat <<'EOF'
Usage: ./xsky-license.sh [options] > output.enc
    -h  --help                 Show this page
    -s  --stat                 Show usage quota

    -c  --capacity  [num]      Capacity (TB)
    -d  --days      [num]      License expiring days
    -o  --hosts     [num]      Host Count
    -k  --keyfile   [str]      License key file path
    -p  --product   [str]      Product name:
        'X-EOS',
        'X-EFS Standard', 'X-EFS Pro',
        'X-EBS Basic',    'X-EBS Standard', 'X-EBS Pro',
        'X-EDP Basic',    'X-EDP Standard', 'X-EDP Pro',
EOF
}


parse_opts() {
    if [[ -z "$@" ]]; then
        show_help
    fi

    local opts=$(getopt \
        -o hsc:d:o:k:p: \
        --long help,stat,capacity:,days:,hosts:,keyfile:,product: \
        -- "$@")

    if [[ $? -ne 0 ]]; then
        show_help
        exit 1
    fi

    eval set -- "$opts"
    while true; do
        case "$1" in
            -c | --capacity)  CAPACITY="$2"; shift 2 ;;
            -d | --days)      DAYS="$2";     shift 2 ;;
            -o | --hosts)     HOSTS="$2";    shift 2 ;;
            -k | --keyfile)   KEYFILE="$2";  shift 2 ;;
            -p | --product)   PRODUCT="$2";  shift 2 ;;
            -h | --help) show_help; exit 1 ;;
            -s | --stat) show_stat; exit 1 ;;
            --) shift; break ;;
            *)  break ;;
        esac
    done
}


gen_license() {
    curl "$URL/licenses/" \
        -X  'POST' \
        -H  "Authorization: Bearer $TOKEN" \
        -F  "cust_name=$AGENT" \
        -F  "key_file=@$KEYFILE" \
        -F  "prod_name=$PRODUCT" \
        -F  "capacity=$CAPACITY" \
        -F  "days=$DAYS" \
        -F  "hosts=$HOSTS" \
        -so-
}


show_stat() {
    curl "$URL/licenses/stat/" \
        -X  'GET' \
        -H  "Authorization: Bearer $TOKEN" \
        -so- | python -m json.tool
}


main() {
    parse_opts "$@"
    gen_license
}


main "$@"

