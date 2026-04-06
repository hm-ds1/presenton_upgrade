#!/bin/bash
# Presenton 웹 서버 실행 스크립트
# 사용법: bash run.sh

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 환경변수 설정
export APP_DATA_DIRECTORY="$PROJECT_DIR/app_data"
export USER_CONFIG_PATH="$PROJECT_DIR/app_data/userConfig.json"
export LLM=custom
export CUSTOM_LLM_URL="https://pdf.mobis.com:11001/v1"
export CUSTOM_MODEL=gpt5.4
export CUSTOM_LLM_API_KEY=null
export IMAGE_PROVIDER=disabled
export DISABLE_IMAGE_GENERATION=true
export CAN_CHANGE_KEYS=true

mkdir -p "$APP_DATA_DIRECTORY"

# userConfig.json 없으면 생성
if [ ! -f "$USER_CONFIG_PATH" ]; then
  echo '{"LLM":"custom","CUSTOM_LLM_URL":"https://pdf.mobis.com:11001/v1","CUSTOM_MODEL":"gpt5.4","CUSTOM_LLM_API_KEY":"null","IMAGE_PROVIDER":"disabled","DISABLE_IMAGE_GENERATION":"true"}' > "$USER_CONFIG_PATH"
fi

echo "=== Presenton 서버 시작 ==="
echo "Frontend: http://0.0.0.0:3000"
echo "Backend:  http://127.0.0.1:8000"
echo "Swagger:  http://127.0.0.1:8000/docs"
echo ""

# FastAPI 백엔드 실행 (백그라운드)
cd "$PROJECT_DIR/servers/fastapi"
.venv/bin/python server.py --port 8000 --reload true &
FASTAPI_PID=$!
echo "FastAPI PID: $FASTAPI_PID"

# Next.js 프론트엔드 실행 (백그라운드)
cd "$PROJECT_DIR/servers/nextjs"
npx next start -H 0.0.0.0 -p 3000 &
NEXTJS_PID=$!
echo "Next.js PID: $NEXTJS_PID"

echo ""
echo "종료하려면 Ctrl+C를 누르세요"

# Ctrl+C로 두 프로세스 모두 종료
trap "kill $FASTAPI_PID $NEXTJS_PID 2>/dev/null; echo '서버 종료됨'; exit 0" SIGINT SIGTERM
wait
