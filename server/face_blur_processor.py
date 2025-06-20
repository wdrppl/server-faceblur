import cv2
import dlib
import numpy as np
from fastapi import HTTPException

# Face detector + shape predictor 초기화
_DETECTOR = dlib.get_frontal_face_detector()
_PREDICTOR = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")


def apply_blur(image: np.ndarray, strength: int) -> np.ndarray:
    if strength % 2 == 0:
        strength += 1
    return cv2.GaussianBlur(image, (strength, strength), 0)


def blur_face_outline(image: np.ndarray,
                      blur_strength: int,
                      unblur_parts: list = ["Left"],
                      mask_blur_kernel: tuple = (21, 21),
                      mask_blur_sigma: int = 11) -> np.ndarray:
    img = image.copy()
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = _DETECTOR(gray, 1)

    if len(faces) == 0:
        error_message = "사진에서 얼굴을 찾을 수 없습니다. 얼굴이 잘 나오는 사진을 업로드해주세요."
        raise HTTPException(status_code=422, detail=error_message)

    for face in faces:
        shape = _PREDICTOR(gray, face)

        # Calculate face center point and diameter
        face_points = []
        for i in range(68):
            face_points.append((shape.part(i).x, shape.part(i).y))
        face_points_array = np.array(face_points)

        # 얼굴 외곽 점들의 중심과 반지름 계산
        (center_x,
         center_y), radius = cv2.minEnclosingCircle(face_points_array)
        face_diameter = radius * 2

        # 얼굴 지름의 10%를 확장 크기로 사용
        kernel_size = int(face_diameter * 0.1)
        if kernel_size % 2 == 0:
            kernel_size += 1
        kernel = np.ones((kernel_size, kernel_size), np.uint8)

        # Create mask
        mask = np.zeros(img.shape[:2], dtype=np.uint8)
        h, w = mask.shape

        # Generate mask based on angles
        y_coords, x_coords = np.ogrid[:h, :w]

        # Calculate angles from center point (0 to 360 degrees)
        # 0° = 12 o'clock, 90° = 3 o'clock, 180° = 6 o'clock, 270° = 9 o'clock
        angles = (np.arctan2(-(y_coords - center_y), -(x_coords - center_x)) *
                  180 / np.pi - 90) % 360

        # Create mask based on selected parts
        for part in unblur_parts:
            if part == "Right":  # 12 o'clock to 4 o'clock (0° to 120°)
                mask[(angles >= 0) & (angles < 120)] = 255
            elif part == "Mouth":  # 4 o'clock to 8 o'clock (120° to 240°)
                mask[(angles >= 120) & (angles < 240)] = 255
            elif part == "Left":  # 8 o'clock to 12 o'clock (240° to 360°)
                mask[(angles >= 240) & (angles < 360)] = 255

        # Create face area mask with expanded area
        face_mask = np.zeros_like(mask)
        face_hull = cv2.convexHull(face_points_array)
        cv2.fillConvexPoly(face_mask, face_hull, 255)

        # 얼굴 마스크 확장
        face_mask = cv2.dilate(face_mask, kernel, iterations=1)

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
