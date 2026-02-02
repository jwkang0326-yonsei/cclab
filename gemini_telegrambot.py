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

def run_gemini(prompt):
    """로컬 gemini CLI를 실행하고 결과를 반환합니다."""
    try:
        # gemini 명령 실행 (이전 세션 재개 모드)
        print(f"🚀 Gemini 실행 (Context Resume): {prompt}")
        
        process = subprocess.Popen(
            ['gemini', '--yolo', '--resume', 'latest', prompt],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=os.environ,
            text=True
        )
        
        stdout, stderr = process.communicate()
        
        if process.returncode != 0:
            # 세션 없음 오류 시 재시도 (새 세션 시작)
            if "No previous sessions found" in stderr:
                print("⚠️ 이전 세션 없음. 새 세션으로 시작합니다.")
                process = subprocess.Popen(
                    ['gemini', '--yolo', prompt],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    env=os.environ,
                    text=True
                )
                stdout, stderr = process.communicate()
            
            # 재시도 후에도 에러가 있거나, 다른 에러인 경우
            if process.returncode != 0:
                # 에러 메시지 분석 및 순화
                if "exhausted your capacity" in stderr:
                    return "😅 Gemini가 잠시 지쳤어요. (API 사용량 제한 초과)\n잠시 후 다시 질문해주세요."
                if "Operation cancelled" in stderr:
                    return "⚠️ 작업이 취소되었습니다."
                
                # 너무 긴 기술적 로그는 잘라내고 핵심만 보여줌
                return f"⚠️ 오류가 발생했습니다:\n{clean_ansi_codes(stderr)[:300]}..."
            
        return clean_ansi_codes(stdout).strip()

    except FileNotFoundError:
        return "❌ 오류: 'gemini' 명령어를 찾을 수 없습니다. PATH 설정을 확인해주세요."
    except Exception as e:
        return f"❌ 실행 중 오류 발생: {str(e)}"

def main():
    env = load_env()
    token = env.get('GEMINI_BOT_TOKEN') or os.environ.get('GEMINI_BOT_TOKEN')
    authorized_user = env.get('ALLOWED_USER_ID') or os.environ.get('ALLOWED_USER_ID')

    if not token or not authorized_user:
        print("Error: .env 파일에 GEMINI_BOT_TOKEN과 ALLOWED_USER_ID가 필요합니다.")
        sys.exit(1)
        
    print(f"🤖 Gemini Bridge 봇 시작 (User: {authorized_user})")
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
                    
                    if chat_id != authorized_user:
                        print(f"⛔ 차단된 사용자: {chat_id}")
                        continue
                    
                    if text:
                        print(f"👤 질문: {text}")
                        
                        if text == '/start':
                            send_message("안녕하세요! 저는 당신의 로컬 Gemini CLI와 연결된 봇입니다. 무엇이든 물어보세요.")
                            continue
                        
                        if text == '/save_context':
                            send_message("💾 대화 맥락을 압축하여 저장하는 중입니다...")
                            response = run_gemini("현재까지의 대화 내용, 프로젝트 진행 상황, 주요 결정 사항을 요약해서 'context_history.md' 파일로 저장해줘. 나중에 이 파일을 읽어서 작업을 이어서 할 수 있도록 구체적으로 작성해줘.")
                            print(f"🤖 답변 전송 ({len(response)}자)")
                            send_message(response)
                            continue
                        
                        # 처리 중임을 알림
                        send_message("🤔 생각 중...")
                        
                        # Gemini CLI 실행
                        response = run_gemini(text)
                        
                        # 결과 전송
                        print(f"🤖 답변 전송 ({len(response)}자)")
                        # 메시지가 너무 길 경우 텔레그램 제한(4096자) 고려해야 하나 일단 보냄
                        send_message(response)
            
            time.sleep(1)

        except KeyboardInterrupt:
            print("\n👋 봇 종료")
            break
        except Exception as e:
            print(f"\n❌ 메인 루프 오류: {e}")
            time.sleep(5)

if __name__ == "__main__":
    main()