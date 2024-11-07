-- 부서 테이블
INSERT INTO department (department_code, department_name, created_at, disbanded_at, min_employee_num, upper_department_code)
VALUES 
('DP001', '경영지원부', '2023-01-10 09:00:00', NULL, 5, NULL),
('DP002', '인사부', '2023-02-15 09:00:00', NULL, 3, 'DP001'),
('DP003', '재무부', '2023-03-01 09:00:00', NULL, 2, 'DP001'),
('DP004', '영업부', '2023-01-20 09:00:00', NULL, 10, NULL),
('DP005', '마케팅부', '2023-04-10 09:00:00', NULL, 6, NULL),
('DP006', 'IT기술지원부', '2023-05-15 09:00:00', NULL, 7, NULL),
('T001', '영업1팀', '2023-04-01 09:00:00', NULL, 4, 'DP004'),
('T002', '영업2팀', '2023-05-10 09:00:00', NULL, 4, 'DP004'),
('T003', '인사관리팀', '2023-06-01 09:00:00', NULL, 2, 'DP002'),
('T004', '재무회계팀', '2023-07-15 09:00:00', NULL, 3, 'DP003'),
('T005', '기획팀', '2023-08-01 09:00:00', NULL, 3, 'DP004'),
('T006', '기술지원팀', '2023-09-01 09:00:00', NULL, 4, 'DP006');

-- 근태상태유형 테이블
INSERT INTO attendance_status_type (attendance_status_type_code, attendance_status_type_name)
VALUES 
('AS001', '정상출근'),
('AS002', '지각'),
('AS003', '조퇴'),
('AS004', '결근'),
('AS005', '휴가'),
('AS006', '병가'),
('AS007', '출장'),
('AS008', '재택근무'),
('AS009', '공가'),
('AS010', '연차'),
('AS011', '퇴근');

-- 직위 테이블
INSERT INTO `position` (position_code, position_name)
VALUES 
('P001', '사원'),
('P002', '대리'),
('P003', '과장'),
('P004', '차장'),
('P005', '부장'),
('P006', '이사'),
('P007', '상무'),
('P008', '전무'),
('P009', '부사장'),
('P010', '사장');

-- 직책 테이블
INSERT INTO `role` (role_code, role_name)
VALUES 
('R001', '팀원'),
('R002', '팀장'),
('R003', '프로젝트 매니저'),
('R004', '본부장'),
('R005', '부서장'),
('R006', '실장'),
('R007', '총괄'),
('R008', '대표'),
('R009', '감사'),
('R010', '고문');

-- 직무 테이블
INSERT INTO duty (duty_code, duty_name)
VALUES 
('D001', '회계'),
('D002', '인사'),
('D003', '영업'),
('D004', '마케팅'),
('D005', '기술지원'),
('D006', '개발'),
('D007', '디자인'),
('D008', '기획'),
('D009', '데이터 분석'),
('D010', '품질 관리');

-- 사원 테이블
INSERT INTO employee (
    employee_id, employee_number, password, gender, name, birth_date, 
    resident_registration_number, email, phone_number, profile_img_url, join_date, 
    join_type, resignation_date, resignation_status, salary, monthly_salary, 
    street_address, detailed_address, postcode, department_code, 
    attendance_status_type_code, position_code, role_code, duty_code
)
VALUES 
(1, 'E001', 'password123', 'MALE', '홍길동', '1985-03-15', '123456-1234567', 
 'hong@company.com', '010-1234-5678', 'https://example.com/profile1.jpg', '2020-01-01 09:00:00', 
 'ROOKIE', NULL, 'N', 50000000, 4000000, '서울 강남구 개포로 109길 5', '101동 101호', '06335', 
 'DP001', 'AS001', 'P001', 'R001', 'D003'),
(2, 'E002', 'password456', 'FEMALE', '김영희', '1990-07-22', '234567-2345678', 
 'kim@company.com', '010-2345-6789', 'https://example.com/profile2.jpg', '2021-03-10 09:00:00', 
 'VETERAN', NULL, 'N', 55000000, 4500000, '서울 강남구 개포로 109길 9', '202동 202호', '06335', 
 'DP002', 'AS002', 'P002', 'R002', 'D004'),
