#!/bin/bash

set -e

ACCESS_DATE=$(date +"%Y-%m-%d %T")
TODAY=$(date +"%Y-%m-%d")

# -------------------------------------------------------
# A shell script that generates a MIT LICENSE file
# Written by: Juny(junyharang8592@gmail.com)
# Last updated on: 2023/09/13
# -------------------------------------------------------

# Source: http://opensource.org/licenses/MIT
echo "[$ACCESS_DATE] [notice] The MIT License (MIT)"
echo "[$ACCESS_DATE] [notice] Copyright (c) 2023 juny(junyharang8592@gmail.com)"
echo "[$ACCESS_DATE] [notice] Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE."

DISCORD_WEBHOOK_URL="{디스코드 웹훅 URL}"
USER_IP=$PAM_RHOST
USER=$PAM_USER
USERNAME=$(grep $USER /etc/passwd | cut -d':' -f5)
HOSTNAME=$(hostname)
SERVER_IP=$(hostname -I | awk '{print $1}')
SERVER_OS_INFO=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
LOG_DIR="/var/log/discord/webhook/accessAlarm/${TODAY}"
LOG_FILE="${LOG_DIR}/sshAccessAlarm.log"

checkLogRelevant() {
  echo "[$ACCESS_DATE] [info] Log가 쌓일 Directory가 존재하는지 확인할게요."

  if [ -d "$LOG_DIR" ];
  then
    echo "[$ACCESS_DATE] Directory가 존재 합니다" >> "$LOG_FILE" 2>&1
  else
    echo "[$ACCESS_DATE] [info] Log가 쌓일 Directory가 존재하지 않아 Directory를 생성할게요."
    mkdir -p $LOG_DIR

    if [ $? != 0 ];
    then
      echo "[$ACCESS_DATE] [error] Log 저장을 위한 Directory 만들기 실패 하였습니다."
      exit 1
     else
      echo "[$ACCESS_DATE] [info] Directory가 존재 하지 않아 생성 하였습니다." >> "$LOG_FILE" 2>&1
     fi
  fi

  echo "====================================== [$ACCESS_DATE] SSH 접속 정보 Discord 알림 스크립트 동작 ======================================"  >> "$LOG_FILE" 2>&1
  echo "@Author: Juny(junyharang8592@gmail.com)"  >> "$LOG_FILE" 2>&1

  licenseNotice
}

licenseNotice() {

  echo "[$ACCESS_DATE] [notice] 해당 Shell Script License에 대한 내용 고지합니다. 숙지하시고, 사용 부탁드립니다."
  echo "[$ACCESS_DATE] [notice] 해당 Shell Script License에 대한 내용 고지합니다. 숙지하시고, 사용 부탁드립니다."  >> "$LOG_FILE" 2>&1

  echo "[$ACCESS_DATE] http://opensource.org/licenses/MIT \n" "$LOG_FILE" 2>&1
  echo "[$ACCESS_DATE] [notice] The MIT License (MIT) \n" >> "$LOG_FILE" 2>&1
  echo "[$ACCESS_DATE] [notice] Copyright (c) [2023] [juny(juny8592@gmail.com)] \n" >> "$LOG_FILE" 2>&1
  echo "[$ACCESS_DATE] [notice] Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the \"Software\"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE." >> "$LOG_FILE" 2>&1

  checkScriptLocation
}

checkScriptLocation() {
  # 현재 작업 디렉토리 위치 정보를 가져옴
  current_directory=$(pwd)

  if [ "$current_directory" = "/etc/ssh" ]; then
    echo "[$ACCESS_DATE] [info] Shell Script 위치가 정상이에요." >> "$LOG_FILE" 2>&1

    checkUserInfo
  else
    echo "[$ACCESS_DATE] [error] Shell Script 위치는 /etc/ssh에 위치해야 합니다. \n 현재 Shell Script 위치: $current_directory" >> "$LOG_FILE" 2>&1
    exit 1
  fi
}

checkUserInfo() {
  echo "[$ACCESS_DATE] [info] Shell Script 실행 계정이 root인지 확인할게요." >> "$LOG_FILE" 2>&1

  if [[ $EUID -ne 0 ]]; then
      echo "[$ACCESS_DATE] [error] 해당 Shell Script는 root로 실행시켜야 합니다." >> "$LOG_FILE" 2>&1
      exit 1

  else
      echo "[$ACCESS_DATE] [info] Shell Script가 root 계정으로 실행 되었어요." >> "$LOG_FILE" 2>&1

      accessSshUserProcess
  fi
}

