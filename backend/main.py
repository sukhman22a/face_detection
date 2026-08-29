from __future__ import annotations
import asyncio
from fastapi import FastAPI,WebSocket,WebSocketDisconnect
import numpy as np
import time
import cv2 as cv
from insightface.app import FaceAnalysis
import json
import methods as mt
from datetime import datetime
from pydantic import BaseModel, PositiveInt,ConfigDict, field_validator
COLLECTION_DURATION = 5

class User(BaseModel):
    name: str 
    email: str
    phoneNo:str
    randomNumber:str

db_conn = mt.init_db()

app = FastAPI()
appd = None
height_ , width_ =  160,480
appd = FaceAnalysis(
                name='buffalo_l',
                providers=['CPUExecutionProvider'])
appd.prepare(ctx_id=-1, det_size=(height_,width_)) # ctx_id=-1 for CPU, 0 for GPU
    
@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.post('/Register')
async def register_user_details(user: User):
    print(f"user:{user.name}, email: {user.email}, phoneNo:{user.phoneNo}")
    return {
        "status": "success",
        "message": "User details received successfully",
        "data": user
    }
    
    

@app.websocket("/ws/live-feed")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    global appd 
    embeddings = []
    start_time = None
    user = None
    
    try:

        while True:
            if start_time is not None and (time.time()-start_time) >= COLLECTION_DURATION:
                await websocket.send_text("Time limit reached. finalizing the embedding")
                break
            try:
            # Receive raw frame bytes from Flutter
                message =  await asyncio.wait_for(websocket.receive(),timeout=1.0)
            except asyncio.TimeoutError:
                continue
            # print(message)
            if "text" in message:
                try:
                    row =db_conn.execute("select count(*) from user;").fetchone() 

                    id =row[0]+1
                    payload = json.loads(message['text'])
                    user = mt.User(
                        id=id,
                        name = payload.get('name'),
                        email=payload.get('email'),
                        embedding=np.ndarray([0])
                    )
                    start_time = time.time()
                    print(f"User connected {user}")
                except json.JSONDecodeError:
                    pass
            elif "bytes" in message:
                data = message['bytes'] 
                if not data or len(data)<12:
                    continue      
                embedding,err = mt.bytes_to_face(data=data,appd=appd)
                if embeddings is not None:
                    embeddings.append(embedding)
                else:
                    await websocket.send_text(f"{err}")
        if user and embeddings :
            mean_embedding = np.mean(embeddings,axis=0)
            norm = np.linalg.norm(mean_embedding)
            if norm>0:
                mean_embedding = mean_embedding/norm
            user.embedding = mean_embedding
            mt.add_user(user=user,con=db_conn)
            await websocket.send_text(f"Recognized person : {user.name}")
        else:
            await websocket.send_text("THere is some error in embdding operations")
    except WebSocketDisconnect:
        print("Client disconnected")
    finally:
        await websocket.close(code=1000,reason="completed capture duration")
        print("WebSocket closed cleanly")



@app.websocket('/ws/live-feed/Login')
async def login(websocket: WebSocket):
    await websocket.accept()
    global appd
    startTime=None
    try:
        while True:
            if startTime is not None and (time.time() - startTime)>=COLLECTION_DURATION:
                await websocket.send_text("time limit reached")
            try:
                message = await asyncio.wait_for(websocket.receive_bytes(),timeout=1.0)
            except asyncio.TimeoutError:
                continue
            # print(message)
            if len(message) <12 or not message:
                continue 
            
            # print(message)
            startTime = time.time()
            cur_embedding,isError = mt.bytes_to_face(appd=appd,data=message)
            if (len(isError)> 0):
                await websocket.send_text(f"{isError}")
                continue
            users = db_conn.execute("select person_id , embedding from user;").fetchall()
            best_match = None
            max_possiblity =-1.0
            for person_id , embedding in users:
                similarity,_ = mt.compare_faces(embedding,cur_embedding)
                if similarity>max_possiblity:
                    max_possiblity = similarity
                    best_match = person_id
            # print(best_match)
            # print(max_possiblity)
            if(max_possiblity>0.65):
                sql = "select name from user where person_id =? "
                name = db_conn.execute(sql,(best_match,)).fetchone()
                attendence_id = db_conn.execute("select count(*) from attendence").fetchone()
                print(attendence_id[0])
                attendenceId = int(attendence_id[0]) +1
                attendence = mt.Attendence(attendence_id=attendenceId,
                                           confidence=int(max_possiblity*100),

                                           embedding = cur_embedding,
                                           id = best_match
                                           )
                
                mt.add_attendence(attendence=attendence,con=db_conn)
                await websocket.send_text(f"Name : {name}")
                await websocket.close(code=1000, reason="completed capture duration")

                return
            
    except WebSocketDisconnect:
           print("Client disconnected")
    finally:
        try:
            await websocket.close(
                code=1001, reason="completed capture duration"
            )
        except RuntimeError:
            pass  # Connection was already closed
        print("WebSocket closed")