(3, 'E003', 'password789', 'MALE', '박철수', '1982-11-05', '345678-3456789', 
 'park@company.com', '010-3456-7890', 'https://example.com/profile3.jpg', '2018-06-20 09:00:00', 
 'VETERAN', '2024-05-30 18:00:00', 'Y', 70000000, 5000000, '서울 강남구 양재대로 478', '303동 303호', '06358', 
 'DP003', 'AS004', 'P003', 'R003', 'D005'),
(4, 'E004', 'password101', 'FEMALE', '이수정', '1995-12-17', '456789-4567890', 
 'lee@company.com', '010-4567-8901', 'https://example.com/profile4.jpg', '2022-02-25 09:00:00', 
 'ROOKIE', NULL, 'N', 46000000, 3800000, '서울 강남구 삼성로 11', '404동 404호', '06327', 
 'DP004', 'AS003', 'P004', 'R004', 'D006'),
(5, 'E005', 'password102', 'MALE', '최강욱', '1992-09-30', '567890-5678901', 
 'choi@company.com', '010-5678-9012', 'https://example.com/profile5.jpg', '2020-05-10 09:00:00', 
 'ROOKIE', NULL, 'N', 48000000, 3900000, '서울시 강남구 개포로 416', '505동 505호', '06324', 
 'DP005', 'AS002', 'P005', 'R005', 'D007');

-- 가구원관계 테이블 
INSERT INTO family_relationship (family_relationship_code, family_relationship_name)
VALUES 
('FR001', '배우자'),
('FR002', '자녀'),
('FR003', '부모'),
('FR004', '형제자매'),
('FR005', '조부모');

-- 가족구성원 테이블
INSERT INTO family_member (family_member_id, name, birth_date, employee_id, family_relationship_code)
VALUES 
(1, '배수지', '1986-06-15', 1, 'FR001'),
(2, '홍예지', '2015-08-20', 1, 'FR002'),
(3, '김갑수', '1965-02-25', 2, 'FR003'),
(4, '전소민', '2018-01-10', 2, 'FR002'),
(5, '박해진', '1960-11-11', 3, 'FR003'),
(6, '박철민', '1987-04-05', 3, 'FR004'),
(7, '남궁민수', '1994-07-30', 4, 'FR001'),
(8, '남궁빈', '2020-12-18', 4, 'FR002'),
(9, '최수진', '1968-03-22', 5, 'FR003'),
(10, '최강민', '1990-09-12', 5, 'FR004');

-- 학력 테이블
INSERT INTO education (education_id, school_name, admission_date, graduation_date, degree, major, employee_id)
VALUES 
(1, '서울대학교', '2005-03-01 09:00:00', '2009-02-28 09:00:00', '학사', '컴퓨터공학', 1),
(2, '연세대학교', '2006-03-01 09:00:00', '2010-02-28 09:00:00', '학사', '경영학', 2),
(3, '고려대학교', '2007-03-01 09:00:00', '2011-02-28 09:00:00', '학사', '전자공학', 3),
(4, 'KAIST', '2010-03-01 09:00:00', '2014-02-28 09:00:00', '학사', '기계공학', 4),
(5, 'POSTECH', '2008-03-01 09:00:00', '2012-02-28 09:00:00', '학사', '화학공학', 5),
(6, '서울대학교', '2004-03-01 09:00:00', '2008-02-28 09:00:00', '학사', '경제학', 1),
(7, '연세대학교', '2009-03-01 09:00:00', '2013-02-28 09:00:00', '석사', '경영학', 2),
(8, '고려대학교', '2012-03-01 09:00:00', '2016-02-28 09:00:00', '석사', '전자공학', 3),
(9, 'KAIST', '2014-03-01 09:00:00', '2018-02-28 09:00:00', '석사', '기계공학', 4),
(10, 'POSTECH', '2011-03-01 09:00:00', '2015-02-28 09:00:00', '석사', '화학공학', 5);

