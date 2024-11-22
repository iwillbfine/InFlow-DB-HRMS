import pandas as pd
from sqlalchemy import create_engine

# 데이터베이스 연결 설정
db_user = 'inflow'
db_password = 'inflow'
db_host = 'localhost'
db_port = '3306'
db_name = 'inflowdb'

# MySQL 연결 설정 (Collation 문제 방지)
engine = create_engine(f"mysql+mysqlconnector://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}?charset=utf8mb4&collation=utf8mb4_general_ci")

# CSV 파일 읽기
csv_file_path = r'C:\InFlow-DB\payroll\public_holiday.csv'  # 경로 앞에 r을 추가하여 raw 문자열로 처리
df = pd.read_csv(csv_file_path)

# 데이터프레임 컬럼명 테이블에 맞게 변경
df = df.rename(columns={"Year": "year", "Month": "month", "Holiday_Count": "day_num"})

# 데이터 삽입
try:
    table_name = 'public_holiday'
    df.to_sql(table_name, con=engine, if_exists='append', index=False)
    print("데이터가 성공적으로 삽입되었습니다.")
except Exception as e:
    print(f"데이터 삽입 중 에러 발생: {e}")
