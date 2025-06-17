import base64
from typing import List

import cv2
import dlib
import numpy as np
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Face detector + shape predictor 초기화
detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")


class BlurRequest(BaseModel):
    image: str  # base64 encoded image
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


def apply_blur(image: np.ndarray, strength: int) -> np.ndarray:
    if strength % 2 == 0:
        strength += 1
    return cv2.GaussianBlur(image, (strength, strength), 0)


def blur_face_outline(image: np.ndarray,
                      blur_strength: int = 66,
                      unblur_parts: list = ["Left"],
                      mask_blur_kernel: tuple = (21, 21),
                      mask_blur_sigma: int = 11) -> np.ndarray:
    img = image.copy()
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = detector(gray, 1)

    if len(faces) == 0:
        error_message = "사진에서 얼굴을 찾을 수 없습니다. 얼굴이 잘 나오는 사진을 업로드해주세요."
        raise HTTPException(status_code=422, detail=error_message)

    for face in faces:
        shape = predictor(gray, face)

        # Calculate face center point
        face_points = []
        for i in range(68):
            face_points.append((shape.part(i).x, shape.part(i).y))

        center_x = sum(p[0] for p in face_points) // len(face_points)
        center_y = sum(p[1] for p in face_points) // len(face_points)

        # Create mask
        mask = np.zeros(img.shape[:2], dtype=np.uint8)
        h, w = mask.shape

        # Generate mask based on angles
        y_coords, x_coords = np.ogrid[:h, :w]
        angles = np.arctan2(-(y_coords - center_y),
                            x_coords - center_x) * 180 / np.pi

        # Create mask based on selected parts
        for part in unblur_parts:
            if part == "Right":  # 12 o'clock to 4 o'clock
                mask[(angles >= -30) & (angles < 90)] = 255
            elif part == "Left":  # 4 o'clock to 8 o'clock
                mask[(angles >= 90) & (angles < 210)] = 255
            elif part == "Mouth":  # 8 o'clock to 12 o'clock
                mask[(angles >= 210) | (angles < -30)] = 255

        # Create face area mask
        face_mask = np.zeros_like(mask)
        face_hull = cv2.convexHull(np.array(face_points, np.int32))
        cv2.fillConvexPoly(face_mask, face_hull, 255)

        # Intersection of face area and angle mask
        mask = cv2.bitwise_and(mask, face_mask)

        # Smooth mask edges
        mask = cv2.GaussianBlur(mask, mask_blur_kernel, mask_blur_sigma)

        # Apply blur effect
        blurred_img = apply_blur(img, blur_strength)

        # Apply blur effect using mask
        mask_3channel = mask[:, :, np.newaxis] / 255.0
        result = (img * mask_3channel + blurred_img *
                  (1 - mask_3channel)).astype(np.uint8)

        return result

    return img


@app.post("/process_image")
async def process_image(request: BlurRequest):
    try:
        # base64 디코딩
        image_bytes = base64.b64decode(request.image)
        image_array = np.frombuffer(image_bytes, np.uint8)
        image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)

        # 이미지 처리
        processed_image = blur_face_outline(
            image=image,
            blur_strength=request.blur_strength,
            unblur_parts=request.unblur_parts)

        # 처리된 이미지를 base64로 인코딩
        _, buffer = cv2.imencode('.jpg', processed_image)
        processed_base64 = base64.b64encode(buffer).decode('utf-8')

        return {"processed_image": processed_base64}
    except HTTPException as he:
        # HTTPException은 그대로 전달
        raise he
    except Exception as e:
        # 그 외 예외는 500 에러로 처리
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