-- 경력 테이블
INSERT INTO career (career_id, company_name, role_name, join_date, resignation_date, employee_id)
VALUES 
(1, '삼성전자', '소프트웨어 엔지니어', '2010-05-01 09:00:00', '2014-08-31 18:00:00', 1),
(2, 'LG전자', '마케팅 매니저', '2012-03-01 09:00:00', '2016-12-31 18:00:00', 2),
(3, 'SK텔레콤', '네트워크 엔지니어', '2013-06-01 09:00:00', '2017-05-31 18:00:00', 3),
(4, '네이버', '프론트엔드 개발자', '2014-02-01 09:00:00', '2018-07-31 18:00:00', 4),
(5, '카카오', '빅데이터 분석가', '2015-08-01 09:00:00', '2019-11-30 18:00:00', 5),
(6, '삼성전자', '하드웨어 엔지니어', '2011-04-01 09:00:00', '2015-03-31 18:00:00', 1),
(7, 'LG전자', '경영 기획', '2013-07-01 09:00:00', '2017-06-30 18:00:00', 2),
(8, 'SK텔레콤', 'IT 기획자', '2014-09-01 09:00:00', '2018-08-31 18:00:00', 3),
(9, '네이버', 'UX/UI 디자이너', '2015-05-01 09:00:00', '2019-04-30 18:00:00', 4),
(10, '카카오', '모바일 앱 개발자', '2016-03-01 09:00:00', '2020-06-30 18:00:00', 5);

-- 계약서 테이블
INSERT INTO contract (contract_id, contract_type, created_at, file_url, review_status, employee_id, reviewer_id)
VALUES 
(1, '근로계약서', '2024-01-01 09:00:00', 'https://example.com/contract1.pdf', 'N', 1, 5),
(2, '비밀유지서약서', '2024-02-01 09:00:00', 'https://example.com/contract2.pdf', 'Y', 2, 5),
(3, '근로계약서', '2024-03-01 09:00:00', 'https://example.com/contract3.pdf', 'N', 3, 5),
(4, '비밀유지서약서', '2024-04-01 09:00:00', 'https://example.com/contract4.pdf', 'Y', 4, 5),
(5, '근로계약서', '2024-05-01 09:00:00', 'https://example.com/contract5.pdf', 'N', 5, 3),
(6, '비밀유지서약서', '2024-06-01 09:00:00', 'https://example.com/contract6.pdf', 'Y', 1, 5),
(7, '근로계약서', '2024-07-01 09:00:00', 'https://example.com/contract7.pdf', 'N', 2, 5),
(8, '비밀유지서약서', '2024-08-01 09:00:00', 'https://example.com/contract8.pdf', 'Y', 3, 5),
(9, '근로계약서', '2024-09-01 09:00:00', 'https://example.com/contract9.pdf', 'N', 4, 5),
(10, '비밀유지서약서', '2024-10-01 09:00:00', 'https://example.com/contract10.pdf', 'Y', 5, 3);

-- 자격증 테이블
INSERT INTO qualification (qualification_id, qualification_name, qualification_number, qualified_at, issuer, grade_score, employee_id)
VALUES 
(1, '정보처리기사', '123456789', '2023-12-01 09:00:00', '한국산업인력공단', 'PASS', 1),
(2, '컴퓨터활용능력 1급', '987654321', '2024-01-15 09:00:00', '한국산업인력공단', 'PASS', 2),
(3, '한국사능력검정시험 1급', '223344556', '2024-02-20 09:00:00', '국사편찬위원회', 'PASS', 4),
(4, '회계관리 1급', '334455667', '2023-11-10 09:00:00', '한국세무사회', 'PASS', 5),
(5, 'ERP 정보관리사', '445566778', '2024-03-05 09:00:00', '한국경영기술연구원', 'PASS', 1),
(6, '운전면허 1종 보통', '556677889', '2023-08-01 09:00:00', '도로교통공단', 'PASS', 2),
(7, 'SQLD', '667788990', '2024-04-10 09:00:00', '한국정보통신기술협회', 'PASS', 3),
(8, '미용사', '778899001', '2023-07-15 09:00:00', '한국미용사회', 'PASS', 4),
(9, '국가공인 자격증', '889900112', '2024-05-30 09:00:00', '국가자격관리원', 'PASS', 5);

-- 언어 테이블
INSERT INTO language (language_code, language_name)
VALUES 
('EN', 'English'),
('JP', 'Japanese'),
('CN', 'Chinese'),
('FR', 'French'),
('DE', 'German');

