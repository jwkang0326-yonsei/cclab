#!/usr/bin/env python3
import os
import sys
import time
import json
import urllib.request
import urllib.parse
import subprocess
import re
from send_tg import send_message, load_env

def get_updates(token, offset=None):
    """텔레그램 서버에서 새 메시지(Update)를 가져옵니다."""
    url = f"https://api.telegram.org/bot{token}/getUpdates?timeout=10"
    if offset:
        url += f"&offset={offset}"
    
    try:
        print("⏳ 텔레그램 서버에 메시지 확인 요청 중...", end='\r')
        with urllib.request.urlopen(url, timeout=15) as response:
            data = json.loads(response.read().decode('utf-8'))
            if data.get('result'):
                print(f"\n📨 서버 응답(데이터 있음): {len(data['result'])}건")
            return data
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        print(f"\n❌ HTTP 오류 발생 ({e.code}): {e.reason}")
        if e.code == 409:
             print("💡 힌트: Webhook 충돌. 브라우저에서 deleteWebhook을 실행하세요.")
        time.sleep(3)
        return None
    except Exception as e:
        print(f"\n❌ 업데이트 확인 중 오류: {e}")
        time.sleep(3)
        return None

def clean_ansi_codes(text):
    """터미널 출력의 ANSI 색상 코드를 제거합니다."""
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|[\[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', text)

SESSION_MAP_FILE = "tg_sessions.json"

def load_session_map():
    if os.path.exists(SESSION_MAP_FILE):
        try:
            with open(SESSION_MAP_FILE, 'r') as f:
                return json.load(f)
        except:
            return {}
    return {}

def save_session_map(session_map):
    try:
        with open(SESSION_MAP_FILE, 'w') as f:
            json.dump(session_map, f)
    except Exception as e:
        print(f"❌ 세션 맵 저장 오류: {e}")

def get_latest_session_uuid():
    try:
        # 최근 세션 목록을 가져와서 가장 최근(첫 번째) 세션의 UUID 추출
        result = subprocess.run(['gemini', '--list-sessions'], capture_output=True, text=True, env=os.environ)
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')
            for line in lines:
                # [uuid] 형식 매칭
                match = re.search(r'\[([a-f0-9\-]{36})\]', line)
                if match:
                    return match.group(1)
    except Exception as e:
        print(f"⚠️ 최신 세션 UUID 확인 중 오류: {e}")
    return None

def run_gemini(prompt, chat_id):
    """로컬 gemini CLI를 실행하고 결과를 반환합니다."""
    session_map = load_session_map()
    session_uuid = session_map.get(chat_id)
    
    try:
        if session_uuid:
            print(f"🚀 Gemini 실행 (Resume Session: {session_uuid}): {prompt[:50]}...")
            cmd = ['gemini', '--yolo', '--resume', session_uuid, '-p', prompt]
        else:
            print(f"🚀 Gemini 실행 (New Session): {prompt[:50]}...")
            cmd = ['gemini', '--yolo', '-p', prompt]
        
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=os.environ,
            text=True
        )
        
        stdout, stderr = process.communicate()
        
        # 세션 식별자 오류 또는 세션을 찾을 수 없는 경우
        if process.returncode != 0 and ("Invalid session identifier" in stderr or "not found" in stderr.lower() or "Error resuming session" in stderr):
            print(f"⚠️ 세션 {session_uuid}을(를) 사용할 수 없습니다. 새 세션으로 시작합니다.")
            process = subprocess.Popen(
                ['gemini', '--yolo', '-p', prompt],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                env=os.environ,
                text=True
            )
            stdout, stderr = process.communicate()
            
            # 새 세션 시작 후 UUID 업데이트
            new_uuid = get_latest_session_uuid()
            if new_uuid:
                session_map[chat_id] = new_uuid
                save_session_map(session_map)
                print(f"✅ 새 세션 UUID 저장: {new_uuid}")

        elif process.returncode == 0 and not session_uuid:
            # 성공적으로 새 세션을 시작한 경우 UUID 저장
            new_uuid = get_latest_session_uuid()
            if new_uuid:
                session_map[chat_id] = new_uuid
                save_session_map(session_map)
                print(f"✅ 새 세션 UUID 저장: {new_uuid}")
            
        if process.returncode != 0:
            if "exhausted your capacity" in stderr:
                return "😅 Gemini가 잠시 지쳤어요. (API 사용량 제한 초과)\n잠시 후 다시 질문해주세요."
            return f"⚠️ 오류가 발생했습니다:\n{clean_ansi_codes(stderr)[:300]}..."
            
        return clean_ansi_codes(stdout).strip()

    except FileNotFoundError:
        return "❌ 오류: 'gemini' 명령어를 찾을 수 없습니다. PATH 설정을 확인해주세요."
    except Exception as e:
        return f"❌ 실행 중 오류 발생: {str(e)}"

import traceback

def delete_webhook(token):
    """등록된 webhook을 삭제하여 getUpdates와의 충돌을 방지합니다."""
    # drop_pending_updates=True를 추가하여 쌓여있던 업데이트를 삭제합니다.
    url = f"https://api.telegram.org/bot{token}/deleteWebhook?drop_pending_updates=True"
    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            data = json.loads(response.read().decode('utf-8'))
            if data.get('result'):
                print("✅ Webhook 삭제 및 대기 업데이트 정리 완료")
            else:
                print(f"⚠️ Webhook 삭제 응답: {data}")
    except Exception as e:
        print(f"⚠️ Webhook 삭제 중 오류 (무시하고 계속): {e}")


def main():
    try:
        env = load_env()
        token = env.get('GEMINI_BOT_TOKEN') or os.environ.get('GEMINI_BOT_TOKEN')
        authorized_users_raw = env.get('ALLOWED_USER_ID') or os.environ.get('ALLOWED_USER_ID')

        if not token or not authorized_users_raw:
            print("Error: .env 파일에 GEMINI_BOT_TOKEN과 ALLOWED_USER_ID가 필요합니다.")
            sys.exit(1)

        # Webhook 충돌 방지: 시작 시 항상 삭제
        delete_webhook(token)

        # 쉼표로 구분된 ID들을 리스트로 변환
        authorized_users = [uid.strip() for uid in authorized_users_raw.split(',')]
        
        print(f"🤖 Gemini Bridge 봇 시작 (Users: {', '.join(authorized_users)})")
        print("텔레그램 -> Gemini CLI -> 텔레그램")
        
        last_update_id = None

        while True:
            try:
                updates = get_updates(token, last_update_id)
                
                if updates and updates.get('ok'):
                    for result in updates['result']:
                        last_update_id = result['update_id'] + 1
                        
                        message = result.get('message')
                        if not message: continue
                        
                        chat_id = str(message['chat']['id'])
                        text = message.get('text', '')
                        
                        if chat_id not in authorized_users:
                            print(f"⛔ 차단된 사용자: {chat_id}")
                            continue
                        
                        if text:
                            print(f"👤 질문: {text}")
                            
                            if text == '/start':
                                send_message("안녕하세요! 저는 당신의 로컬 Gemini CLI와 연결된 봇입니다. 무엇이든 물어보세요.", chat_id=chat_id)
                                continue
                            
                            if text == '/save_context':
                                send_message("💾 대화 맥락을 압축하여 저장하는 중입니다...", chat_id=chat_id)
                                response = run_gemini("현재까지의 대화 내용, 프로젝트 진행 상황, 주요 결정 사항을 요약해서 'context_history.md' 파일로 저장해줘. 나중에 이 파일을 읽어서 작업을 이어서 할 수 있도록 구체적으로 작성해줘.", chat_id=chat_id)
                                print(f"🤖 답변 전송 ({len(response)}자)")
                                send_message(response, chat_id=chat_id)
                                continue
                            
                            # 처리 중임을 알림
                            send_message("🤔 생각 중...", chat_id=chat_id)
                            
                            # Gemini CLI 실행
                            response = run_gemini(text, chat_id=chat_id)
                            # 결과 전송
                            print(f"🤖 답변 전송 ({len(response)}자)")
                            send_message(response, chat_id=chat_id)
                
                time.sleep(1)

            except Exception as e:
                print(f"\n❌ 루프 내 오류 발생: {e}")
                traceback.print_exc()
                time.sleep(5)

    except KeyboardInterrupt:
        print("\n👋 봇 종료 (KeyboardInterrupt)")
    except Exception as e:
        print(f"\n💥 치명적 오류 발생: {e}")
        traceback.print_exc()


if __name__ == "__main__":
    main()