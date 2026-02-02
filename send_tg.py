import os
import sys
import urllib.request
import urllib.parse
import json

def load_env():
    """간단한 .env 파서 (스크립트 위치 기준)"""
    env_vars = {}
    # 스크립트 파일의 절대 경로를 기준으로 .env 파일 경로 설정
    base_dir = os.path.dirname(os.path.abspath(__file__))
    env_path = os.path.join(base_dir, '.env')
    
    # print(f"DEBUG: .env 파일 경로 확인: {env_path}") # 필요시 주석 해제

    if os.path.exists(env_path):
        with open(env_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                if '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip().strip('"').strip("'")
                    env_vars[key] = value
    else:
        print(f"⚠️ 경고: .env 파일을 찾을 수 없습니다: {env_path}")

    return env_vars

def send_message(message):
    env = load_env()
    token = env.get('GEMINI_BOT_TOKEN') or os.environ.get('GEMINI_BOT_TOKEN')
    chat_id = env.get('ALLOWED_USER_ID') or os.environ.get('ALLOWED_USER_ID')

    if not token or not chat_id:
        print("Error: .env 파일 또는 환경 변수에 GEMINI_BOT_TOKEN과 ALLOWED_USER_ID가 설정되지 않았습니다.")
        sys.exit(1)

    url = f"https://api.telegram.org/bot{token}/sendMessage"
    data = {
        "chat_id": chat_id,
        "text": message
    }
    
    headers = {'Content-Type': 'application/json'}
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=headers)

    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            if result.get('ok'):
                print("✅ 텔레그램 메시지 전송 성공!")
            else:
                print(f"❌ 전송 실패: {result}")
    except Exception as e:
        print(f"❌ 오류 발생: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("사용법: python3 send_tg.py \"보낼 메시지\"")
        sys.exit(1)
    
    msg = sys.argv[1]
    send_message(msg)
