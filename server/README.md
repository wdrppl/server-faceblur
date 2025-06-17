# Face Blur Server

FastAPI 서버를 사용하여 얼굴 이미지의 특정 부분을 선택적으로 블러 처리하는 서비스입니다.

## 기능

- 얼굴 감지 및 랜드마크 인식
- 선택적 영역 블러 처리 (왼쪽, 오른쪽, 입 주변)
- 블러 강도 조절
- FastAPI를 통한 RESTful API 제공

## 설치

```bash
# 가상환경 생성 및 활성화
uv venv
source .venv/bin/activate

# 의존성 설치
uv pip install -e ".[dev]"
```

## 실행

```bash
uvicorn main:app --reload
```

서버는 기본적으로 http://localhost:8000 에서 실행됩니다. 