-- 어학시험 테이블
INSERT INTO language_test (language_test_id, language_test_name, qualification_number, issuer, qualified_at, grade_score, employee_id, language_code)
VALUES 
(1, 'TOEIC', '123456789', 'ETS', '2023-11-01 09:00:00', '550', 1, 'EN'),
(2, 'JLPT N1', '987654321', 'JLPT', '2024-02-10 09:00:00', 'PASS', 2, 'JP'),
(3, 'HSK 5급', '223344556', 'HSK', '2023-12-05 09:00:00', 'PASS', 3, 'CN'),
(4, 'DELF B2', '334455667', 'CIEP', '2024-01-15 09:00:00', 'PASS', 4, 'FR'),
(5, 'TestDaF', '445566778', 'Goethe-Institut', '2024-03-01 09:00:00', 'C1', 5, 'DE');

-- 징계 및 포상 테이블
INSERT INTO discipline_reward (discipline_reward_id, discipline_reward_name, content, created_at, employee_id)
VALUES 
(1, '포상', '우수사원으로 선정되어 상금 100만원 지급', '2023-12-10 09:00:00', 1),
(2, '징계', '업무 중 상사의 지시 불이행으로 경고처리', '2024-01-05 09:00:00', 2),
(3, '포상', '해외출장 우수 성과를 달성하여 포상 휴가 제공', '2024-02-20 09:00:00', 3),
(4, '징계', '직장 내 폭언으로 경고조치', '2024-03-01 09:00:00', 4),
(5, '포상', '고객 만족도 우수 평가로 인센티브 지급', '2024-04-10 09:00:00', 5),
(6, '징계', '무단결근으로 인한 감봉 조치', '2024-05-15 09:00:00', 1),
(7, '포상', '팀 프로젝트 우수성 인정으로 팀원에게 상장 수여', '2024-06-20 09:00:00', 2),
(8, '징계', '연차 미사용으로 경고처리', '2024-07-25 09:00:00', 3),
(9, '포상', '특별한 기여로 사내 표창장 수여', '2024-08-30 09:00:00', 4),
(10, '징계', '지각 반복으로 경고조치', '2024-09-10 09:00:00', 5);

-- 인사발령 테이블
INSERT INTO appointment (appointment_id, appointed_at, employee_id, authorizer_id, department_code, duty_code, role_code, position_code)
VALUES 
(1, '2024-01-10 09:00:00', 1, 5, 'DP001', 'D003', 'R001', 'P001'),
(2, '2024-02-15 09:00:00', 2, 5, 'DP002', 'D004', 'R002', 'P002'),
(3, '2024-03-01 09:00:00', 3, 5, 'DP003', 'D005', 'R003', 'P003'),
(4, '2024-04-05 09:00:00', 4, 5, 'DP004', 'D006', 'R004', 'P004'),
(5, '2024-05-10 09:00:00', 5, 5, 'DP005', 'D007', 'R005', 'P005');

-- 체크리스트 테이블
INSERT INTO checklist (checklist_id, content, check_status, created_at, employee_id)
VALUES 
(1, '서류 제출', 'N', '2024-01-10 09:00:00', 1),
(2, '근로계약서 서명', 'Y', '2024-02-12 10:30:00', 1),
(3, '비밀유지서약서 서명', 'N', '2024-03-15 14:00:00', 2),
(4, '보안교육 이수', 'Y', '2024-04-01 11:00:00', 2),
(5, '건강검진 결과 제출', 'N', '2024-05-18 16:00:00', 3),
(6, '인사발령 확인', 'Y', '2024-06-20 09:30:00', 3),
(7, '휴가 신청서 제출', 'N', '2024-07-25 10:00:00', 4),
(8, '직무 교육 이수', 'Y', '2024-08-30 13:00:00', 4),
(9, '연말정산 서류 제출', 'N', '2024-09-15 15:30:00', 5),
(10, '퇴직금 수령 확인', 'Y', '2024-10-10 17:00:00', 5);

-- 부서구성원 테이블
INSERT INTO department_member (
    department_member_id, employee_number, name, role_name, email, profile_img_url, 
    phone_number, attendance_status_type_name, manager_status, department_code, employee_id
)
VALUES
(1, 'E001', '홍길동', '팀원', 'hong@company.com', 'https://example.com/profile1.jpg', 
 '010-1234-5678', '정상출근', 'N', 'DP001', 1),
(2, 'E002', '김영희', '팀장', 'kim@company.com', 'https://example.com/profile2.jpg', 
 '010-2345-6789', '지각', 'N', 'DP002', 2),