accessSshUserProcess() {
  # 사용자가 SSH 접속
  if [ "$PAM_TYPE" != "close_session" ];
  then
    TITLE="$ACCESS_DATE 사용자 SSH 접속 확인!"
    MESSAGE="SSH 접속 정보 알림 \n\n ==== 접속 사용자 정보 ==== \n 접속자 계정: $USER \n 접속자 IP 주소: $USER_IP \n 접속자 이름: $USERNAME \n\n ==== 접속 대상 서버 정보 ==== \n 접속 대상 서버 OS 정보 : $SERVER_OS_INFO \n 접속 대상 서버: $HOSTNAME \n 접속 대상 서버 IP: $SERVER_IP"
    COLOR=16711680 # 빨간색
    accessWhether="1"

    echo "[$ACCESS_DATE] [info] SSH 접속 정보 알림 메시지 만들기 성공하였어요." >> "$LOG_FILE" 2>&1
  fi

  # 사용자가 SSH 접속 해제 시
  if [ "$PAM_TYPE" == "close_session" ];
  then
    TITLE="$ACCESS_DATE 사용자 SSH 접속 해제 확인!"
    MESSAGE="SSH 접속 해제 정보 알림 \n\n ==== 접속 해제 사용자 정보 ==== \n 접속자 계정: $USER \n 접속자 IP 주소: $USER_IP \n 접속자 이름: $USERNAME \n\n ==== 접속 해제  대상 서버 정보 ==== \n 접속 대상 서버 OS 정보 : $SERVER_OS_INFO  \n 접속 대상 서버: $HOSTNAME \n 접속 대상 서버 IP: $SERVER_IP"
    COLOR=65280 # 형광 녹색
    accessWhether="0"

    echo "[$ACCESS_DATE] [info] SSH 접속 해제 정보 알림 메시지 만들기 성공하였어요." >> "$LOG_FILE" 2>&1
  fi

  useCurlSendDiscord
}

useCurlSendDiscord() {
  echo "[$ACCESS_DATE] Discord로 SSH 접속 정보 알림 메시지 전송 작업을 시작 합니다." >> "$LOG_FILE" 2>&1

  curl -H "Content-Type: application/json" -d "{
          \"username\":\"Bot Name (임의 작성)\",
          \"embeds\":[{
                  \"title\":\"$TITLE\",
                  \"description\":\"$MESSAGE\",
                  \"color\":$COLOR}]
          }" "$DISCORD_WEBHOOK_URL"

  if [ $? != 0 ];
  then
    echo "[$ACCESS_DATE] [error] Discord로 SSH 접속 정보 알림 메시지 전송 실패하였어요." >> "$LOG_FILE" 2>&1
  else
    echo "[$ACCESS_DATE] [info] Discord로 SSH 접속 정보 알림 메시지 전송 성공하였어요." >> "$LOG_FILE" 2>&1
  fi
}

echo "====================================== [$ACCESS_DATE] SSH 접속 정보 Discord 알림 스크립트 동작 ======================================"
echo "@Author: Juny(junyharang8592@gmail.com)"

checkLogRelevant

echo "[$ACCESS_DATE] ==== 접속 또는 접속 해제 사용자 정보 ====" >> "$LOG_FILE" 2>&1
echo "[$ACCESS_DATE] 접속자 계정: $USER" >> "$LOG_FILE" 2>&1
echo "[$ACCESS_DATE] 접속자 IP 주소: $USER_IP" >> "$LOG_FILE" 2>&1
echo "[$ACCESS_DATE] 접속자 이름: $USERNAME" >> "$LOG_FILE" 2>&1
echo "[$ACCESS_DATE] ==== 접속 또는 접속 해제 대상 서버 정보 ====" >> "$LOG_FILE" 2>&1
echo "[$ACCESS_DATE] 접속 대상 서버: $HOSTNAME" >> "$LOG_FILE" 2>&1
echo "[$ACCESS_DATE] 접속 대상 서버 IP: $SERVER_IP" >> "$LOG_FILE" 2>&1

echo "@Author: Juny(junyharang8592@gmail.com)"  >> "$LOG_FILE" 2>&1
echo "====================================== [$ACCESS_DATE] SSH 접속 정보 Discord 알림 스크립트 작업 끝 ======================================"  >> "$LOG_FILE" 2>&1
