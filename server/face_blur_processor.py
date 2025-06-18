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