(3, 'E003', '박철수', '프로젝트 매니저', 'park@company.com', 'https://example.com/profile3.jpg', 
 '010-3456-7890', '결근', 'Y', 'DP003', 3),
(4, 'E004', '이수정', '본부장', 'lee@company.com', 'https://example.com/profile4.jpg', 
 '010-4567-8901', '조퇴', 'N', 'DP004', 4),
(5, 'E005', '최강욱', '부서장', 'choi@company.com', 'https://example.com/profile5.jpg', 
 '010-5678-9012', '지각', 'Y', 'DP005', 5);
 
 -- 휴가유형 테이블
INSERT INTO vacation_type (vacation_type_id, vacation_type_name)
VALUES
(1, '연차'),
(2, '공가'),
(3, '병가'),
(4, '포상휴가'),
(5, '특별휴가');

-- 휴가 정책 테이블
INSERT INTO vacation_policy (vacation_policy_id, vacation_policy_name, allocation_days, paid_status, year, created_at, auto_allocation_cycle, vacation_type_id, policy_register_id)
VALUES
(1, '2024 연차 정책', 15, 'Y', 2024, '2024-01-01 00:00:00', '1Y', 1, 5),
(2, '2024 공가 정책', 5, 'Y', 2024, '2024-01-01 00:00:00', NULL, 2, 5),
(3, '2024 병가 정책', 10, 'Y', 2024, '2024-01-01 00:00:00', NULL, 3, 5),
(4, '2024 포상휴가 정책', 3, 'Y', 2024, '2024-01-01 00:00:00', NULL, 4, 5),
(5, '2024 특별휴가 정책', 7, 'N', 2024, '2024-01-01 00:00:00', NULL, 5, 5);

-- 휴가 테이블
INSERT INTO vacation (
   vacation_id, vacation_name, vacation_left, vacation_used, created_at, expired_at, expiration_status, 
   employee_id, vacation_policy_id, vacation_type_id
) VALUES
(1, '2024년 연차', 15, 5, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 1, 1, 1),
(2, '2024년 연차', 14, 1, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 2, 1, 1),
(3, '2024년 병가', 10, 2, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 3, 2, 3),
(4, '2024년 포상휴가', 7, 0, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 4, 4, 4),
(5, '2024년 특별휴가', 5, 1, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 5, 5, 5),
(6, '2024년 연차', 15, 3, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 1, 1, 1),
(7, '2024년 공가', 3, 1, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 2, 3, 2),
(8, '2024년 연차', 20, 4, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 3, 1, 1),
(9, '2024년 연차', 10, 2, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 4, 1, 1),
(10, '2024년 특별휴가', 5, 0, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 5, 5, 5);

-- 휴가 신청 테이블
INSERT INTO vacation_request (
   vacation_request_id, start_date, end_date, created_at, request_reason, 
   request_status, rejection_reason, canceled_at, cancel_reason, cancel_status, 
   employee_id, vacation_id
)
VALUES 
(1, '2024-12-01 09:00:00', '2024-12-03 18:00:00', '2024-11-01 10:00:00', '휴가를 가고 싶습니다.',
 'ACCEPT', NULL, NULL, NULL, 'N', 1, 1),
(2, '2024-12-10 09:00:00', '2024-12-12 18:00:00', '2024-11-05 11:30:00', '가족 모임 참석',
 'WAIT', NULL, NULL, NULL, 'N', 2, 2),
(3, '2024-12-20 09:00:00', '2024-12-22 18:00:00', '2024-11-10 14:00:00', '긴급한 일로 휴가 요청',
 'REJECT', '일정이 맞지 않아서', NULL, NULL, 'N', 3, 3),
(4, '2024-12-25 09:00:00', '2024-12-27 18:00:00', '2024-11-15 16:00:00', '병원 치료',
 'ACCEPT', NULL, NULL, NULL, 'N', 4, 4),
(5, '2024-12-30 09:00:00', '2024-12-31 18:00:00', '2024-11-20 08:00:00', '휴가',
 'WAIT', NULL, NULL, NULL, 'N', 5, 5);

