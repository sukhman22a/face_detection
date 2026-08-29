import numpy as np
import cv2 as cv
from insightface.app import FaceAnalysis 
import sqlite3 as sql 
from pydantic import BaseModel, PositiveInt,ConfigDict, field_validator
from datetime import datetime ,date
import io
import random
def adapt_array(arr):
    out = io.BytesIO()
    np.save(out, arr)
    out.seek(0)
    return sql.Binary(out.read())

def convert_array(text):
    if isinstance(text,memoryview):
        text = text.tobytes()
    out = io.BytesIO(text)
    out.seek(0)
    return np.load(out,allow_pickle=False)

def connect_db():
    
    try:
        sql.register_adapter(np.ndarray, adapt_array)
        sql.register_converter("array", convert_array)
        con = sql.connect('test.db',detect_types=sql.PARSE_DECLTYPES)
        con.execute("PRAGMA foeighn_keys = ON;")
        return con
    except:
        print("error in connected to db")
        ConnectionError

class User(BaseModel):
    id: PositiveInt
    name: str 
    email: str
    embedding: np.ndarray
    model_config = ConfigDict(arbitrary_types_allowed=True)

class Attendence(BaseModel):
    attendence_id: PositiveInt
    embedding: np.ndarray
    confidence: PositiveInt
    id:PositiveInt
    model_config = ConfigDict(arbitrary_types_allowed=True)

    


def user_table(con:sql.connect):
    cur = con.cursor()
    cur.execute("""create table if not exists user (person_id INTEGER PRIMARY KEY
                                                    ,name TEXT NOT NULL 
                                                    ,email TEXT UNIQUE NOT NULL
                                                    ,embedding ARRAY);""")
    con.commit()                         
def attendence_table(con:sql.connect):
    cur = con.cursor()
    cur.execute("""create table if not exists attendence (attendence_id INTEGER PRIMARY KEY AUTOINCREMENT
                                                        ,timestamp TEXT
                                                        ,embedding ARRAY 
                                                        ,confidence INTEGER OPTIONAL
                                                        ,person_id INTEGER
                                                        ,FOREIGN KEY(person_id) REFERENCES user(person_id));""")
    con.commit()        


def init_db():
    con = connect_db()
    user_table(con=con)
    attendence_table(con=con)
    return con

def add_user(user: User,con:sql.connect):
    sql = '''INSERT INTO user(person_id,name,email,embedding)
                VALUES(?,?,?,?)''' 
    cur = con.cursor()
    tmp_data = [i[1] for  i in user]
    cur.execute(sql,tmp_data)
    con.commit()

def add_attendence(attendence: Attendence, con:sql.connect):
    sql='''INSERT INTO attendence (attendence_id,timestamp,embedding,confidence,person_id)
            VALUES(?,?,?,?,?)'''
    cur = con.cursor()
    datetime_now = datetime.now()
    cur.execute(sql,(attendence.attendence_id,datetime.now(),attendence.embedding, attendence.confidence,attendence.id))
    con.commit()
    show_table(cur,"asd")



def show_table(cur,user_or_attendence:str='user'):
    if (user_or_attendence.lower() == 'user'):
        l = cur.execute("select * from user; ").fetchall()
    else:
        l =cur.execute("select * from attendence; ").fetchall()
    print(l)

def get_all_user_embedding(con:sql.connect):
    sql='''select embedding from user;'''
    cur = con.cursor()
    data = cur.execute(sql).fetchall()
    return data

def get_user_by_id(person_id:PositiveInt , con:sql.connect):
    sql = '''select * from user 
            where person_id=?'''
    cur = con.cursor()
    data = cur.execute(sql,(person_id,))
    return data

def delete_user(person_id:PositiveInt,con:sql.connect):
    try:
        sql = '''delete from user
                where person_id= ? '''
        cur = con.cursor()
        cur.execute(sql,(person_id,))
        cur.commit()
        return 
    except sql.OperationalError as e:
        print(e)

def update_embedding(person_id: PositiveInt,embedding,con:sql.connect):
    try:
        sql = """update user 
                set embedding = ? 
                where person_id=?"""
        cur = con.cursor()
        cur.execute(sql,(embedding,person_id,))
        con.commit()
        return
    except sql.OperationalError as e:
        print(e)

def get_daily_report(con:sql.connect,target_date:date):
    date_str = target_date.strftime("%Y-%m-%d")
    cur = con.cursor()
    sql = """select u.person_id u.name u.email a.timestamp a.confidence
            from user u 
            inner join attendence a ON a.id = u.person_id
            where DATE(a.timestamp) = DATE(?)
            order by a.timestamp ASC;
            """
    cur.execute(sql,date_str)
    return cur.fetchall()


def has_marked_today(person_id:PositiveInt,con:sql.connect)-> bool:
    sql = """select 1 from attendence 
            where person_id = ? and DATE(timestamp) = ?
            order by timestamp desc limit 1 """
    now = datetime.now().strftime("%Y-%m-%d")
    cur = con.cursor()
    cur.execute(sql,(person_id,now,))
    record = cur.fetchone()
    print(record)
    return record is not None 



    
    

# def random_srt(length):
#     number = '0123456789'
#     alpha = 'abcdefghijklmnopqrstuvwxyz'
#     id = ''
#     for i in range(0,length,2):
#         id += random.choice(number)
#         id += random.choice(alpha)
#     return id

# # for  i in range(10):
# #     id = int((random.random())*1000)
# #     id1 = int((random.random())*1000)
# #     embedding = [random.random()*1000 for i in range(10)]
# #     userr = User(id=id,name="dsafa",email=random_srt(10),embedding=embedding)
# #     attendence = Attendence(attendence_id=id1,dataTime=datetime.now(), confidence=int(id/id1*1000), id = id ,  embedding=embedding)
# #     con = init_db()
# #     add_user(userr,con=con)
# #     add_attendence(attendence,con)

# # con = init_db()
# # id = con.execute("select person_id from user limit 1").fetchone()
# # has_marked_today(id[0],con=con)

def bytes_to_face(appd: FaceAnalysis,data:bytearray) -> (list,str):
    width = int.from_bytes(data[0:4],byteorder='big')
    height = int.from_bytes(data[4:8],byteorder='big')
    bytesPerRow = int.from_bytes(data[8:12],byteorder='big')
    frame_bytes = data[12:]
    nparr = np.frombuffer(frame_bytes,np.uint8)
    # Reshape accounting for padding (bytes_per_row)
    img_padded = nparr.reshape(height,bytesPerRow)
    # Crop out the padding to get the actual image
    img_gray = img_padded[:,:width]
    img_gray = cv.rotate(img_gray,cv.ROTATE_90_COUNTERCLOCKWISE)
    cv.imwrite("img.png",img_gray)
    if img_gray is None:
        return
    img = cv.cvtColor(img_gray,cv.COLOR_GRAY2BGR)
    faces = appd.get(img)
    if(len(faces)==0):
        # raise ValueError("NO FACESSS")
        print("VALUE ERROR")
        return [],"no Face"
    if(len(faces)>1):
        # raise ValueError("toom MMany Facces")
        print("too many facrss")
        return [],"Too many faces"
    
    return faces[0].embedding,""

def compare_faces(emb1, emb2, threshold=0.65):
    """Compare two embeddings using cosine similarity"""
    similarity = np.dot(emb1, emb2) / (np.linalg.norm(emb1) * np.linalg.norm(emb2))
    return (similarity, similarity > threshold)


# db_conn = init_db()
# users = db_conn.execute("select person_id , embedding from user;").fetchall()
# print(users)
print(datetime.now())