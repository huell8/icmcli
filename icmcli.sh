#!/usr/bin/env bash

# defaults
# DATE=now but the hour must be a multiple of 6
if [ $(date +%H) -lt 6 ]; then
    DATE="$(date +%Y%m%d --date="1 day ago")18"
else
    HOUR=$(($(($(date +%H)/6))*6))
    HOUR="$HOUR"
    if [ $(expr length $HOUR) -lt 2]; then
        $HOUR="0$HOUR"
    fi
    DATE="$(date +%Y%m%d)${HOUR}"
fi
CITY="&row=342&col=208" # gdynia
LANG="en"
OUT="$HOME/Downloads/forecast.png"
EXEC="sxiv -z 200"

function usage {
    echo "
weather - icm meteo cli debloater
Usage: whather
    -d, --date -> specify date and time (dafaults to current time)
                    format: yyyymmddhh
                    hour must be divisible by 6!
    -c, --city -> specify city (defaults to $CITY)
                    format: &row=xxx&col=yyy
                    get you xxx and yyy cooridnates on https://m.meteo.pl
    -l, --lang -> specify lanugage (defaults to $LANG)
                    format: pl or en
    -o, --out  -> path to store the forecast to (defaults to $OUT)
    -e, --exec -> program to open forcast (defaults to $EXEC)
                    if you want to just download use '--exec donotpen'
    -h, --help -> show this message
"
    exit 0
}

for arg in "$@"; do
    shift
    case "$arg" in
        '--date') set -- "$@" '-d'   ;;
        '--city') set -- "$@" '-c'   ;;
        '--lang') set -- "$@" '-l'   ;;
        '--out')  set -- "$@" '-o'   ;;
        '--exec') set -- "$@" '-e'   ;;
        '--help') set -- "$@" '-h'   ;;
        *)        set -- "$@" "$arg" ;;
    esac
done
while getopts "d:c:l:e:h" opt; do
    case ${opt} in
        d)
            if [ $(expr length "$OPTARG") -ne 10 ] ||
               !( [ ${OPTARG: -2} == "00" ] || [ ${OPTARG: -2} == "06" ] || [ ${OPTARG: -2} == "12" ] || [ ${OPTARG: -2} == "18" ] ); then
                echo "wrong date format!"
                usage
            fi
            DATE=$OPTARG
        ;;
        c)
            PATTERN="&row=*&col=*"
            if [[ $OPTARG != $PATTERN ]]; then
                echo "wrong city format!"
                usage
            fi
            CITY=$OPTARG
        ;;
        l)
            if [[ $OPTARG != "en" ]] || [[ $OPTARG != "pl" ]]; then
                echo "wrong language format!"
                usage
            fi
            LANG=$OPTARG
        ;;
        e)
            EXEC=$OPTARG
        ;;
        h)  usage ;;
        \?) usage ;;
        *)  usage  ;;
    esac
done

if [[ -d $OUT ]]; then
    if [[ $OUT == */ ]]; then
        OUT=${OUT}forecast.png
    else
        OUT=$OUT/forecast.png
    fi
fi

echo "downloading: https://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&fdate=${DATE}${CITY}&lang=${LANG}"
curl "https://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&fdate=${DATE}${CITY}&lang=${LANG}" > $OUT

if [[ $EXEC == "donotopen" ]]; then
    echo "saved to $OUT"
    exit 0
else
    $EXEC $OUT
fi