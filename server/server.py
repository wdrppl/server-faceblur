import base64
from typing import List

import cv2
import numpy as np
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from face_blur_processor import blur_face_outline


class BlurRequest(BaseModel):
    original_image: str  # base64 encoded image
    unblur_parts: List[str]
    blur_strength: int


app = FastAPI()

# CORS 미들웨어 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 배포 시에는 특정 도메인만 허용하도록 수정
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/process_image")
async def process_image(request: BlurRequest):
    try:
        # base64 디코딩
        image_bytes = base64.b64decode(request.original_image)
        image_array = np.frombuffer(image_bytes, np.uint8)
        image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)

        # 이미지 처리
        partial_blur_image = blur_face_outline(
            image=image,
            blur_strength=request.blur_strength,
            unblur_parts=request.unblur_parts)

        # 전체 블러 처리 이미지 생성
        full_blur_image = blur_face_outline(
            image=image, blur_strength=request.blur_strength,
            unblur_parts=[])  # 빈 리스트로 전달하여 모든 부분을 블러 처리

        # 두 이미지를 base64로 인코딩
        _, partial_buffer = cv2.imencode('.jpg', partial_blur_image)
        partial_base64 = base64.b64encode(partial_buffer).decode('utf-8')

        _, full_buffer = cv2.imencode('.jpg', full_blur_image)
        full_base64 = base64.b64encode(full_buffer).decode('utf-8')

        return {
            "partial_blur_image": partial_base64,
            "full_blur_image": full_base64
        }
    except HTTPException as he:
        # HTTPException은 그대로 전달
        raise he
    except Exception as e:
        # 그 외 예외는 500 에러로 처리
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
