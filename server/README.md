# Face Blur 서버

얼굴 이미지의 특정 부분을 선택적으로 블러 처리하는 FastAPI 기반 서버입니다.

## 설치 방법

### 1. 사전 준비사항
- Python 3.11 이상
- uv 패키지 매니저

### 2. 가상환경 설정
```bash
# 가상환경 생성
uv venv

# 가상환경 활성화
source server/.venv/bin/activate
```

### 3. 의존성 설치
```bash
# 개발 의존성을 포함한 모든 패키지 설치
uv pip install -e ".[dev]"
```

### 4. 얼굴 인식 모델 다운로드
- shape_predictor_68_face_landmarks.dat 파일이 server 디렉토리에 있는지 확인해주세요.
- 없다면 별도로 제공되는 파일을 다운로드하여 배치해주세요.

## 서버 실행 방법

1. server 디렉토리로 이동:
```bash
cd server
```

2. 서버 실행:
```bash
python server.py
```

서버는 기본적으로 http://0.0.0.0:8000 에서 실행됩니다.

## API 엔드포인트

- POST `/process_image`: 이미지 처리 API
  - 요청 본문: base64로 인코딩된 이미지, 블러 해제할 영역 목록, 블러 강도
  - 응답: base64로 인코딩된 처리된 이미지

## 주의사항

- 서버를 실행하기 전에 반드시 가상환경을 활성화해주세요.
- 이미지 처리 시 얼굴이 명확하게 보이는 사진을 사용해주세요.
