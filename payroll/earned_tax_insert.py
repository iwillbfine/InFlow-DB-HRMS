import pandas as pd
from sqlalchemy import create_engine

# 데이터베이스 연결 설정
db_user = 'inflow'         # DB 사용자 이름
db_password = 'inflow'      # DB 비밀번호
db_host = 'localhost'       # DB 호스트 (예: localhost)
db_port = '3306'            # MySQL 포트 (기본 3306)
db_name = 'inflowdb'        # 사용할 데이터베이스 이름

# MySQL 연결 문자열에 charset과 collation을 설정 (utf8mb4_general_ci 사용)
engine = create_engine(f"mysql+mysqlconnector://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}?charset=utf8mb4&collation=utf8mb4_general_ci")

# CSV 파일 읽기
csv_file_path = r'C:\InFlow-DB\payroll\earned_income_tax_long.csv'  # 경로 앞에 r을 추가하여 raw 문자열로 처리
df = pd.read_csv(csv_file_path)

# 데이터베이스에 데이터 삽입
table_name = 'earned_income_tax'
df.to_sql(table_name, con=engine, if_exists='append', index=False)

print("데이터가 성공적으로 삽입되었습니다.")
