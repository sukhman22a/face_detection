import cv2
import numpy as np
import time
import random
from insightface.app import FaceAnalysis

# -------------------------------------------------------------------
# 1. Landmark Utility Functions
# -------------------------------------------------------------------
def calculate_distance(pt1, pt2):
    """Euclidean distance between two points."""
    return np.linalg.norm(np.array(pt1) - np.array(pt2))

def get_head_pose_ratio(kps):
    """
    Estimates horizontal head rotation using InsightFace 5 keypoints:
    0: Left Eye, 1: Right Eye, 2: Nose Tip, 3: Mouth Left, 4: Mouth Right
    """
    left_eye, right_eye, nose = kps[0], kps[1], kps[2]
    
    dist_nose_to_left_eye = calculate_distance(nose, left_eye)
    dist_nose_to_right_eye = calculate_distance(nose, right_eye)
    
    # Ratio < 0.5 means head turned right; > 2.0 means head turned left
    ratio = dist_nose_to_left_eye / (dist_nose_to_right_eye + 1e-6)
    return ratio

def is_eye_closed(kps):
    """
    Simplified eye closure check using distance relative to eye distance.
    For production, use 68/106 landmark models for exact EAR calculation.
    """
    eye_dist = calculate_distance(kps[0], kps[1])
    mouth_height = calculate_distance(kps[3], kps[4])
    # Returns True if face parameters indicate closed eyes/blink state
    return eye_dist / (mouth_height + 1e-6) < 0.8

# -------------------------------------------------------------------
# 2. Challenge-Response State Machine
# -------------------------------------------------------------------
class ChallengeResponseLiveness:
    def __init__(self, challenges=None):
        self.challenges = challenges or ["TURN_LEFT", "TURN_RIGHT", "BLINK"]
        self.current_challenge_idx = 0
        self.randomize_challenge()
        self.state = "PENDING"  # PENDING, SUCCESS, FAILED
        self.start_time = time.time()
        self.timeout = 10.0  # seconds allowed per challenge

    def randomize_challenge(self):
        self.current_challenge = random.choice(self.challenges)

    def evaluate_frame(self, kps):
        if self.state != "PENDING":
            return self.state

        # Timeout check
        if time.time() - self.start_time > self.timeout:
            self.state = "FAILED"
            return "FAILED (TIMEOUT)"

        ratio = get_head_pose_ratio(kps)

        # Challenge Verification Logic
        if self.current_challenge == "TURN_LEFT" and ratio > 2.2:
            self.state = "SUCCESS"
        elif self.current_challenge == "TURN_RIGHT" and ratio < 0.45:
            self.state = "SUCCESS"
        elif self.current_challenge == "BLINK" and is_eye_closed(kps):
            self.state = "SUCCESS"

        return self.current_challenge if self.state == "PENDING" else "SUCCESS"

# -------------------------------------------------------------------
# 3. Live Webcam Loop
# -------------------------------------------------------------------
app = FaceAnalysis(name='buffalo_l', allowed_modules=['detection'], providers=['CPUExecutionProvider'])
app.prepare(ctx_id=-1, det_size=(640, 640))

cap = cv2.VideoCapture(0)
verifier = ChallengeResponseLiveness()

print(f"--> ACTION REQUIRED: Please {verifier.current_challenge}")

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    faces = app.get(frame)

    if len(faces) == 1:
        face = faces[0]
        kps = face.kps  # 5 keypoints

        # Draw bounding box & keypoints
        bbox = face.bbox.astype(int)
        cv2.rectangle(frame, (bbox[0], bbox[1]), (bbox[2], bbox[3]), (255, 0, 0), 2)
        for pt in kps:
            cv2.circle(frame, (int(pt[0]), int(pt[1])), 3, (0, 255, 0), -1)

        # Check Challenge
        status = verifier.evaluate_frame(kps)

        # Display Prompt
        cv2.putText(frame, f"Prompt: {verifier.current_challenge}", (30, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 255), 2)
        cv2.putText(frame, f"Status: {status}", (30, 90),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.9, 
                    (0, 255, 0) if status == "SUCCESS" else (0, 0, 255), 2)

    elif len(faces) > 1:
        cv2.putText(frame, "Multiple faces detected!", (30, 50), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)

    cv2.imshow("Active Liveness Verification", frame)

    if verifier.state in ["SUCCESS", "FAILED"] or cv2.waitKey(1) & 0xFF == ord('q'):
        time.sleep(1)
        break

cap.release()
cv2.destroyAllWindows()