-- 휴가 신청 증빙자료 테이블 
INSERT INTO vacation_request_file (
   vacation_request_file_id, file_url, vacation_request_id
)
VALUES 
(1, 'https://example.com/files/vacation_request_1.pdf', 1),
(2, 'https://example.com/files/vacation_request_2.pdf', 2),
(3, 'https://example.com/files/vacation_request_3.pdf', 3),
(4, 'https://example.com/files/vacation_request_4.pdf', 4),
(5, 'https://example.com/files/vacation_request_5.pdf', 5);

-- 연차사용촉진정책 테이블
INSERT INTO annual_vacation_promotion_policy (
   annual_vacation_promotion_policy_id, month, day, standard
)
VALUES 
(1, 7, 1, 15),
(2, 10, 1, 10);

-- 근태 신청 유형 테이블
INSERT INTO attendance_request_type (
   attendance_request_type_id, attendance_request_type_name
)
VALUES 
(1, '재택근무'),
(2, '초과근무'),
(3, '출장'),
(4, '파견'),
(5, '휴직');

-- 근태 신청 테이블
INSERT INTO attendance_request (
   attendance_request_id, request_reason, start_date, end_date, created_at, 
   rejection_reason, request_status, canceled_at, cancel_reason, cancel_status, 
   destination, employee_id, attendance_request_type_id
)
VALUES 
(1, '출장으로 인한 근무지 변경', '2024-11-10 09:00:00', '2024-11-10 18:00:00', '2024-11-01 09:00:00', 
 NULL, 'WAIT', NULL, NULL, 'N', '서울시 강남구', 1, 3),
(2, '재택근무 요청', '2024-11-05 09:00:00', '2024-11-05 18:00:00', '2024-11-02 09:30:00', 
 NULL, 'ACCEPT', NULL, NULL, 'N', NULL, 5, 1),
(3, '초과근무 요청', '2024-11-07 19:00:00', '2024-11-07 22:00:00', '2024-11-03 10:00:00', 
 NULL, 'ACCEPT', NULL, NULL, 'N', NULL, 3, 2),
(4, '파견 근무 요청', '2024-11-12 09:00:00', '2024-12-12 18:00:00', '2024-11-04 08:00:00', 
 NULL, 'ACCEPT', NULL, NULL, 'N', '부산 사무소', 4, 4),
(5, '휴직 신청', '2024-11-02 00:00:00', '2024-11-05 23:59:59', '2024-11-06 09:15:00', 
 NULL, 'ACCEPT', NULL, NULL, 'N', NULL, 1, 5);
 
 -- 근태 신청 증빙자료 테이블
 INSERT INTO attendance_request_file (
   attendance_request_file_id, file_url, attendance_request_id
)
VALUES 
(1, 'https://example.com/file1.pdf', 1),
(2, 'https://example.com/file2.pdf', 2),
(3, 'https://example.com/file3.pdf', 3),
(4, 'https://example.com/file4.pdf', 4),
(5, 'https://example.com/file5.pdf', 5);

-- 출퇴근 테이블
INSERT INTO commute (
   commute_id, start_time, end_time, remote_status, overtime_status, employee_id, attendance_request_id
)
VALUES 
(1, '2024-11-01 09:00:00', '2024-11-01 18:00:00', 'N', 'N', 1, NULL),
(2, '2024-11-01 08:30:00', '2024-11-01 17:30:00', 'N', 'N', 2, NULL),
(3, '2024-11-02 09:15:00', '2024-11-02 18:15:00', 'N', 'Y', 3, 3),
(4, '2024-11-02 09:00:00', '2024-11-02 18:00:00', 'N', 'N', 4, NULL),
(5, '2024-11-03 09:00:00', '2024-11-03 17:00:00', 'Y', 'N', 5, 2);

-- 휴복직 테이블
INSERT INTO leave_return (
   leave_return_id, start_date, end_date, employee_id, attendance_request_id
)
VALUES 
(1, '2024-11-02 00:00:00', '2024-11-05 23:59:59', 1, 5);

-- 출장파견 테이블
INSERT INTO business_trip (
   business_trip_id, start_date, end_date, trip_type, destination, employee_id, attendance_request_id
)
VALUES 
(1, '2024-11-12 09:00:00', '2024-12-12 18:00:00', 'DISPATCH', '부산 사무소', 4, 4);

-- 
INSERT INTO grade (
   grade_id, grade_name
)
VALUES 
(1, 'S'),
(2, 'A'),
(3, 'B'),
(4, 'C'),
(5, 'D');