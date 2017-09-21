#!/bin/bash
URL_GET_TOKEN="https://qyapi.weixin.qq.com/cgi-bin/gettoken"
URL_SEND_MSG="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token="
CORP_ID="ww13bb539141c8d2fb"
SECRET="jm9RODj0jM2H7ghFiD4dnIRjhW8t3-VWR51gbrmuNvY"
TOUSER=@all
AGENTID=1000002

MSG='{'
MSG=$MSG'"touser":"'$TOUSER'",'
MSG=$MSG'"text":{"content":"'$1'"},'
MSG=$MSG'"safe":"0",'
MSG=$MSG'"agentid":'$AGENTID','
MSG=$MSG'"msgtype":"text"'
MSG=$MSG'}'

TOKEN=$(curl -s "$URL_GET_TOKEN?corpid=$CORP_ID&corpsecret=$SECRET" | jq -r .access_token)

if [ -z $TOKEN ]; then
    echo Get token error, maybe network issue
    exit 100
fi

return=$(curl -s -X POST -d "$MSG" $URL_SEND_MSG$TOKEN)

if [ -z "$return" ]; then
    echo Send msg error, maybe network issue
    exit 101
else
    errcode=$(echo $return | jq -r .errcode)
    if [[ $errcode -ne 0 ]]; then
        errmsg=$(echo $return | jq -r .errmsg)
        echo Send msg error, with error $errcode: $errmsg
        exit 102
    else
        echo ok
    fi
fi
