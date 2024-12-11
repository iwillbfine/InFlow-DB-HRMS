-- 회사 테이블
INSERT INTO company (company_id, company_name, ceo, ceo_signature, business_registration_number, company_address, company_phone_number, company_stamp_url, company_logo_url)
VALUES
(1, '파도파도', '홍길동', 'https://inflow-company.s3.ap-northeast-2.amazonaws.com/ceo_signature.png', '229-81-30104', '서울 동작구 보라매로 87', '02-1234-5678', 'https://inflow-company.s3.ap-northeast-2.amazonaws.com/company_stamp.png', 'https://inflow-company.s3.ap-northeast-2.amazonaws.com/company_logo.png');

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

DELIMITER //
CREATE TRIGGER after_employee_insert
AFTER INSERT ON employee
FOR EACH ROW
BEGIN
    DECLARE role_name VARCHAR(255) DEFAULT '팀원';
    DECLARE attendance_status_type_name VARCHAR(255) DEFAULT '정상출근';
    DECLARE target_department_code VARCHAR(255);

    -- position_code에 따라 role_name 설정
    SET role_name = CASE NEW.position_code
        WHEN 'P001' THEN '사원'
        WHEN 'P002' THEN '대리'
        WHEN 'P003' THEN '과장'
        WHEN 'P004' THEN '차장'
        WHEN 'P005' THEN '부장'
        WHEN 'P006' THEN '이사'
        WHEN 'P007' THEN '상무'
        WHEN 'P008' THEN '전무'
        WHEN 'P009' THEN '부사장'
        WHEN 'P010' THEN '사장'
        ELSE '기타'
    END;

    -- attendance_status_type_code에 따라 attendance_status_type_name 설정
    SET attendance_status_type_name = CASE NEW.attendance_status_type_code
        WHEN 'AS001' THEN '정상출근'
        WHEN 'AS002' THEN '지각'
        WHEN 'AS003' THEN '조퇴'
        WHEN 'AS004' THEN '결근'
        WHEN 'AS005' THEN '휴가'
        WHEN 'AS006' THEN '병가'
        WHEN 'AS007' THEN '출장'
        WHEN 'AS008' THEN '재택근무'
        WHEN 'AS009' THEN '공가'
        WHEN 'AS010' THEN '연차'
        WHEN 'AS011' THEN '퇴근'
        ELSE '정상출근'
    END;

    -- position_code가 P005(부장)인 경우, 하위 부서로 할당하지 않음
    IF NEW.position_code = 'P005' THEN
        SET target_department_code = NEW.department_code;
    ELSE
        -- 상위 부서에서 하위 부서를 결정 (임의 기준으로 결정)
        SET target_department_code = (
            SELECT d.department_code
            FROM department d
            WHERE d.upper_department_code = NEW.department_code
            LIMIT 1
        );

        -- 하위 부서가 없는 경우, 기존 상위 부서를 그대로 사용
        IF target_department_code IS NULL THEN
            SET target_department_code = NEW.department_code;
        END IF;
    END IF;

    -- department_member 테이블에 새 사원 정보 추가
    INSERT INTO department_member (
        employee_number,
        name,
        role_name,
        email,
        profile_img_url,
        phone_number,
        attendance_status_type_name,
        manager_status,
        department_code,
        employee_id
    )
    VALUES (
        NEW.employee_number,
        NEW.name,
        role_name,
        NEW.email,
        NEW.profile_img_url,
        NEW.phone_number,
        attendance_status_type_name,
        CASE
            WHEN NEW.position_code IN ('P005') THEN 'Y'
            ELSE 'N'
        END,
        target_department_code,
        NEW.employee_id
    );
END//
DELIMITER ;



-- 사원 테이블
INSERT INTO employee (
    employee_id, employee_number, employee_role, password, gender, name, birth_date,
    email, phone_number, profile_img_url, join_date,
    join_type, resignation_date, resignation_status, salary, monthly_salary,
    street_address, detailed_address, postcode, department_code,
    attendance_status_type_code, position_code, role_code, duty_code
)

VALUES
    (1, '199901234', 'ADMIN', '$2a$10$gEF/iaV.jiHyAL0c8TZ2Aufen4ovoQyZX9ipoTKXUSIZ8h9XDlmFa', 'MALE', '홍길동', '1971-03-15',
     'hong@company.com', '010-1234-5678', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_admin.png', '2020-01-01 09:00:00',
     'ROOKIE', NULL, 'N', 50000000, 4000000, '서울 강남구 개포로 109길 5', '101동 101호', '06335',
     'DP001', 'AS001', 'P010', 'R008', 'D003'),
    (2, '202100001', 'EMPLOYEE', 'password456', 'FEMALE', '김영희', '1990-07-22',
     'kim@company.com', '010-2345-6789', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-03-10 09:00:00',
     'VETERAN', NULL, 'N', 55000000, 4500000, '서울 강남구 개포로 109길 9', '202동 202호', '06335',
     'DP002', 'AS002', 'P002', 'R002', 'D004'),
    (3, '201800001', 'EMPLOYEE', 'password789', 'MALE', '박철수', '1982-11-05',
     'park@company.com', '010-3456-7890', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2018-06-20 09:00:00',
     'VETERAN', '2024-05-30 18:00:00', 'Y', 70000000, 5000000, '서울 강남구 양재대로 478', '303동 303호', '06358',
     'DP002', 'AS004', 'P003', 'R003', 'D005'),
    (4, '202200001', 'EMPLOYEE', 'password101', 'FEMALE', '이수정', '1995-12-17',
     'lee@company.com', '010-4567-8901', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-02-25 09:00:00',
     'ROOKIE', NULL, 'N', 46000000, 3800000, '서울 강남구 삼성로 11', '404동 404호', '06327',
     'DP002', 'AS003', 'P004', 'R004', 'D006'),
     
-- 인사팀 부장
    (5, '201000002', 'MANAGER', '$2a$10$gEF/iaV.jiHyAL0c8TZ2Aufen4ovoQyZX9ipoTKXUSIZ8h9XDlmFa', 'MALE', '최강욱', '1982-09-30',
     'choi@company.com', '010-5678-9012', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2020-05-10 09:00:00',
     'ROOKIE', NULL, 'N', 48000000, 3900000, '서울시 강남구 개포로 416', '505동 505호', '06324',
     'DP002', 'AS002', 'P005', 'R005', 'D004'),
-- 인사팀 직원
     (6, '201901234', 'HR', '$2a$10$gEF/iaV.jiHyAL0c8TZ2Aufen4ovoQyZX9ipoTKXUSIZ8h9XDlmFa', 'FEMALE', '윤지혜', '1993-05-12',
     'yoon@company.com', '010-6789-0123', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_hr.png', '2019-04-01 09:00:00',
     'VETERAN', NULL, 'N', 47000000, 3900000, '서울 강남구 논현로 509', '606동 606호', '06349',
     'DP002', 'AS001', 'P002', 'R001', 'D002'),
     
-- 7번 ~ 26번 사원: IT기술지원부 사원(총 20명)

--  IT 기술 지원 팀 부장
    (7, '201301234', 'MANAGER', '$2a$10$gEF/iaV.jiHyAL0c8TZ2Aufen4ovoQyZX9ipoTKXUSIZ8h9XDlmFa', 'MALE', '한상민', '1984-10-21',
     'han@company.com', '010-7890-1234', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_man.png', '2013-03-15 09:00:00',
     'VETERAN', NULL, 'N', 36000000, 3000000, '서울 강남구 도산대로 311', '707동 707호', '06351',
     'DP006', 'AS001', 'P005', 'R005', 'D008'),
-- 3년차 개발직 대리
   (8, '202101234', 'EMPLOYEE', '$2a$10$gEF/iaV.jiHyAL0c8TZ2Aufen4ovoQyZX9ipoTKXUSIZ8h9XDlmFa', 'MALE', '서진우', '1995-07-15',
     'seo@company.com', '010-8901-2345', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_manager.png', '2021-01-10 09:00:00',
     'VETERAN', NULL, 'N', 90000000, 7500000, '서울 강남구 압구정로 102', '808동 808호', '06353',
     'DP006', 'AS001', 'P002', 'R001', 'D006'),
--  9번 ~ 26번 사원: IT기술지원부 사원

  	 (9, '202100002', 'EMPLOYEE', '$2a$10$gEF/iaV.jiHyAL0c8TZ2Aufen4ovoQyZX9ipoTKXUSIZ8h9XDlmFa', 'FEMALE', '장은희', '1995-01-22',
     'jang@company.com', '010-9012-3456', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_woman.png', '2021-09-30 09:00:00',
     'ROOKIE', NULL, 'N', 45000000, 3700000, '경기도 수원시 영통구 광교로 55', '102동 202호', '16704',
     'DP006', 'AS001', 'P001', 'R001', 'D006'),
    (10, '202000003', 'EMPLOYEE', 'password107', 'MALE', '조우주', '1991-03-14',
     'leej@company.com', '010-2345-6780', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2020-02-10 09:00:00',
     'VETERAN', NULL, 'N', 47000000, 3900000, '경기도 성남시 분당구 백현로 97', '201동 1502호', '13518',
     'DP006', 'AS002', 'P001', 'R002', 'D006'),
    (11, '202200002', 'EMPLOYEE', 'password108', 'FEMALE', '박하늘', '1996-06-20',
     'parkh@company.com', '010-3456-7892', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-07-25 09:00:00',
     'ROOKIE', NULL, 'N', 46000000, 3800000, '경기도 고양시 일산동구 정발산로 24', '302동 302호', '10405',
     'DP006', 'AS003', 'P001', 'R001', 'D005'),
    (12, '202100003', 'EMPLOYEE', 'password109', 'MALE', '김민수', '1993-08-30',
     'kimmin@company.com', '010-4567-8903', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-04-20 09:00:00',
     'ROOKIE', NULL, 'N', 46000000, 3700000, '경기도 용인시 기흥구 흥덕2로 123', '402동 402호', '16950',
     'DP006', 'AS001', 'P001', 'R002', 'D006'),
    (13, '202100004', 'EMPLOYEE', 'password110', 'FEMALE', '최은정', '1994-02-11',
     'choeun@company.com', '010-5678-9014', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-05-15 09:00:00',
     'ROOKIE', NULL, 'N', 46000000, 3700000, '경기도 부천시 부천로 50', '302동 505호', '14556',
     'DP006', 'AS001', 'P001', 'R002', 'D005'),
    (14, '202200003', 'EMPLOYEE', 'password111', 'MALE', '신동엽', '1992-12-20',
     'shin@company.com', '010-6789-0125', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-01-10 09:00:00',
     'ROOKIE', NULL, 'N', 47000000, 3800000, '경기도 평택시 평택로 155', '101동 1201호', '17747',
     'DP006', 'AS002', 'P001', 'R001', 'D006'),
    (15, '202200004', 'EMPLOYEE', 'password112', 'FEMALE', '정윤아', '1995-07-18',
     'jung@company.com', '010-7890-1236', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-03-25 09:00:00',
     'ROOKIE', NULL, 'N', 45000000, 3700000, '경기도 안양시 동안구 관악대로 141', '101동 703호', '13931',
     'DP006', 'AS003', 'P001', 'R002', 'D006'),
    (16, '201900002', 'EMPLOYEE', 'password113', 'MALE', '오지현', '1989-04-02',
     'ohji@company.com', '010-8901-2347', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2019-07-01 09:00:00',
     'VETERAN', NULL, 'N', 48000000, 3800000, '경기도 남양주시 화도읍 마석로 56', '205동 808호', '12224',
     'DP006', 'AS001', 'P001', 'R003', 'D005'),
    (17, '202200005', 'EMPLOYEE', 'password114', 'FEMALE', '박수현', '1996-10-05',
     'parksh123@company.com', '010-9012-3458', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-04-12 09:00:00',
     'ROOKIE', NULL, 'N', 47000000, 3900000, '경기도 의정부시 시민로 23', '103동 1103호', '11652',
     'DP006', 'AS003', 'P001', 'R001', 'D006'),
    (18, '202000004', 'EMPLOYEE', 'password115', 'MALE', '이하늘', '1992-11-30',
     'leehn@company.com', '010-2345-6789', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2020-08-01 09:00:00',
     'VETERAN', NULL, 'N', 46000000, 3800000, '경기도 파주시 교하로 240', '505동 505호', '10932',
     'DP006', 'AS002', 'P001', 'R003', 'D006'),
    (19, '202200006', 'EMPLOYEE', 'password116', 'FEMALE', '김은서', '1998-01-12',
     'kimse@company.com', '010-3456-7890', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-09-15 09:00:00',
     'ROOKIE', NULL, 'N', 45000000, 3700000, '경기도 광명시 광명로 121', '101동 303호', '14305',
     'DP006', 'AS001', 'P001', 'R001', 'D005'),
    (20, '202100005', 'EMPLOYEE', 'password117', 'MALE', '정민호', '1993-03-03',
     'jungmh@company.com', '010-5678-9011', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-06-25 09:00:00',
     'ROOKIE', NULL, 'N', 47000000, 3900000, '경기도 하남시 미사대로 250', '301동 1004호', '12918',
     'DP006', 'AS002', 'P001', 'R002', 'D006'),

-- 21번 ~ 26번 사원: IT기술지원부 사원 (경기도 지역 주소와 사번 설정 완료)
    (21, '202110006', 'EMPLOYEE', 'password118', 'FEMALE', '윤채은', '1997-04-25',
     'yoonce@company.com', '010-6789-0122', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-10-01 09:00:00',
     'ROOKIE', NULL, 'N', 46000000, 3700000, '경기도 김포시 김포한강3로 210', '502동 1502호', '10003',
     'DP006', 'AS001', 'P001', 'R001', 'D005'),
    (22, '202010005', 'EMPLOYEE', 'password119', 'MALE', '차정훈', '1990-09-11',
     'chajh@company.com', '010-7890-1233', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2020-12-15 09:00:00',
     'VETERAN', NULL, 'N', 48000000, 3800000, '경기도 군포시 산본로 200', '305동 1003호', '15820',
     'DP006', 'AS001', 'P001', 'R001', 'D008'),
    (23, '202100007', 'EMPLOYEE', 'password120', 'FEMALE', '이선영', '1994-07-30',
     'leese@company.com', '010-8901-2344', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-05-20 09:00:00',
     'ROOKIE', NULL, 'N', 47000000, 3800000, '경기도 의왕시 철도박물관로 112', '101동 503호', '16071',
     'DP006', 'AS002', 'P001', 'R001', 'D005'),
    (24, '201910003', 'EMPLOYEE', 'password121', 'MALE', '김재환', '1988-02-17',
     'kimjh123@company.com', '010-3456-7891', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2019-08-25 09:00:00',
     'VETERAN', NULL, 'N', 49000000, 3800000, '경기도 양주시 고덕로 150', '202동 902호', '11487',
     'DP006', 'AS001', 'P001', 'R001', 'D008'),
    (25, '202200007', 'EMPLOYEE', 'password122', 'FEMALE', '박수영', '1995-06-05',
     'parksy@company.com', '010-4567-8902', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-03-18 09:00:00',
     'ROOKIE', NULL, 'N', 46000000, 3700000, '경기도 구리시 건원대로 230', '303동 1305호', '11915',
     'DP006', 'AS003', 'P001', 'R001', 'D005'),
    (26, '202000006', 'EMPLOYEE', 'password123', 'MALE', '최용준', '1989-10-27',
     'choiyj123@company.com', '010-5678-9013', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2020-06-12 09:00:00',
     'VETERAN', NULL, 'N', 47000000, 3900000, '경기도 포천시 소흘읍 송우리 345', '701동 104호', '11135',
     'DP006', 'AS002', 'P001', 'R001', 'D006'),

-- 경기도 한정 27번~50번
	(27, '202200008', 'EMPLOYEE', 'password124', 'FEMALE', '정가은', '1995-11-18',
	'jungge@company.com', '010-6789-1234', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-01-15 09:00:00',
	'ROOKIE', NULL, 'N', 45000000, 3700000, '경기도 안산시 단원구 중앙대로 100', '101동 1203호', '15357',
	'DP003', 'AS001', 'P001', 'R001', 'D003'),
	(28, '202100008', 'EMPLOYEE', 'password125', 'MALE', '김도훈', '1993-04-12',
	'kimdh@company.com', '010-7890-1235', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-04-01 09:00:00',
	'VETERAN', NULL, 'N', 48000000, 3800000, '경기도 화성시 동탄대로 50', '102동 904호', '18590',
	'DP004', 'AS002', 'P002', 'R002', 'D004'),
	(29, '202000007', 'EMPLOYEE', 'password126', 'FEMALE', '최현아', '1987-08-15',
	'choiha@company.com', '010-1234-5679', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2020-06-20 09:00:00',
	'VETERAN', NULL, 'N', 52000000, 4000000, '경기도 남양주시 와부읍 덕소로 150', '203동 1202호', '12276',
	'DP002', 'AS001', 'P003', 'R003', 'D002'),
	(30, '202100009', 'EMPLOYEE', 'password127', 'MALE', '이준석', '1994-10-02',
	'leejs@company.com', '010-2345-6781', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-09-25 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3700000, '경기도 평택시 서재로 230', '501동 1103호', '17714',
	'DP001', 'AS001', 'P001', 'R001', 'D001'),
	(31, '202100010', 'EMPLOYEE', 'password128', 'FEMALE', '문하영', '1996-07-18',
	'moonhy@company.com', '010-3456-7892', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-05-30 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3800000, '경기도 광주시 역동로 89', '701동 503호', '12780',
	'DP005', 'AS001', 'P002', 'R001', 'D008'),
	(32, '202100011', 'EMPLOYEE', 'password129', 'MALE', '강성민', '1992-09-27',
	'kangsm@company.com', '010-4567-8903', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-03-10 09:00:00',
	'VETERAN', NULL, 'N', 49000000, 3900000, '경기도 고양시 덕양구 행신로 45', '203동 1102호', '10594',
	'DP004', 'AS002', 'P001', 'R002', 'D009'),
	(33, '202100012', 'EMPLOYEE', 'password130', 'FEMALE', '한예은', '1998-06-11',
	'hanyee@company.com', '010-5678-9014', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-06-01 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3800000, '경기도 하남시 미사대로 200', '401동 1204호', '12918',
	'DP001', 'AS001', 'P001', 'R001', 'D001'),
	(34, '202000008', 'EMPLOYEE', 'password131', 'MALE', '윤지혁', '1990-12-05',
	'yoonjh@company.com', '010-6789-0125', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2020-11-12 09:00:00',
	'VETERAN', NULL, 'N', 53000000, 4000000, '경기도 용인시 기흥구 흥덕로 200', '302동 1001호', '16950',
	'DP003', 'AS003', 'P002', 'R003', 'D003'),
	(35, '202100013', 'EMPLOYEE', 'password132', 'FEMALE', '강미정', '1995-03-23',
	'kangmj@company.com', '010-7890-1236', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-02-15 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3800000, '경기도 파주시 와석로 78', '201동 805호', '10925',
	'DP005', 'AS001', 'P001', 'R001', 'D008'),
	(36, '202200009', 'EMPLOYEE', 'password133', 'MALE', '박상진', '1993-08-19',
	'parksj232@company.com', '010-8901-2347','https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-03-05 09:00:00',
	'ROOKIE', NULL, 'N', 48000000, 3800000, '경기도 안양시 동안구 관악대로 145', '103동 1202호', '13929',
	'DP003', 'AS001', 'P003', 'R001', 'D005'),
	(37, '202000009', 'EMPLOYEE', 'password134', 'FEMALE', '오지민', '1994-01-29',
	'ohjm@company.com', '010-9012-3458', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2020-09-10 09:00:00',
	'VETERAN', NULL, 'N', 47000000, 3900000, '경기도 시흥시 배곧로 100', '205동 1404호', '15010',
	'DP002', 'AS003', 'P001', 'R002', 'D006'),
	(38, '202200010', 'EMPLOYEE', 'password135', 'MALE', '김현우', '1991-07-13',
	'kimhw@company.com', '010-2345-6789', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-01-20 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '경기도 양평군 양근로 245', '201동 506호', '12507',
	'DP001', 'AS001', 'P001', 'R001', 'D001'),
	(39, '202100014', 'EMPLOYEE', 'password136', 'FEMALE', '박지수', '1995-11-30',
	'parksj@company.com', '010-3456-7893', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-05-21 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '경기도 광명시 오리로 90', '104동 803호', '14320',
	'DP004', 'AS002', 'P002', 'R002', 'D007'),
	(40, '202200011', 'EMPLOYEE', 'password137', 'MALE', '서은호', '1998-02-18',
	'seoho@company.com', '010-4567-8904', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-06-12 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3800000, '경기도 오산시 경기대로 220', '501동 1106호', '18129',
	'DP005', 'AS001', 'P001', 'R001', 'D008'),
	(41, '202000010', 'EMPLOYEE', 'password138', 'FEMALE', '나민정', '1996-05-22',
	'namj@company.com', '010-5678-9015', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2020-12-03 09:00:00',
	'VETERAN', NULL, 'N', 47000000, 3800000, '경기도 의정부시 시민로 80', '601동 1407호', '11650',
	'DP003', 'AS002', 'P003', 'R002', 'D009'),
	(42, '202100015', 'EMPLOYEE', 'password139', 'MALE', '조현수', '1997-10-11',
	'johs@company.com', '010-6789-0126', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-11-20 09:00:00',
	'ROOKIE', NULL, 'N', 48000000, 3900000, '경기도 광주시 성남로 250', '102동 703호', '12765',
	'DP004', 'AS001', 'P002', 'R001', 'D003'),
	(43, '202100016', 'EMPLOYEE', 'password140', 'FEMALE', '김나리', '1994-06-08',
	'kimnr@company.com', '010-7890-1237', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-08-15 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3800000, '경기도 안산시 상록구 사동로 40', '305동 506호', '15324',
	'DP005', 'AS003', 'P001', 'R001', 'D004'),
	(44, '202100017', 'EMPLOYEE', 'password141', 'MALE', '이동훈', '1993-02-04',
	'leodh@company.com', '010-8901-2348', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-02-10 09:00:00',
	'VETERAN', NULL, 'N', 47000000, 3900000, '경기도 고양시 일산동구 백마로 150', '202동 1402호', '10425',
	'DP001', 'AS001', 'P002', 'R002', 'D006'),
	(45, '202200012', 'EMPLOYEE', 'password142', 'FEMALE', '최유정', '1998-09-05',
	'choiyj@company.com', '010-2234-5678','https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-03-19 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '경기도 시흥시 은행로 99', '203동 1006호', '15027',
	'DP004', 'AS002', 'P003', 'R003', 'D005'),
	(46, '202100018', 'EMPLOYEE', 'password143', 'MALE', '박준영', '1992-08-24',
	'parkjy123@company.com', '010-3456-7895','https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-09-30 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '경기도 성남시 수정구 남문로 40', '101동 1208호', '13101',
	'DP003', 'AS001', 'P001', 'R002', 'D008'),
	(47, '202200013', 'EMPLOYEE', 'password144', 'FEMALE', '김혜진', '1997-05-21',
	'kimhj@company.com', '010-4567-8906', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-05-18 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '경기도 군포시 군포로 160', '102동 1001호', '15855',
	'DP001', 'AS003', 'P001', 'R001', 'D003'),
	(48, '202100019', 'EMPLOYEE', 'password145', 'MALE', '이태우', '1989-01-28',
	'leetw@company.com', '010-5678-9017', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-04-22 09:00:00',
	'VETERAN', NULL, 'N', 49000000, 3900000, '경기도 안성시 금광로 121', '304동 1205호', '17539',
	'DP005', 'AS002', 'P002', 'R002', 'D004'),
	(49, '202200014', 'EMPLOYEE', 'password146', 'FEMALE', '조혜진', '1996-04-02',
	'johj@company.com', '010-6789-0128', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-06-30 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '경기도 화성시 봉담읍 와우로 40', '205동 503호', '18397',
	'DP002', 'AS001', 'P003', 'R001', 'D006'),
	(50, '202200015', 'EMPLOYEE', 'password147', 'MALE', '한세준', '1993-11-29',
	'hansj@company.com', '010-7890-1239', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-07-10 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '경기도 포천시 이동면 경기동로 90', '701동 1203호', '11130',
	'DP005', 'AS002', 'P001', 'R001', 'D004'),

-- 51번 ~ 65번 사원: 인천광역시 주소와 DP006 제외 부서 설정
	(51, '202200016', 'EMPLOYEE', 'password148', 'FEMALE', '이민아', '1995-09-22',
	'leema@company.com', '010-6789-1230', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-01-25 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '인천광역시 남동구 구월로 30', '101동 401호', '21574',
	'DP001', 'AS001', 'P001', 'R001', 'D002'),
	(52, '202100020', 'EMPLOYEE', 'password149', 'MALE', '조태호', '1992-05-10',
	'joth@company.com', '010-7890-1231', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-02-14 09:00:00',
	'VETERAN', NULL, 'N', 49000000, 3800000, '인천광역시 서구 청라대로 100', '202동 1102호', '22741',
	'DP003', 'AS002', 'P002', 'R002', 'D003'),
	(53, '202100021', 'EMPLOYEE', 'password150', 'FEMALE', '박유진', '1993-06-18',
	'parkjy@company.com', '010-1234-5671', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-09-05 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '인천광역시 부평구 경원대로 55', '302동 202호', '21405',
	'DP005', 'AS003', 'P001', 'R001', 'D004'),
	(54, '202100022', 'EMPLOYEE', 'password151', 'MALE', '김민호', '1991-07-23',
	'kimmh@company.com', '010-2345-6782', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-03-12 09:00:00',
	'VETERAN', NULL, 'N', 47000000, 3900000, '인천광역시 계양구 계양대로 170', '401동 804호', '21063',
	'DP002', 'AS001', 'P002', 'R002', 'D002'),
	(55, '202200017', 'EMPLOYEE', 'password152', 'FEMALE', '정혜인', '1997-12-04',
	'jungji@company.com', '010-3456-7894', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-06-25 09:00:00',
	'ROOKIE', NULL, 'N', 45000000, 3700000, '인천광역시 남동구 논현로 120', '105동 505호', '21684',
	'DP001', 'AS001', 'P001', 'R001', 'D003'),
	(56, '202100023', 'EMPLOYEE', 'password153', 'MALE', '서지훈', '1989-08-15',
	'seojh@company.com', '010-4567-8905', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-11-10 09:00:00',
	'ROOKIE', NULL, 'N', 48000000, 3800000, '인천광역시 연수구 송도과학로 85', '103동 1202호', '21984',
	'DP004', 'AS002', 'P001', 'R002', 'D006'),
	(57, '202100024', 'EMPLOYEE', 'password154', 'FEMALE', '김연주', '1994-09-02',
	'kimyj@company.com', '010-5678-9016', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-07-01 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3700000, '인천광역시 중구 운남로 30', '302동 506호', '22386',
	'DP005', 'AS001', 'P001', 'R001', 'D008'),
	(58, '202200018', 'EMPLOYEE', 'password155', 'MALE', '장우진', '1995-11-13',
	'jangwj@company.com', '010-6789-1234', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-02-17 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '인천광역시 동구 샛골로 75', '203동 1103호', '22551',
	'DP003', 'AS002', 'P003', 'R003', 'D009'),
	(59, '202100025', 'EMPLOYEE', 'password156', 'FEMALE', '윤소희', '1996-03-25',
	'yoonsh@company.com', '010-1890-1234', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-12-18 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '인천광역시 미추홀구 미추홀대로 210', '104동 307호', '22231',
	'DP001', 'AS003', 'P001', 'R001', 'D001'),
	(60, '202100026', 'EMPLOYEE', 'password157', 'MALE', '한준수', '1992-07-17',
	'hanjs@company.com', '010-1234-5672', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-08-10 09:00:00',
	'ROOKIE', NULL, 'N', 49000000, 3800000, '인천광역시 부평구 부평대로 70', '105동 907호', '21422',
	'DP004', 'AS001', 'P002', 'R001', 'D006'),
	(61, '202200019', 'EMPLOYEE', 'password158', 'FEMALE', '신혜수', '1993-10-15',
	'shinhs@company.com', '010-2345-6783', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-03-22 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3700000, '인천광역시 연수구 인천타워대로 150', '103동 304호', '21932',
	'DP005', 'AS003', 'P002', 'R001', 'D007'),
	(62, '202200020', 'EMPLOYEE', 'password159', 'MALE', '유성민', '1998-11-22',
	'yusm@company.com', '010-3456-7895', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-05-12 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3800000, '인천광역시 계양구 계양대로 100', '101동 804호', '21057',
	'DP003', 'AS001', 'P002', 'R001', 'D001'),
	(63, '202200021', 'EMPLOYEE', 'password160', 'FEMALE', '조하영', '1994-06-11',
	'johy@company.com', '010-4567-8906', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-07-30 09:00:00',
	'ROOKIE', NULL, 'N', 45000000, 3700000, '인천광역시 서구 원당로 65', '201동 1205호', '22768',
	'DP001', 'AS001', 'P001', 'R001', 'D008'),
	(64, '202200022', 'EMPLOYEE', 'password161', 'MALE', '고재훈', '1991-02-18',
	'gojh@company.com', '010-5678-9017', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-02-02 09:00:00',
	'ROOKIE', NULL, 'N', 48000000, 3800000, '인천광역시 동구 솔빛로 100', '301동 907호', '22535',
	'DP004', 'AS003', 'P003', 'R001', 'D009'),
	(65, '202100027', 'EMPLOYEE', 'password162', 'FEMALE', '배윤정', '1992-09-01',
	'baeyj@company.com', '010-6789-0128','https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-10-15 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3700000, '인천광역시 남구 매소홀로 50', '305동 1303호', '22150',
	'DP002', 'AS002', 'P001', 'R002', 'D002'),

-- 66번 ~ 90번 사원: 서울특별시 주소와 DP006 제외 부서 설정
	 (66, '202200023', 'EMPLOYEE', 'password163', 'MALE', '장민수', '1993-04-22',
	'jangms@company.com', '010-1294-5678', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-03-15 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '서울특별시 강남구 테헤란로 150', '101동 202호', '06236',
	'DP001', 'AS001', 'P001', 'R001', 'D002'),
	(67, '202100028', 'EMPLOYEE', 'password164', 'FEMALE', '김소현', '1994-08-14',
	'kimsh@company.com', '010-2345-6781', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-05-11 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '서울특별시 서초구 서초대로 60', '203동 603호', '06595',
	'DP003', 'AS001', 'P002', 'R002', 'D003'),
	(68, '202100029', 'EMPLOYEE', 'password165', 'MALE', '이정훈', '1992-03-25',
	'leejh@company.com', '010-3456-7892', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-07-19 09:00:00',
	'ROOKIE', NULL, 'N', 48000000, 3800000, '서울특별시 용산구 한남대로 80', '402동 1502호', '04401',
	'DP004', 'AS002', 'P002', 'R003', 'D004'),
	(69, '202100030', 'EMPLOYEE', 'password166', 'FEMALE', '박수빈', '1995-01-12',
	'parksb@company.com', '010-4567-8903', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-09-10 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '서울특별시 동작구 흑석로 40', '105동 1101호', '06901',
	'DP002', 'AS001', 'P003', 'R002', 'D002'),
	(70, '202200024', 'EMPLOYEE', 'password167', 'MALE', '신재영', '1993-06-07',
	'shinjy@company.com', '010-5678-9014', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-04-10 09:00:00',
	'ROOKIE', NULL, 'N', 45000000, 3700000, '서울특별시 성동구 왕십리로 220', '201동 1005호', '04794',
	'DP005', 'AS002', 'P001', 'R001', 'D007'),
	(71, '202100031', 'EMPLOYEE', 'password168', 'FEMALE', '차은지', '1990-02-11',
	'chaeji@company.com', '010-6789-0125', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-08-01 09:00:00',
	'VETERAN', NULL, 'N', 47000000, 3900000, '서울특별시 중구 소공로 70', '301동 204호', '04535',
	'DP003', 'AS001', 'P001', 'R001', 'D009'),
	(72, '202100032', 'EMPLOYEE', 'password169', 'MALE', '오세민', '1996-11-17',
	'osemin@company.com', '010-7890-1236', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-03-18 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '서울특별시 강서구 화곡로 45', '201동 702호', '07628',
	'DP001', 'AS002', 'P002', 'R001', 'D008'),
	(73, '202200025', 'EMPLOYEE', 'password170', 'FEMALE', '고지원', '1997-08-29',
	'gojw@company.com', '010-1234-5677', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-02-20 09:00:00',
	'ROOKIE', NULL, 'N', 45000000, 3700000, '서울특별시 강북구 도봉로 110', '202동 903호', '01032',
	'DP002', 'AS001', 'P001', 'R001', 'D002'),
	(74, '202200026', 'EMPLOYEE', 'password171', 'MALE', '백준호', '1993-09-21',
	'baekjh@company.com', '010-2345-6789', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-05-25 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '서울특별시 송파구 송파대로 400', '104동 805호', '05613',
	'DP005', 'AS003', 'P003', 'R002', 'D004'),
	(75, '202100033', 'EMPLOYEE', 'password172', 'FEMALE', '윤다인', '1998-12-06',
	'yundi@company.com', '010-3456-7894', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-06-15 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '서울특별시 관악구 남부순환로 290', '303동 303호', '08810',
	'DP004', 'AS002', 'P001', 'R003', 'D006'),
	(76, '202200027', 'EMPLOYEE', 'password173', 'MALE', '조현석', '1991-07-29',
	'jochs@company.com', '010-4567-8906', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-08-10 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '서울특별시 은평구 응암로 160', '401동 1404호', '03477',
	'DP003', 'AS001', 'P002', 'R001', 'D001'),
	(77, '202100034', 'EMPLOYEE', 'password174', 'FEMALE', '신가현', '1994-05-15',
	'shingh@company.com', '010-5678-9018', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-05-28 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '서울특별시 종로구 종로대로 120', '101동 1205호', '03195',
	'DP001', 'AS001', 'P001', 'R001', 'D003'),
	(78, '202200028', 'EMPLOYEE', 'password175', 'MALE', '박세훈', '1992-09-30',
	'parksh@company.com', '010-6789-0126', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-09-05 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '서울특별시 성북구 화랑로 300', '501동 703호', '02798',
	'DP005', 'AS001', 'P003', 'R001', 'D009'),
	(79, '202200029', 'EMPLOYEE', 'password176', 'FEMALE', '김현수', '1993-03-01',
	'kimhs@company.com', '010-7890-1238', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-07-12 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3700000, '서울특별시 금천구 가산디지털로 100', '201동 1303호', '08590',
	'DP004', 'AS003', 'P001', 'R001', 'D008'),
	(80, '202100035', 'EMPLOYEE', 'password177', 'MALE', '정하나', '1996-04-07',
	'jungha@company.com', '010-1234-5679', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-04-15 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3800000, '서울특별시 마포구 마포대로 200', '401동 203호', '04168',
	'DP001', 'AS002', 'P003', 'R002', 'D004'),
	(81, '202100036', 'EMPLOYEE', 'password178', 'FEMALE', '박서준', '1997-06-30',
	'parksej@company.com', '010-2345-6780', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-10-05 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '서울특별시 노원구 동일로 320', '203동 905호', '01850',
	'DP003', 'AS001', 'P001', 'R001', 'D007'),
	(82, '202200030', 'EMPLOYEE', 'password179', 'MALE', '유수빈', '1990-10-21',
	'yusb@company.com', '010-3456-7895', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-04-22 09:00:00',
	'ROOKIE', NULL, 'N', 48000000, 3800000, '서울특별시 서대문구 연희로 150', '105동 1301호', '03730',
	'DP005', 'AS001', 'P001', 'R002', 'D006'),
	(83, '202100037', 'EMPLOYEE', 'password180', 'FEMALE', '최다해', '1998-03-09',
	'choidh@company.com', '010-4567-8909', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-11-22 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '서울특별시 양천구 목동로 220', '202동 1003호', '07995',
	'DP002', 'AS003', 'P001', 'R001', 'D008'),
	(84, '202100038', 'EMPLOYEE', 'password181', 'MALE', '한지훈', '1994-01-15',
	'hanjh@company.com', '010-5678-9019', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-03-03 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '서울특별시 강동구 천호대로 300', '101동 501호', '05399',
	'DP001', 'AS001', 'P002', 'R002', 'D003'),
	(85, '202200031', 'EMPLOYEE', 'password182', 'FEMALE', '이해나', '1993-12-23',
	'leeha@company.com', '010-6789-0127', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-02-17 09:00:00',
	'ROOKIE', NULL, 'N', 45000000, 3700000, '서울특별시 중랑구 망우로 210', '103동 204호', '02100',
	'DP003', 'AS001', 'P003', 'R001', 'D002'),
	(86, '202100039', 'EMPLOYEE', 'password183', 'MALE', '김정환', '1997-07-01',
	'kimjh@company.com', '010-7890-1239', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-09-14 09:00:00',
	'ROOKIE', NULL, 'N', 48000000, 3800000, '서울특별시 구로구 디지털로 300', '204동 502호', '08378',
	'DP005', 'AS003', 'P001', 'R001', 'D009'),
	(87, '202200032', 'EMPLOYEE', 'password184', 'FEMALE', '정지윤', '1994-05-14',
	'jungjy@company.com', '010-1243-5678', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-05-30 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3700000, '서울특별시 동대문구 장안로 100', '304동 604호', '02630',
	'DP004', 'AS001', 'P002', 'R003', 'D006'),
	(88, '202200033', 'EMPLOYEE', 'password185', 'MALE', '차현우', '1995-10-16',
	'chahw@company.com', '010-2345-6789', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-06-14 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3800000, '서울특별시 종로구 삼청로 50', '102동 1407호', '03018',
	'DP003', 'AS003', 'P003', 'R001', 'D007'),
	(89, '202100040', 'EMPLOYEE', 'password186', 'FEMALE', '한미주', '1992-06-10',
	'hanmj@company.com', '010-3456-7890', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-04-08 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3700000, '서울특별시 광진구 아차산로 100', '105동 903호', '05025',
	'DP002', 'AS001', 'P001', 'R002', 'D001'),
	(90, '202200034', 'EMPLOYEE', 'password187', 'MALE', '이서준', '1991-09-05',
	'leej@company.com', '010-5678-9011', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-04-11 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '서울특별시 강남구 언주로 250', '104동 803호', '06108',
	'DP005', 'AS002', 'P002', 'R003', 'D004'),
	
-- 91번 ~ 100번 사원: 임의의 서울, 인천, 경기 주소와 DP006 제외 부서 설정

	(91, '202100041', 'EMPLOYEE', 'password188', 'MALE', '최상준', '1996-03-21',
	'choisj@company.com', '010-6789-1231', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-06-12 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '서울특별시 강북구 번동로 30', '101동 401호', '01010',
	'DP004', 'AS001', 'P001', 'R001', 'D002'),
	(92, '202200035', 'EMPLOYEE', 'password189', 'FEMALE', '김유리', '1995-10-12',
	'kimyr@company.com', '010-7890-1232', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-08-18 09:00:00',
	'ROOKIE', NULL, 'N', 48000000, 3800000, '경기도 고양시 덕양구 고양대로 120', '202동 1002호', '10586',
	'DP002', 'AS003', 'P001', 'R001', 'D003'),
	(93, '202200036', 'EMPLOYEE', 'password190', 'MALE', '박찬영', '1993-08-10',
	'parkcy@company.com', '010-1234-5673', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-09-05 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '서울특별시 은평구 갈현로 80', '203동 903호', '03401',
	'DP003', 'AS001', 'P002', 'R003', 'D004'),
	(94, '202100042', 'EMPLOYEE', 'password191', 'FEMALE', '송은지', '1998-04-05',
	'songej@company.com', '010-2345-6784', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-11-15 09:00:00',
	'ROOKIE', NULL, 'N', 45000000, 3700000, '인천광역시 계양구 봉오대로 100', '304동 1403호', '21023',
	'DP005', 'AS002', 'P001', 'R001', 'D008'),
	(95, '202100043', 'EMPLOYEE', 'password192', 'MALE', '고영호', '1991-01-30',
	'goyh@company.com', '010-3456-7896', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-07-10 09:00:00',
	'VETERAN', NULL, 'N', 47000000, 3900000, '경기도 부천시 길주로 150', '205동 302호', '14510',
	'DP001', 'AS001', 'P003', 'R002', 'D005'),
	(96, '202200037', 'EMPLOYEE', 'password193', 'FEMALE', '백나경', '1994-09-25',
	'baeknk@company.com', '010-4567-8907', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2022-02-12 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3700000, '서울특별시 동작구 흑석로 75', '101동 504호', '06923',
	'DP003', 'AS001', 'P001', 'R001', 'D009'),
	(97, '202100044', 'EMPLOYEE', 'password194', 'MALE', '이준호', '1997-07-15',
	'leejh@company.com', '010-5678-9018', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-10-01 09:00:00',
	'ROOKIE', NULL, 'N', 46000000, 3800000, '서울특별시 서초구 반포대로 120', '301동 205호', '06591',
	'DP005', 'AS002', 'P002', 'R003', 'D001'),
	(98, '202100045', 'EMPLOYEE', 'password195', 'FEMALE', '한예진', '1996-02-17',
	'hanyj@company.com', '010-6789-0129', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-03-25 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '서울특별시 마포구 대흥로 200', '403동 903호', '04141',
	'DP001', 'AS002', 'P002', 'R002', 'D007'),
	(99, '202100046', 'EMPLOYEE', 'password196', 'MALE', '최지호', '1993-11-05',
	'choijh@company.com', '010-1234-5680', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-06-22 09:00:00',
	'ROOKIE', NULL, 'N', 47000000, 3800000, '인천광역시 남동구 구월로 50', '205동 1304호', '21550',
	'DP004', 'AS001', 'P003', 'R001', 'D006'),
	(100, '202100047', 'EMPLOYEE', 'password197', 'FEMALE', '유진아', '1995-06-30',
	'yujina@company.com', '010-3456-7891', 'https://inflow-emp-profile.s3.ap-northeast-2.amazonaws.com/emp_basic_profile.png', '2021-07-28 09:00:00',
	'ROOKIE', NULL, 'N', 45000000, 3700000, '경기도 수원시 영통구 광교로 200', '102동 1004호', '16503',
	'DP002', 'AS003', 'P001', 'R001', 'D008');


-- 가구원관계 테이블
INSERT INTO family_relationship (family_relationship_code, family_relationship_name)
VALUES
    ('SELF', '본인'),
    ('SPOUSE', '배우자'),
    ('CHILD', '자녀'),
    ('PARENT', '부모'),
    ('SIBLING', '형제자매'),
    ('GRANDPARENT', '조부모');

-- 가족구성원 테이블
INSERT INTO family_member (family_member_id, name, birth_date, employee_id, family_relationship_code)
VALUES
-- employee_id 1
(1, '홍길동', '1980-01-01', 1, 'SELF'),     -- 본인
(2, '배수지', '1986-06-15', 1, 'SPOUSE'),    -- 배우자
(3, '홍예지', '2015-08-20', 1, 'CHILD'),     -- 자녀

-- employee_id 2
(4, '김영수', '1975-02-15', 2, 'SELF'),      -- 본인
(5, '김갑수', '1965-02-25', 2, 'PARENT'),    -- 부모
(6, '전소민', '2018-01-10', 2, 'CHILD'),     -- 자녀

-- employee_id 3
(7, '박철수', '1960-07-11', 3, 'SELF'),      -- 본인
(8, '박해진', '1960-11-11', 3, 'PARENT'),    -- 부모
(9, '박철민', '1987-04-05', 3, 'SIBLING'),   -- 형제자매

-- employee_id 4
(10, '남궁희', '1994-07-30', 4, 'SELF'),     -- 본인
(11, '남궁민수', '1994-07-30', 4, 'SPOUSE'), -- 배우자
(12, '남궁빈', '2020-12-18', 4, 'CHILD'),    -- 자녀

-- employee_id 5
(13, '최영희', '1968-03-22', 5, 'SELF'),     -- 본인
(14, '최수진', '1968-03-22', 5, 'PARENT'),   -- 부모
(15, '최강민', '1990-09-12', 5, 'SIBLING'),  -- 형제자매

-- employee_id 7
(16, '홍길둥', '1980-01-01', 7, 'SELF'),      -- 본인
(17, '배수진', '1986-06-15', 7, 'SPOUSE'),    -- 배우자
(18, '홍지예', '2015-08-20', 7, 'CHILD');     -- 자녀   


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
    (10, 'POSTECH', '2011-03-01 09:00:00', '2015-02-28 09:00:00', '석사', '화학공학', 5),
    (11, '고려대학교', '2007-03-01 09:00:00', '2011-02-28 09:00:00', '학사', '전자공학', 7);

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
    (10, '카카오', '모바일 앱 개발자', '2016-03-01 09:00:00', '2020-06-30 18:00:00', 5),
    (11, '삼성전자', '소프트웨어 엔지니어', '2011-05-01 09:00:00', '2014-08-31 18:00:00', 7);

-- 계약서 table
INSERT INTO contract (contract_id, contract_type, created_at, file_name, file_url, contract_status, consent_status, employee_id)
VALUES 
(1, 'EMPLOYMENT', NULL, NULL, NULL, 'SIGNING', 'N', 1),
(2, 'SECURITY', NULL, NULL, NULL, 'SIGNING', 'N', 1),
(3, 'EMPLOYMENT', NULL, NULL, NULL, 'SIGNING', 'N', 2),
(4, 'SECURITY', NULL, NULL, NULL, 'SIGNING', 'N', 2),
(5, 'EMPLOYMENT', NULL, NULL, NULL, 'SIGNING', 'N', 3),
(6, 'SECURITY', NULL, NULL, NULL, 'SIGNING', 'N', 3),
(7, 'EMPLOYMENT', NULL, NULL, NULL, 'SIGNING', 'N', 4),
(8, 'SECURITY', NULL, NULL, NULL, 'SIGNING', 'N', 4),
(9, 'EMPLOYMENT', NULL, NULL, NULL, 'SIGNING', 'N', 5),
(10, 'SECURITY', NULL, NULL, NULL, 'SIGNING', 'N', 5),
(11, 'EMPLOYMENT', NULL, NULL, NULL, 'SIGNING', 'N', 6),
(12, 'SECURITY', NULL, NULL, NULL, 'SIGNING', 'N', 6),
(13, 'EMPLOYMENT', NULL, NULL, NULL, 'SIGNING', 'N', 7),
(14, 'SECURITY', NULL, NULL, NULL, 'SIGNING', 'N', 7),
(15, 'EMPLOYMENT', NULL, NULL, NULL, 'SIGNING', 'N', 8),
(16, 'SECURITY', NULL, NULL, NULL, 'SIGNING', 'N', 8),
(17, 'EMPLOYMENT', NULL, NULL, NULL, 'SIGNING', 'N', 9),
(18, 'SECURITY', NULL, NULL, NULL, 'SIGNING', 'N', 9),
(19, 'EMPLOYMENT', NULL, NULL, NULL, 'SIGNING', 'N', 10),
(20, 'SECURITY', NULL, NULL, NULL, 'SIGNING', 'N', 10);

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
    (9, '국가공인 자격증', '889900112', '2024-05-30 09:00:00', '국가자격관리원', 'PASS', 5),
    -- 한상민 데이터터
    (10, '정보처리기사', '123456189', '2023-12-01 09:00:00', '한국산업인력공단', 'PASS', 7),
    (11, '컴퓨터활용능력 1급', '917654321', '2024-01-15 09:00:00', '한국산업인력공단', 'PASS', 7),
    (12, '한국사능력검정시험 1급', '221344556', '2024-02-20 09:00:00', '국사편찬위원회', 'PASS', 7),
    (13, '회계관리 1급', '334415667', '2023-11-10 09:00:00', '한국세무사회', 'PASS', 7),
    (14, 'ERP 정보관리사', '445516778', '2024-03-05 09:00:00', '한국경영기술연구원', 'PASS', 7),
    (15, '운전면허 1종 보통', '556177889', '2023-08-01 09:00:00', '도로교통공단', 'PASS', 7),
    (16, 'SQLD', '667718990', '2024-04-10 09:00:00', '한국정보통신기술협회', 'PASS', 7);

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
    (5, 'TestDaF', '445566778', 'Goethe-Institut', '2024-03-01 09:00:00', 'C1', 5, 'DE'),

    (6, 'TOEIC', '123416789', 'ETS', '2023-11-01 09:00:00', '980', 7, 'EN'),
    (7, 'JLPT N1', '988654321', 'JLPT', '2024-02-10 09:00:00', 'PASS', 7, 'JP'),
    (8, 'HSK 5급', '228344556', 'HSK', '2023-12-05 09:00:00', 'PASS', 7, 'CN'),
    (9, 'DELF B2', '338455667', 'CIEP', '2024-01-15 09:00:00', 'PASS', 7, 'FR');

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
    (10, '징계', '지각 반복으로 경고조치', '2024-09-10 09:00:00', 5),
    (11, '포상', '우수사원으로 선정되어 상금 100만원 지급', '2023-12-10 09:00:00', 7),
    (12, '포상', '팀 프로젝트 우수성 인정으로 팀원에게 상장 수여', '2024-06-20 09:00:00', 7);

-- 인사발령 항목  테이블
INSERT INTO appointment_item (appointment_item_code, appointment_item_name) VALUES
('PROM', '승진'),
('SPPR', '특진'),
('RETI', '퇴직'),
('DEMO', '강등'),
('TRNS', '부서이동'),
('RCHG', '보직변경');

-- 인사발령 테이블
INSERT INTO appointment (appointment_id, appointed_at, employee_id,authorizer_id, appointment_item_code, department_code, duty_code, role_code, position_code)
VALUES
-- 한상민의 첫 발령: 입사 시 주임으로 IT 기술 부서로 발령
(1, '2021-03-15 09:00:00', 7, 1, 'TRNS', 'DP006', 'D005', 'R001', 'P001'), -- 주임(P001)으로 입사

-- 한상민의 두 번째 발령: 대리로 승진
(2, '2024-03-15 09:00:00', 7, 1, 'PROM', 'DP006', 'D005', 'R001', 'P002'); -- 대리(P002)로 승진

-- 휴가유형 테이블
INSERT INTO vacation_type (vacation_type_id, vacation_type_name)
VALUES
    (1, '연차'),
    (2, '공가'),
    (3, '병가'),
    (4, '포상휴가'),
    (5, '특별휴가');

-- 휴가 정책 테이블
INSERT INTO vacation_policy (vacation_policy_id, vacation_policy_name, vacation_policy_description, vacation_policy_status, allocation_days, paid_status, year, created_at, auto_allocation_cycle, vacation_type_id, policy_register_id)
VALUES
    (1, '2024 1년 이상 근속자 연차', '2024년 연차는 1년 이상 근속한 사원에게 15일씩 자동 지급됩니다.', 'NORMAL', 15, 'Y', 2024, '2024-01-01 00:00:00', '0 0 0 1 1 *', 1, 5),
    (2, '2024 공가', '공가는 증빙자료가 있어야 지급 가능합니다.', 'NORMAL', 366, 'Y', 2024, '2024-01-01 00:00:00', '0 0 0 1 1 *', 2, 5),
    (3, '2024 병가', '병가는 진료확인서가 있어야 지급 가능합니다.', 'NORMAL', 240, 'Y', 2024, '2024-01-01 00:00:00', '0 0 0 1 1 *', 3, 5),
    (4, '2024 포상휴가', '2024년 포상휴가는 최대 3일까지 지급 가능합니다.', 'NORMAL', 3, 'Y', 2024, '2024-01-01 00:00:00', NULL, 4, 5),
    (5, '2024 특별휴가', '2024년 특별휴가는 최대 7일까지 지급 가능합니다.', 'NORMAL', 7, 'N', 2024, '2024-01-01 00:00:00', NULL, 5, 5),
    (6, '2024 1년 미만 근속자 연차', '2024년 연차는 1년 미만 근속한 사원에게 매월 1일씩 자동 지급됩니다.', 'ROOKIE', 1, 'Y', 2024, '2024-01-01 00:00:00', '0 0 0 1 * *', 1, 5);


-- 휴가 테이블
INSERT INTO vacation (
    vacation_id, vacation_name, vacation_left, vacation_used, created_at, expired_at, expiration_status,
    employee_id, vacation_policy_id, vacation_type_id
) VALUES
      (1, '2024년 연차', 15, 5, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 1, 1, 1),
      (2, '2024년 연차', 14, 1, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 2, 1, 1),
      (3, '2024년 병가', 10, 2, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 3, 2, 3),
      (4, '2024년 포상휴가', 7, 0, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 1, 4, 4),
      (5, '2024년 특별휴가', 5, 1, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 5, 5, 5),
      (6, '2024년 연차', 15, 3, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 3, 1, 1),
      (7, '2024년 공가', 3, 1, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 2, 3, 2),
      (8, '2024년 연차', 20, 4, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 4, 1, 1),
      (9, '2024년 연차', 10, 2, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 5, 1, 1),
      (10, '2024년 특별휴가', 5, 0, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 5, 5, 5),
      (11, '2024년 공가', 366, 0, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 1, 2, 2),
      (12, '2024년 병가', 240, 0, '2024-01-01 09:00:00', '2024-12-31 23:59:59', 'N', 1, 3, 3);

-- 휴가 신청 테이블
INSERT INTO vacation_request (
    vacation_request_id, start_date, end_date, created_at, request_reason,
    request_status, rejection_reason, canceled_at, cancel_reason, cancel_status,
    employee_id, vacation_id
)
VALUES
    (1, '2024-12-01 09:00:00', '2024-12-03 18:00:00', '2024-11-01 10:00:00', '휴가를 가고 싶습니다.',
     'REJECT', '휴가 사유 재작성 요망', NULL, NULL, 'N', 1, 1),
    (2, '2024-12-10 09:00:00', '2024-12-12 18:00:00', '2024-11-05 11:30:00', '가족 모임 참석',
     'WAIT', NULL, NULL, NULL, 'N', 2, 2),
    (3, '2024-12-20 09:00:00', '2024-12-22 18:00:00', '2024-11-10 14:00:00', '긴급한 일로 휴가 요청',
     'REJECT', '일정이 맞지 않아서', NULL, NULL, 'N', 3, 3),
    (4, '2024-12-25 09:00:00', '2024-12-27 18:00:00', '2024-11-15 16:00:00', '포상 휴가 사용',
     'WAIT', NULL, NULL, NULL, 'N', 1, 4),
    (5, '2024-12-30 09:00:00', '2024-12-31 18:00:00', '2024-11-20 08:00:00', '휴가',
     'WAIT', NULL, NULL, NULL, 'N', 5, 5),
    (6, '2025-01-01 09:00:00', '2025-01-03 18:00:00', '2024-11-30 10:00:00', '연차 사용',
     'ACCEPT', NULL, NULL, NULL, 'N', 1, 1);

-- 휴가 신청 증빙자료 테이블
INSERT INTO vacation_request_file (
    vacation_request_file_id, file_name, file_url, vacation_request_id
)
VALUES
    (1, '홍길동_휴가_증빙자료', 'https://example.com/files/vacation_request_1.pdf', 4),
    (2, '김영희_휴가_증빙자료', 'https://example.com/files/vacation_request_2.pdf', 2),
    (3, '박철수_휴가_증빙자료', 'https://example.com/files/vacation_request_3.pdf', 3),
    (4, '홍길동_휴가_증빙자료', 'https://example.com/files/vacation_request_4.pdf', 4),
    (5, '최강욱_휴가_증빙자료', 'https://example.com/files/vacation_request_5.pdf', 5);

-- 연차사용촉진정책 테이블
INSERT INTO annual_vacation_promotion_policy (
    annual_vacation_promotion_policy_id, month, day, standard
)
VALUES
    (1, 7, 1, 15),
    (2, 10, 1, 10);

-- 근태 신청 유형 테이블
INSERT INTO attendance_request_type (
    attendance_request_type_id, attendance_request_type_name, attendance_request_type_description
)
VALUES
    (1, '재택근무', '선재택 후승인'),
    (2, '초과근무', '초과근무는 30분 간격으로 연장이 가능합니다.'),
    (3, '출장', '출장을 가시려면 출장전에 출장 신청하시고, 신청 승인받으셔야 합니다.'),
    (4, '파견', '파견을 가시려면 파견 전에 파견 신청하시고, 신청 승인받으셔야 합니다.'),
    (5, '휴직', '휴직을 하려면 휴직 신청 후, 신청 승인받으셔야 합니다'),
    (6, '복직', '복직을 하려면 복직 신청을 하셔야 되는데, 신청에 복직 신청서 파일을 같이 첨부하셔야 합니다.');

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
    (5, '휴직 신청', '2023-11-02 00:00:00', '2024-11-02 00:00:00', '2023-10-01 09:15:00',
     NULL, 'ACCEPT', NULL, NULL, 'N', NULL, 1, 5),
    (6, '한화시스템 부트캠프 멘토링', '2024-11-12 18:00:00', '2024-11-12 22:00:00', '2024-11-12 17:00:00',
     NULL, 'ACCEPT', NULL, NULL, 'N', NULL, 1, 2),
    (7, '야근', '2024-12-01 18:00:00', '2024-12-01 20:00:00', '2024-12-01 12:00:00',
     NULL, 'ACCEPT', NULL, NULL, 'N', NULL, 1, 2);

-- 근태 신청 증빙자료 테이블
INSERT INTO attendance_request_file (
    attendance_request_file_id, file_name, file_url, attendance_request_id
)
VALUES
    (1, '근태 증빙자료1', 'https://example.com/file1.pdf', 1),
    (2, '근태 증빙자료2', 'https://example.com/file2.pdf', 2),
    (3, '근태 증빙자료3', 'https://example.com/file3.pdf', 3),
    (4, '근태 증빙자료4', 'https://example.com/file4.pdf', 4),
    (5, '근태 증빙자료5', 'https://example.com/file5.pdf', 5);

-- 2023년 2024년 출퇴근 더미데이터
INSERT INTO commute (commute_id, start_time, end_time, remote_status, overtime_status, employee_id, attendance_request_id)
VALUES
    -- 1월 (신정 제외)
    (1, '2024-01-02 08:23:15', '2024-01-02 18:00:00', 'N', 'N', 1, NULL),
    (2, '2024-01-03 08:45:32', '2024-01-03 18:00:00', 'N', 'N', 1, NULL),
    (3, '2024-01-04 08:12:45', '2024-01-04 18:00:00', 'N', 'N', 1, NULL),
    (4, '2024-01-05 08:34:21', '2024-01-05 18:00:00', 'N', 'N', 1, NULL),
    (5, '2024-01-08 08:56:43', '2024-01-08 18:00:00', 'N', 'N', 1, NULL),
    (6, '2024-01-09 08:15:27', '2024-01-09 18:00:00', 'N', 'N', 1, NULL),
    (7, '2024-01-10 08:42:18', '2024-01-10 18:00:00', 'N', 'N', 1, NULL),
    (8, '2024-01-11 08:28:54', '2024-01-11 18:00:00', 'N', 'N', 1, NULL),
    (9, '2024-01-12 08:37:16', '2024-01-12 18:00:00', 'N', 'N', 1, NULL),
    (10, '2024-01-15 08:19:45', '2024-01-15 18:00:00', 'N', 'N', 1, NULL),
    (11, '2024-01-16 08:51:32', '2024-01-16 18:00:00', 'N', 'N', 1, NULL),
    (12, '2024-01-17 08:24:17', '2024-01-17 18:00:00', 'N', 'N', 1, NULL),
    (13, '2024-01-18 08:47:28', '2024-01-18 18:00:00', 'N', 'N', 1, NULL),
    (14, '2024-01-19 08:33:54', '2024-01-19 18:00:00', 'N', 'N', 1, NULL),
    (15, '2024-01-22 08:16:42', '2024-01-22 18:00:00', 'N', 'N', 1, NULL),
    (16, '2024-01-23 08:58:21', '2024-01-23 18:00:00', 'N', 'N', 1, NULL),
    (17, '2024-01-24 08:27:35', '2024-01-24 18:00:00', 'N', 'N', 1, NULL),
    (18, '2024-01-25 08:44:19', '2024-01-25 18:00:00', 'N', 'N', 1, NULL),
    (19, '2024-01-26 08:31:47', '2024-01-26 18:00:00', 'N', 'N', 1, NULL),
    (20, '2024-01-29 08:22:36', '2024-01-29 18:00:00', 'N', 'N', 1, NULL),
    (21, '2024-01-30 08:49:23', '2024-01-30 18:00:00', 'N', 'N', 1, NULL),
    (22, '2024-01-31 08:35:58', '2024-01-31 18:00:00', 'N', 'N', 1, NULL),

    -- 2월 (설날 연휴 제외: 9-11일)
    (23, '2024-02-01 08:26:45', '2024-02-01 18:00:00', 'N', 'N', 1, NULL),
    (24, '2024-02-02 08:53:12', '2024-02-02 18:00:00', 'N', 'N', 1, NULL),
    (25, '2024-02-05 08:18:34', '2024-02-05 18:00:00', 'N', 'N', 1, NULL),
    (26, '2024-02-06 08:41:27', '2024-02-06 18:00:00', 'N', 'N', 1, NULL),
    (27, '2024-02-07 08:29:53', '2024-02-07 18:00:00', 'N', 'N', 1, NULL),
    (28, '2024-02-08 08:55:16', '2024-02-08 18:00:00', 'N', 'N', 1, NULL),
    (29, '2024-02-12 08:23:48', '2024-02-12 18:00:00', 'N', 'N', 1, NULL),
    (30, '2024-02-13 08:47:32', '2024-02-13 18:00:00', 'N', 'N', 1, NULL),
    (31, '2024-02-14 08:34:15', '2024-02-14 18:00:00', 'N', 'N', 1, NULL),
    (32, '2024-02-15 08:21:49', '2024-02-15 18:00:00', 'N', 'N', 1, NULL),
    (33, '2024-02-16 08:52:37', '2024-02-16 18:00:00', 'N', 'N', 1, NULL),
    (34, '2024-02-19 08:28:54', '2024-02-19 18:00:00', 'N', 'N', 1, NULL),
    (35, '2024-02-20 08:43:21', '2024-02-20 18:00:00', 'N', 'N', 1, NULL),
    (36, '2024-02-21 08:37:46', '2024-02-21 18:00:00', 'N', 'N', 1, NULL),
    (37, '2024-02-22 08:19:32', '2024-02-22 18:00:00', 'N', 'N', 1, NULL),
    (38, '2024-02-23 08:56:14', '2024-02-23 18:00:00', 'N', 'N', 1, NULL),
    (39, '2024-02-26 08:31:45', '2024-02-26 18:00:00', 'N', 'N', 1, NULL),
    (40, '2024-02-27 08:48:23', '2024-02-27 18:00:00', 'N', 'N', 1, NULL),
    (41, '2024-02-28 08:25:57', '2024-02-28 18:00:00', 'N', 'N', 1, NULL),
    (42, '2024-02-29 08:54:32', '2024-02-29 18:00:00', 'N', 'N', 1, NULL),

    -- 3월 (삼일절 제외)
    (43, '2024-03-04 08:22:45', '2024-03-04 18:00:00', 'N', 'N', 1, NULL),
    (44, '2024-03-05 08:35:12', '2024-03-05 18:00:00', 'N', 'N', 1, NULL),
    (45, '2024-03-06 08:47:33', '2024-03-06 18:00:00', 'N', 'N', 1, NULL),
    (46, '2024-03-07 08:28:54', '2024-03-07 18:00:00', 'N', 'N', 1, NULL),
    (47, '2024-03-08 08:15:27', '2024-03-08 18:00:00', 'N', 'N', 1, NULL),
    (48, '2024-03-11 08:42:18', '2024-03-11 18:00:00', 'N', 'N', 1, NULL),
    (49, '2024-03-12 08:33:45', '2024-03-12 18:00:00', 'N', 'N', 1, NULL),
    (50, '2024-03-13 08:19:32', '2024-03-13 18:00:00', 'N', 'N', 1, NULL),
    (51, '2024-03-14 08:56:14', '2024-03-14 18:00:00', 'N', 'N', 1, NULL),
    (52, '2024-03-15 08:27:48', '2024-03-15 18:00:00', 'N', 'N', 1, NULL),
    (53, '2024-03-18 08:45:23', '2024-03-18 18:00:00', 'N', 'N', 1, NULL),
    (54, '2024-03-19 08:31:56', '2024-03-19 18:00:00', 'N', 'N', 1, NULL),
    (55, '2024-03-20 08:52:14', '2024-03-20 18:00:00', 'N', 'N', 1, NULL),
    (56, '2024-03-21 08:24:37', '2024-03-21 18:00:00', 'N', 'N', 1, NULL),
    (57, '2024-03-22 08:38:45', '2024-03-22 18:00:00', 'N', 'N', 1, NULL),
    (58, '2024-03-25 08:17:29', '2024-03-25 18:00:00', 'N', 'N', 1, NULL),
    (59, '2024-03-26 08:49:12', '2024-03-26 18:00:00', 'N', 'N', 1, NULL),
    (60, '2024-03-27 08:23:54', '2024-03-27 18:00:00', 'N', 'N', 1, NULL),
    (61, '2024-03-28 08:41:33', '2024-03-28 18:00:00', 'N', 'N', 1, NULL),
    (62, '2024-03-29 08:35:47', '2024-03-29 18:00:00', 'N', 'N', 1, NULL),

    -- 4월
    (63, '2024-04-01 08:28:15', '2024-04-01 18:00:00', 'N', 'N', 1, NULL),
    (64, '2024-04-02 08:42:33', '2024-04-02 18:00:00', 'N', 'N', 1, NULL),
    (65, '2024-04-03 08:19:47', '2024-04-03 18:00:00', 'N', 'N', 1, NULL),
    (66, '2024-04-04 08:55:22', '2024-04-04 18:00:00', 'N', 'N', 1, NULL),
    (67, '2024-04-05 08:31:48', '2024-04-05 18:00:00', 'N', 'N', 1, NULL),
    (68, '2024-04-08 08:47:15', '2024-04-08 18:00:00', 'N', 'N', 1, NULL),
    (69, '2024-04-09 08:23:54', '2024-04-09 18:00:00', 'N', 'N', 1, NULL),
    (70, '2024-04-10 08:38:27', '2024-04-10 18:00:00', 'N', 'N', 1, NULL),
    (71, '2024-04-11 08:15:42', '2024-04-11 18:00:00', 'N', 'N', 1, NULL),
    (72, '2024-04-12 08:52:33', '2024-04-12 18:00:00', 'N', 'N', 1, NULL),
    (73, '2024-04-15 08:29:18', '2024-04-15 18:00:00', 'N', 'N', 1, NULL),
    (74, '2024-04-16 08:44:56', '2024-04-16 18:00:00', 'N', 'N', 1, NULL),
    (75, '2024-04-17 08:21:34', '2024-04-17 18:00:00', 'N', 'N', 1, NULL),
    (76, '2024-04-18 08:57:12', '2024-04-18 18:00:00', 'N', 'N', 1, NULL),
    (77, '2024-04-19 08:33:45', '2024-04-19 18:00:00', 'N', 'N', 1, NULL),
    (78, '2024-04-22 08:48:23', '2024-04-22 18:00:00', 'N', 'N', 1, NULL),
    (79, '2024-04-23 08:25:54', '2024-04-23 18:00:00', 'N', 'N', 1, NULL),
    (80, '2024-04-24 08:41:27', '2024-04-24 18:00:00', 'N', 'N', 1, NULL),
    (81, '2024-04-25 08:17:38', '2024-04-25 18:00:00', 'N', 'N', 1, NULL),
    (82, '2024-04-26 08:53:15', '2024-04-26 18:00:00', 'N', 'N', 1, NULL),
    (83, '2024-04-29 08:28:42', '2024-04-29 18:00:00', 'N', 'N', 1, NULL),
    (84, '2024-04-30 08:45:19', '2024-04-30 18:00:00', 'N', 'N', 1, NULL),

    -- 5월 (어린이날, 부처님오신날 제외)
    (85, '2024-05-02 08:32:15', '2024-05-02 18:00:00', 'N', 'N', 1, NULL),
    (86, '2024-05-03 08:47:33', '2024-05-03 18:00:00', 'N', 'N', 1, NULL),
    (87, '2024-05-06 08:23:48', '2024-05-06 18:00:00', 'N', 'N', 1, NULL),
    (88, '2024-05-07 08:38:27', '2024-05-07 18:00:00', 'N', 'N', 1, NULL),
    (89, '2024-05-08 08:15:42', '2024-05-08 18:00:00', 'N', 'N', 1, NULL),
    (90, '2024-05-09 08:52:33', '2024-05-09 18:00:00', 'N', 'N', 1, NULL),
    (91, '2024-05-10 08:29:18', '2024-05-10 18:00:00', 'N', 'N', 1, NULL),
    (92, '2024-05-13 08:44:56', '2024-05-13 18:00:00', 'N', 'N', 1, NULL),
    (93, '2024-05-14 08:21:34', '2024-05-14 18:00:00', 'N', 'N', 1, NULL),
    (94, '2024-05-16 08:57:12', '2024-05-16 18:00:00', 'N', 'N', 1, NULL),
    (95, '2024-05-17 08:33:45', '2024-05-17 18:00:00', 'N', 'N', 1, NULL),
    (96, '2024-05-20 08:48:23', '2024-05-20 18:00:00', 'N', 'N', 1, NULL),
    (97, '2024-05-21 08:25:54', '2024-05-21 18:00:00', 'N', 'N', 1, NULL),
    (98, '2024-05-22 08:41:27', '2024-05-22 18:00:00', 'N', 'N', 1, NULL),
    (99, '2024-05-23 08:17:38', '2024-05-23 18:00:00', 'N', 'N', 1, NULL),
    (100, '2024-05-24 08:53:15', '2024-05-24 18:00:00', 'N', 'N', 1, NULL),
    (101, '2024-05-27 08:28:42', '2024-05-27 18:00:00', 'N', 'N', 1, NULL),
    (102, '2024-05-28 08:45:19', '2024-05-28 18:00:00', 'N', 'N', 1, NULL),
    (103, '2024-05-29 08:31:56', '2024-05-29 18:00:00', 'N', 'N', 1, NULL),
    (104, '2024-05-30 08:39:23', '2024-05-30 18:00:00', 'N', 'N', 1, NULL),
    (105, '2024-05-31 08:22:47', '2024-05-31 18:00:00', 'N', 'N', 1, NULL),
    
    -- 6월 (현충일 제외)
    (106, '2024-06-03 08:34:15', '2024-06-03 18:00:00', 'N', 'N', 1, NULL),
    (107, '2024-06-04 08:49:32', '2024-06-04 18:00:00', 'N', 'N', 1, NULL),
    (108, '2024-06-05 08:25:47', '2024-06-05 18:00:00', 'N', 'N', 1, NULL),
    (109, '2024-06-07 08:41:23', '2024-06-07 18:00:00', 'N', 'N', 1, NULL),
    (110, '2024-06-10 08:18:36', '2024-06-10 18:00:00', 'N', 'N', 1, NULL),
    (111, '2024-06-11 08:53:28', '2024-06-11 18:00:00', 'N', 'N', 1, NULL),
    (112, '2024-06-12 08:29:45', '2024-06-12 18:00:00', 'N', 'N', 1, NULL),
    (113, '2024-06-13 08:45:19', '2024-06-13 18:00:00', 'N', 'N', 1, NULL),
    (114, '2024-06-14 08:22:34', '2024-06-14 18:00:00', 'N', 'N', 1, NULL),
    (115, '2024-06-17 08:57:48', '2024-06-17 18:00:00', 'N', 'N', 1, NULL),
    (116, '2024-06-18 08:33:25', '2024-06-18 18:00:00', 'N', 'N', 1, NULL),
    (117, '2024-06-19 08:48:52', '2024-06-19 18:00:00', 'N', 'N', 1, NULL),
    (118, '2024-06-20 08:26:17', '2024-06-20 18:00:00', 'N', 'N', 1, NULL),
    (119, '2024-06-21 08:42:43', '2024-06-21 18:00:00', 'N', 'N', 1, NULL),
    (120, '2024-06-24 08:19:36', '2024-06-24 18:00:00', 'N', 'N', 1, NULL),
    (121, '2024-06-25 08:54:29', '2024-06-25 18:00:00', 'N', 'N', 1, NULL),
    (122, '2024-06-26 08:31:15', '2024-06-26 18:00:00', 'N', 'N', 1, NULL),
    (123, '2024-06-27 08:46:42', '2024-06-27 18:00:00', 'N', 'N', 1, NULL),
    (124, '2024-06-28 08:23:57', '2024-06-28 18:00:00', 'N', 'N', 1, NULL),

    -- 7월
    (125, '2024-07-01 08:35:22', '2024-07-01 18:00:00', 'N', 'N', 1, NULL),
    (126, '2024-07-02 08:48:45', '2024-07-02 18:00:00', 'N', 'N', 1, NULL),
    (127, '2024-07-03 08:24:33', '2024-07-03 18:00:00', 'N', 'N', 1, NULL),
    (128, '2024-07-04 08:41:17', '2024-07-04 18:00:00', 'N', 'N', 1, NULL),
    (129, '2024-07-05 08:19:52', '2024-07-05 18:00:00', 'N', 'N', 1, NULL),
    (130, '2024-07-08 08:55:28', '2024-07-08 18:00:00', 'N', 'N', 1, NULL),
    (131, '2024-07-09 08:32:14', '2024-07-09 18:00:00', 'N', 'N', 1, NULL),
    (132, '2024-07-10 08:47:39', '2024-07-10 18:00:00', 'N', 'N', 1, NULL),
    (133, '2024-07-11 08:23:55', '2024-07-11 18:00:00', 'N', 'N', 1, NULL),
    (134, '2024-07-12 08:39:21', '2024-07-12 18:00:00', 'N', 'N', 1, NULL),
    (135, '2024-07-15 08:18:47', '2024-07-15 18:00:00', 'N', 'N', 1, NULL),
    (136, '2024-07-16 08:54:33', '2024-07-16 18:00:00', 'N', 'N', 1, NULL),
    (137, '2024-07-17 08:29:16', '2024-07-17 18:00:00', 'N', 'N', 1, NULL),
    (138, '2024-07-18 08:45:42', '2024-07-18 18:00:00', 'N', 'N', 1, NULL),
    (139, '2024-07-19 08:22:58', '2024-07-19 18:00:00', 'N', 'N', 1, NULL),
    (140, '2024-07-22 08:38:25', '2024-07-22 18:00:00', 'N', 'N', 1, NULL),
    (141, '2024-07-23 08:17:49', '2024-07-23 18:00:00', 'N', 'N', 1, NULL),
    (142, '2024-07-24 08:53:14', '2024-07-24 18:00:00', 'N', 'N', 1, NULL),
    (143, '2024-07-25 08:28:37', '2024-07-25 18:00:00', 'N', 'N', 1, NULL),
    (144, '2024-07-26 08:44:53', '2024-07-26 18:00:00', 'N', 'N', 1, NULL),
    (145, '2024-07-29 08:21:19', '2024-07-29 18:00:00', 'N', 'N', 1, NULL),
    (146, '2024-07-30 08:37:45', '2024-07-30 18:00:00', 'N', 'N', 1, NULL),
    (147, '2024-07-31 08:16:32', '2024-07-31 18:00:00', 'N', 'N', 1, NULL),

    -- 8월 (광복절 제외)
    (148, '2024-08-01 08:52:28', '2024-08-01 18:00:00', 'N', 'N', 1, NULL),
    (149, '2024-08-02 08:27:45', '2024-08-02 18:00:00', 'N', 'N', 1, NULL),
    (150, '2024-08-05 08:43:19', '2024-08-05 18:00:00', 'N', 'N', 1, NULL),
    (151, '2024-08-06 08:19:54', '2024-08-06 18:00:00', 'N', 'N', 1, NULL),
    (152, '2024-08-07 08:36:27', '2024-08-07 18:00:00', 'N', 'N', 1, NULL),
    (153, '2024-08-08 08:15:43', '2024-08-08 18:00:00', 'N', 'N', 1, NULL),
    (154, '2024-08-09 08:51:16', '2024-08-09 18:00:00', 'N', 'N', 1, NULL),
    (155, '2024-08-12 08:26:32', '2024-08-12 18:00:00', 'N', 'N', 1, NULL),
    (156, '2024-08-13 08:42:58', '2024-08-13 18:00:00', 'N', 'N', 1, NULL),
    (157, '2024-08-14 08:19:25', '2024-08-14 18:00:00', 'N', 'N', 1, NULL),
    (158, '2024-08-16 08:35:51', '2024-08-16 18:00:00', 'N', 'N', 1, NULL),
    (159, '2024-08-19 08:14:17', '2024-08-19 18:00:00', 'N', 'N', 1, NULL),
    (160, '2024-08-20 08:50:43', '2024-08-20 18:00:00', 'N', 'N', 1, NULL),
    (161, '2024-08-21 08:25:19', '2024-08-21 18:00:00', 'N', 'N', 1, NULL),
    (162, '2024-08-22 08:41:45', '2024-08-22 18:00:00', 'N', 'N', 1, NULL),
    (163, '2024-08-23 08:18:22', '2024-08-23 18:00:00', 'N', 'N', 1, NULL),
    (164, '2024-08-26 08:34:48', '2024-08-26 18:00:00', 'N', 'N', 1, NULL),
    (165, '2024-08-27 08:13:15', '2024-08-27 18:00:00', 'N', 'N', 1, NULL),
    (166, '2024-08-28 08:49:41', '2024-08-28 18:00:00', 'N', 'N', 1, NULL),
    (167, '2024-08-29 08:24:27', '2024-08-29 18:00:00', 'N', 'N', 1, NULL),
    (168, '2024-08-30 08:40:53', '2024-08-30 18:00:00', 'N', 'N', 1, NULL),

    -- 9월 (추석 연휴 제외: 16-18일)
    (169, '2024-09-02 08:17:29', '2024-09-02 18:00:00', 'N', 'N', 1, NULL),
    (170, '2024-09-03 08:33:55', '2024-09-03 18:00:00', 'N', 'N', 1, NULL),
    (171, '2024-09-04 08:12:22', '2024-09-04 18:00:00', 'N', 'N', 1, NULL),
    (172, '2024-09-05 08:48:48', '2024-09-05 18:00:00', 'N', 'N', 1, NULL),
    (173, '2024-09-06 08:23:15', '2024-09-06 18:00:00', 'N', 'N', 1, NULL),
    (174, '2024-09-09 08:39:41', '2024-09-09 18:00:00', 'N', 'N', 1, NULL),
    (175, '2024-09-10 08:16:27', '2024-09-10 18:00:00', 'N', 'N', 1, NULL),
    (176, '2024-09-11 08:32:53', '2024-09-11 18:00:00', 'N', 'N', 1, NULL),
    (177, '2024-09-12 08:11:19', '2024-09-12 18:00:00', 'N', 'N', 1, NULL),
    (178, '2024-09-13 08:47:45', '2024-09-13 18:00:00', 'N', 'N', 1, NULL),
    (179, '2024-09-19 08:22:12', '2024-09-19 18:00:00', 'N', 'N', 1, NULL),
    (180, '2024-09-20 08:38:38', '2024-09-20 18:00:00', 'N', 'N', 1, NULL),
    (181, '2024-09-23 08:15:14', '2024-09-23 18:00:00', 'N', 'N', 1, NULL),
    (182, '2024-09-24 08:31:40', '2024-09-24 18:00:00', 'N', 'N', 1, NULL),
    (183, '2024-09-25 08:10:17', '2024-09-25 18:00:00', 'N', 'N', 1, NULL),
    (184, '2024-09-26 08:46:43', '2024-09-26 18:00:00', 'N', 'N', 1, NULL),
    (185, '2024-09-27 08:21:19', '2024-09-27 18:00:00', 'N', 'N', 1, NULL),
    (186, '2024-09-30 08:37:45', '2024-09-30 18:00:00', 'N', 'N', 1, NULL),

    -- 10월 (개천절, 한글날 제외)
    (187, '2024-10-01 08:14:22', '2024-10-01 18:00:00', 'N', 'N', 1, NULL),
    (188, '2024-10-02 08:30:48', '2024-10-02 18:00:00', 'N', 'N', 1, NULL),
    (189, '2024-10-04 08:09:15', '2024-10-04 18:00:00', 'N', 'N', 1, NULL),
    (190, '2024-10-07 08:45:41', '2024-10-07 18:00:00', 'N', 'N', 1, NULL),
    (191, '2024-10-08 08:20:17', '2024-10-08 18:00:00', 'N', 'N', 1, NULL),
    (192, '2024-10-10 08:36:43', '2024-10-10 18:00:00', 'N', 'N', 1, NULL),
    (193, '2024-10-11 08:13:19', '2024-10-11 18:00:00', 'N', 'N', 1, NULL),
    (194, '2024-10-14 08:29:45', '2024-10-14 18:00:00', 'N', 'N', 1, NULL),
    (195, '2024-10-15 08:08:12', '2024-10-15 18:00:00', 'N', 'N', 1, NULL),
    (196, '2024-10-16 08:44:38', '2024-10-16 18:00:00', 'N', 'N', 1, NULL),
    (197, '2024-10-17 08:19:15', '2024-10-17 18:00:00', 'N', 'N', 1, NULL),
    (198, '2024-10-18 08:35:41', '2024-10-18 18:00:00', 'N', 'N', 1, NULL),
    (199, '2024-10-21 08:12:17', '2024-10-21 18:00:00', 'N', 'N', 1, NULL),
    (200, '2024-10-22 08:28:43', '2024-10-22 18:00:00', 'N', 'N', 1, NULL),
    (201, '2024-10-23 08:07:19', '2024-10-23 18:00:00', 'N', 'N', 1, NULL),
    (202, '2024-10-24 08:43:45', '2024-10-24 18:00:00', 'N', 'N', 1, NULL),
    (203, '2024-10-25 08:18:22', '2024-10-25 18:00:00', 'N', 'N', 1, NULL),
    (204, '2024-10-28 08:34:48', '2024-10-28 18:00:00', 'N', 'N', 1, NULL),
    (205, '2024-10-29 08:11:15', '2024-10-29 18:00:00', 'N', 'N', 1, NULL),
    (206, '2024-10-30 08:27:41', '2024-10-30 18:00:00', 'N', 'N', 1, NULL),
    (207, '2024-10-31 08:06:17', '2024-10-31 18:00:00', 'N', 'N', 1, NULL),

    -- 11월
    (208, '2024-11-01 08:42:43', '2024-11-01 18:00:00', 'N', 'N', 1, NULL),
    (209, '2024-11-04 08:17:19', '2024-11-04 18:00:00', 'N', 'N', 1, NULL),
    (210, '2024-11-05 08:33:45', '2024-11-05 18:00:00', 'N', 'N', 1, NULL),
    (211, '2024-11-06 08:10:22', '2024-11-06 18:00:00', 'N', 'N', 1, NULL),
    (212, '2024-11-07 08:26:48', '2024-11-07 18:00:00', 'N', 'N', 1, NULL),
    (213, '2024-11-08 08:05:15', '2024-11-08 18:00:00', 'N', 'N', 1, NULL),
    (214, '2024-11-11 08:41:41', '2024-11-11 18:00:00', 'N', 'N', 1, NULL),
    (215, '2024-11-12 08:16:17', '2024-11-12 18:00:00', 'N', 'N', 1, NULL),
    (216, '2024-11-13 08:32:43', '2024-11-13 18:00:00', 'N', 'N', 1, NULL),
    (217, '2024-11-14 08:09:19', '2024-11-14 18:00:00', 'N', 'N', 1, NULL),
    (218, '2024-11-15 08:25:45', '2024-11-15 18:00:00', 'N', 'N', 1, NULL),
    (219, '2024-11-18 08:04:12', '2024-11-18 18:00:00', 'N', 'N', 1, NULL),
    (220, '2024-11-19 08:40:38', '2024-11-19 18:00:00', 'N', 'N', 1, NULL),
    (221, '2024-11-20 08:15:15', '2024-11-20 18:00:00', 'N', 'N', 1, NULL),
    (222, '2024-11-21 08:31:41', '2024-11-21 18:00:00', 'N', 'N', 1, NULL),
    (223, '2024-11-22 08:08:17', '2024-11-22 18:00:00', 'N', 'N', 1, NULL),
    (224, '2024-11-25 08:24:43', '2024-11-25 18:00:00', 'N', 'N', 1, NULL),
    (225, '2024-11-26 08:03:19', '2024-11-26 18:00:00', 'N', 'N', 1, NULL),
    (226, '2024-11-27 08:39:45', '2024-11-27 18:00:00', 'N', 'N', 1, NULL),
    (227, '2024-11-28 08:14:22', '2024-11-28 18:00:00', 'N', 'N', 1, NULL),
    (228, '2024-11-29 08:30:48', '2024-11-29 18:00:00', 'N', 'N', 1, NULL),

    -- 12월 (성탄절 제외)
    (229, '2024-12-02 08:07:15', '2024-12-02 18:00:00', 'N', 'N', 1, NULL),
    (230, '2024-12-03 08:23:41', '2024-12-03 18:00:00', 'N', 'N', 1, NULL),
    (231, '2024-12-04 08:02:17', '2024-12-04 18:00:00', 'N', 'N', 1, NULL),
    (232, '2024-12-05 08:38:43', '2024-12-05 18:00:00', 'N', 'N', 1, NULL),
    (233, '2024-12-06 08:13:19', '2024-12-06 18:00:00', 'N', 'N', 1, NULL),
    (234, '2024-12-09 08:29:45', '2024-12-09 18:00:00', 'N', 'N', 1, NULL),
    (235, '2024-12-10 08:06:12', '2024-12-10 18:00:00', 'N', 'N', 1, NULL),
    (236, '2024-12-11 08:42:38', '2024-12-11 18:00:00', 'N', 'N', 1, NULL),

    -- 1월 (신정 제외) - employee_id: 7
    (237, '2024-01-02 08:23:15', '2024-01-02 18:00:00', 'N', 'N', 7, NULL),
    (238, '2024-01-03 08:45:32', '2024-01-03 18:00:00', 'N', 'N', 7, NULL),
    (239, '2024-01-04 08:12:45', '2024-01-04 18:00:00', 'N', 'N', 7, NULL),
    (240, '2024-01-05 08:34:21', '2024-01-05 18:00:00', 'N', 'N', 7, NULL),
    (241, '2024-01-08 08:56:43', '2024-01-08 18:00:00', 'N', 'N', 7, NULL),
    (242, '2024-01-09 08:15:27', '2024-01-09 18:00:00', 'N', 'N', 7, NULL),
    (243, '2024-01-10 08:42:18', '2024-01-10 18:00:00', 'N', 'N', 7, NULL),
    (244, '2024-01-11 08:28:54', '2024-01-11 18:00:00', 'N', 'N', 7, NULL),
    (245, '2024-01-12 08:37:16', '2024-01-12 18:00:00', 'N', 'N', 7, NULL),
    (246, '2024-01-15 08:19:45', '2024-01-15 18:00:00', 'N', 'N', 7, NULL),
    (247, '2024-01-16 08:51:32', '2024-01-16 18:00:00', 'N', 'N', 7, NULL),
    (248, '2024-01-17 08:24:17', '2024-01-17 18:00:00', 'N', 'N', 7, NULL),
    (249, '2024-01-18 08:47:28', '2024-01-18 18:00:00', 'N', 'N', 7, NULL),
    (250, '2024-01-19 08:33:54', '2024-01-19 18:00:00', 'N', 'N', 7, NULL),
    (251, '2024-01-22 08:16:42', '2024-01-22 18:00:00', 'N', 'N', 7, NULL),
    (252, '2024-01-23 08:58:21', '2024-01-23 18:00:00', 'N', 'N', 7, NULL),
    (253, '2024-01-24 08:27:35', '2024-01-24 18:00:00', 'N', 'N', 7, NULL),
    (254, '2024-01-25 08:44:19', '2024-01-25 18:00:00', 'N', 'N', 7, NULL),
    (255, '2024-01-26 08:31:47', '2024-01-26 18:00:00', 'N', 'N', 7, NULL),
    (256, '2024-01-29 08:22:36', '2024-01-29 18:00:00', 'N', 'N', 7, NULL),
    (257, '2024-01-30 08:49:23', '2024-01-30 18:00:00', 'N', 'N', 7, NULL),
    (258, '2024-01-31 08:35:58', '2024-01-31 18:00:00', 'N', 'N', 7, NULL),

    -- 2월 (설날 연휴 제외: 9-11일) - employee_id: 7
    (259, '2024-02-01 08:26:45', '2024-02-01 18:00:00', 'N', 'N', 7, NULL),
    (260, '2024-02-02 08:53:12', '2024-02-02 18:00:00', 'N', 'N', 7, NULL),
    (261, '2024-02-05 08:18:34', '2024-02-05 18:00:00', 'N', 'N', 7, NULL),
    (262, '2024-02-06 08:41:27', '2024-02-06 18:00:00', 'N', 'N', 7, NULL),
    (263, '2024-02-07 08:29:53', '2024-02-07 18:00:00', 'N', 'N', 7, NULL),
    (264, '2024-02-08 08:55:16', '2024-02-08 18:00:00', 'N', 'N', 7, NULL),
    (265, '2024-02-12 08:23:48', '2024-02-12 18:00:00', 'N', 'N', 7, NULL),
    (266, '2024-02-13 08:47:32', '2024-02-13 18:00:00', 'N', 'N', 7, NULL),
    (267, '2024-02-14 08:34:15', '2024-02-14 18:00:00', 'N', 'N', 7, NULL),
    (268, '2024-02-15 08:21:49', '2024-02-15 18:00:00', 'N', 'N', 7, NULL),
    (269, '2024-02-16 08:52:37', '2024-02-16 18:00:00', 'N', 'N', 7, NULL),
    (270, '2024-02-19 08:28:54', '2024-02-19 18:00:00', 'N', 'N', 7, NULL),
    (271, '2024-02-20 08:43:21', '2024-02-20 18:00:00', 'N', 'N', 7, NULL),
    (272, '2024-02-21 08:37:46', '2024-02-21 18:00:00', 'N', 'N', 7, NULL),
    (273, '2024-02-22 08:19:32', '2024-02-22 18:00:00', 'N', 'N', 7, NULL),
    (274, '2024-02-23 08:56:14', '2024-02-23 18:00:00', 'N', 'N', 7, NULL),
    (275, '2024-02-26 08:31:45', '2024-02-26 18:00:00', 'N', 'N', 7, NULL),
    (276, '2024-02-27 08:48:23', '2024-02-27 18:00:00', 'N', 'N', 7, NULL),
    (277, '2024-02-28 08:25:57', '2024-02-28 18:00:00', 'N', 'N', 7, NULL),
    (278, '2024-02-29 08:54:32', '2024-02-29 18:00:00', 'N', 'N', 7, NULL),

    -- 3월 (삼일절 제외) - employee_id: 7
    (279, '2024-03-04 08:22:45', '2024-03-04 18:00:00', 'N', 'N', 7, NULL),
    (280, '2024-03-05 08:35:12', '2024-03-05 18:00:00', 'N', 'N', 7, NULL),
    (281, '2024-03-06 08:47:33', '2024-03-06 18:00:00', 'N', 'N', 7, NULL),
    (282, '2024-03-07 08:28:54', '2024-03-07 18:00:00', 'N', 'N', 7, NULL),
    (283, '2024-03-08 08:15:27', '2024-03-08 18:00:00', 'N', 'N', 7, NULL),
    (284, '2024-03-11 08:42:18', '2024-03-11 18:00:00', 'N', 'N', 7, NULL),
    (285, '2024-03-12 08:33:45', '2024-03-12 18:00:00', 'N', 'N', 7, NULL),
    (286, '2024-03-13 08:19:32', '2024-03-13 18:00:00', 'N', 'N', 7, NULL),
    (287, '2024-03-14 08:56:14', '2024-03-14 18:00:00', 'N', 'N', 7, NULL),
    (288, '2024-03-15 08:27:48', '2024-03-15 18:00:00', 'N', 'N', 7, NULL),
    (289, '2024-03-18 08:45:23', '2024-03-18 18:00:00', 'N', 'N', 7, NULL),
    (290, '2024-03-19 08:31:56', '2024-03-19 18:00:00', 'N', 'N', 7, NULL),
    (291, '2024-03-20 08:52:14', '2024-03-20 18:00:00', 'N', 'N', 7, NULL),
    (292, '2024-03-21 08:24:37', '2024-03-21 18:00:00', 'N', 'N', 7, NULL),
    (293, '2024-03-22 08:38:45', '2024-03-22 18:00:00', 'N', 'N', 7, NULL),
    (294, '2024-03-25 08:17:29', '2024-03-25 18:00:00', 'N', 'N', 7, NULL),
    (295, '2024-03-26 08:49:12', '2024-03-26 18:00:00', 'N', 'N', 7, NULL),
    (296, '2024-03-27 08:23:54', '2024-03-27 18:00:00', 'N', 'N', 7, NULL),
    (297, '2024-03-28 08:41:33', '2024-03-28 18:00:00', 'N', 'N', 7, NULL),
    (298, '2024-03-29 08:35:47', '2024-03-29 18:00:00', 'N', 'N', 7, NULL),

    -- 4월 계속 - employee_id: 7
    (300, '2024-04-02 08:42:33', '2024-04-02 18:00:00', 'N', 'N', 7, NULL),
    (301, '2024-04-03 08:19:47', '2024-04-03 18:00:00', 'N', 'N', 7, NULL),
    (302, '2024-04-04 08:55:22', '2024-04-04 18:00:00', 'N', 'N', 7, NULL),
    (303, '2024-04-05 08:31:48', '2024-04-05 18:00:00', 'N', 'N', 7, NULL),
    (304, '2024-04-08 08:47:15', '2024-04-08 18:00:00', 'N', 'N', 7, NULL),
    (305, '2024-04-09 08:23:54', '2024-04-09 18:00:00', 'N', 'N', 7, NULL),
    (306, '2024-04-10 08:38:27', '2024-04-10 18:00:00', 'N', 'N', 7, NULL),
    (307, '2024-04-11 08:15:42', '2024-04-11 18:00:00', 'N', 'N', 7, NULL),
    (308, '2024-04-12 08:52:33', '2024-04-12 18:00:00', 'N', 'N', 7, NULL),
    (309, '2024-04-15 08:29:18', '2024-04-15 18:00:00', 'N', 'N', 7, NULL),
    (310, '2024-04-16 08:44:56', '2024-04-16 18:00:00', 'N', 'N', 7, NULL),
    (311, '2024-04-17 08:21:34', '2024-04-17 18:00:00', 'N', 'N', 7, NULL),
    (312, '2024-04-18 08:57:12', '2024-04-18 18:00:00', 'N', 'N', 7, NULL),
    (313, '2024-04-19 08:33:45', '2024-04-19 18:00:00', 'N', 'N', 7, NULL),
    (314, '2024-04-22 08:48:23', '2024-04-22 18:00:00', 'N', 'N', 7, NULL),
    (315, '2024-04-23 08:25:54', '2024-04-23 18:00:00', 'N', 'N', 7, NULL),
    (316, '2024-04-24 08:41:27', '2024-04-24 18:00:00', 'N', 'N', 7, NULL),
    (317, '2024-04-25 08:17:38', '2024-04-25 18:00:00', 'N', 'N', 7, NULL),
    (318, '2024-04-26 08:53:15', '2024-04-26 18:00:00', 'N', 'N', 7, NULL),
    (319, '2024-04-29 08:28:42', '2024-04-29 18:00:00', 'N', 'N', 7, NULL),
    (320, '2024-04-30 08:45:19', '2024-04-30 18:00:00', 'N', 'N', 7, NULL),

    -- 5월 (어린이날, 부처님오신날 제외) - employee_id: 7
    (321, '2024-05-02 08:32:15', '2024-05-02 18:00:00', 'N', 'N', 7, NULL),
    (322, '2024-05-03 08:47:33', '2024-05-03 18:00:00', 'N', 'N', 7, NULL),
    (323, '2024-05-06 08:23:48', '2024-05-06 18:00:00', 'N', 'N', 7, NULL),
    (324, '2024-05-07 08:38:27', '2024-05-07 18:00:00', 'N', 'N', 7, NULL),
    (325, '2024-05-08 08:15:42', '2024-05-08 18:00:00', 'N', 'N', 7, NULL),
    (326, '2024-05-09 08:52:33', '2024-05-09 18:00:00', 'N', 'N', 7, NULL),
    (327, '2024-05-10 08:29:18', '2024-05-10 18:00:00', 'N', 'N', 7, NULL),
    (328, '2024-05-13 08:44:56', '2024-05-13 18:00:00', 'N', 'N', 7, NULL),
    (329, '2024-05-14 08:21:34', '2024-05-14 18:00:00', 'N', 'N', 7, NULL),
    (330, '2024-05-16 08:57:12', '2024-05-16 18:00:00', 'N', 'N', 7, NULL),
    (331, '2024-05-17 08:33:45', '2024-05-17 18:00:00', 'N', 'N', 7, NULL),
    (332, '2024-05-20 08:48:23', '2024-05-20 18:00:00', 'N', 'N', 7, NULL),
    (333, '2024-05-21 08:25:54', '2024-05-21 18:00:00', 'N', 'N', 7, NULL),
    (334, '2024-05-22 08:41:27', '2024-05-22 18:00:00', 'N', 'N', 7, NULL),
    (335, '2024-05-23 08:17:38', '2024-05-23 18:00:00', 'N', 'N', 7, NULL),
    (336, '2024-05-24 08:53:15', '2024-05-24 18:00:00', 'N', 'N', 7, NULL),
    (337, '2024-05-27 08:28:42', '2024-05-27 18:00:00', 'N', 'N', 7, NULL),
    (338, '2024-05-28 08:45:19', '2024-05-28 18:00:00', 'N', 'N', 7, NULL),
    (339, '2024-05-29 08:31:56', '2024-05-29 18:00:00', 'N', 'N', 7, NULL),
    (340, '2024-05-30 08:39:23', '2024-05-30 18:00:00', 'N', 'N', 7, NULL),
    (341, '2024-05-31 08:22:47', '2024-05-31 18:00:00', 'N', 'N', 7, NULL),

    -- 6월 (현충일 제외) - employee_id: 7
    (342, '2024-06-03 08:34:15', '2024-06-03 18:00:00', 'N', 'N', 7, NULL),
    (343, '2024-06-04 08:49:32', '2024-06-04 18:00:00', 'N', 'N', 7, NULL),
    (344, '2024-06-05 08:25:47', '2024-06-05 18:00:00', 'N', 'N', 7, NULL),
    (345, '2024-06-07 08:41:23', '2024-06-07 18:00:00', 'N', 'N', 7, NULL),
    (346, '2024-06-10 08:18:36', '2024-06-10 18:00:00', 'N', 'N', 7, NULL),
    (347, '2024-06-11 08:53:28', '2024-06-11 18:00:00', 'N', 'N', 7, NULL),
    (348, '2024-06-12 08:29:45', '2024-06-12 18:00:00', 'N', 'N', 7, NULL),
    (349, '2024-06-13 08:45:19', '2024-06-13 18:00:00', 'N', 'N', 7, NULL),
    (350, '2024-06-14 08:22:34', '2024-06-14 18:00:00', 'N', 'N', 7, NULL),
    (351, '2024-06-17 08:57:48', '2024-06-17 18:00:00', 'N', 'N', 7, NULL),
    (352, '2024-06-18 08:33:25', '2024-06-18 18:00:00', 'N', 'N', 7, NULL),
    (353, '2024-06-19 08:48:52', '2024-06-19 18:00:00', 'N', 'N', 7, NULL),
    (354, '2024-06-20 08:26:17', '2024-06-20 18:00:00', 'N', 'N', 7, NULL),
    (355, '2024-06-21 08:42:43', '2024-06-21 18:00:00', 'N', 'N', 7, NULL),
    (356, '2024-06-24 08:19:36', '2024-06-24 18:00:00', 'N', 'N', 7, NULL),
    (357, '2024-06-25 08:54:29', '2024-06-25 18:00:00', 'N', 'N', 7, NULL),
    (358, '2024-06-26 08:31:15', '2024-06-26 18:00:00', 'N', 'N', 7, NULL),
    (359, '2024-06-27 08:46:42', '2024-06-27 18:00:00', 'N', 'N', 7, NULL),
    (360, '2024-06-28 08:23:57', '2024-06-28 18:00:00', 'N', 'N', 7, NULL),

-- 7월 - employee_id: 7
    (361, '2024-07-01 08:35:22', '2024-07-01 18:00:00', 'N', 'N', 7, NULL),
    (362, '2024-07-02 08:48:45', '2024-07-02 18:00:00', 'N', 'N', 7, NULL),
    (363, '2024-07-03 08:24:33', '2024-07-03 18:00:00', 'N', 'N', 7, NULL),
    (364, '2024-07-04 08:41:17', '2024-07-04 18:00:00', 'N', 'N', 7, NULL),
    (365, '2024-07-05 08:19:52', '2024-07-05 18:00:00', 'N', 'N', 7, NULL),
    (366, '2024-07-08 08:55:28', '2024-07-08 18:00:00', 'N', 'N', 7, NULL),
    (367, '2024-07-09 08:32:14', '2024-07-09 18:00:00', 'N', 'N', 7, NULL),
    (368, '2024-07-10 08:47:39', '2024-07-10 18:00:00', 'N', 'N', 7, NULL),
    (369, '2024-07-11 08:23:55', '2024-07-11 18:00:00', 'N', 'N', 7, NULL),
    (370, '2024-07-12 08:39:21', '2024-07-12 18:00:00', 'N', 'N', 7, NULL),
    (371, '2024-07-15 08:18:47', '2024-07-15 18:00:00', 'N', 'N', 7, NULL),
    (372, '2024-07-16 08:54:33', '2024-07-16 18:00:00', 'N', 'N', 7, NULL),
    (373, '2024-07-17 08:29:16', '2024-07-17 18:00:00', 'N', 'N', 7, NULL),
    (374, '2024-07-18 08:45:42', '2024-07-18 18:00:00', 'N', 'N', 7, NULL),
    (375, '2024-07-19 08:22:58', '2024-07-19 18:00:00', 'N', 'N', 7, NULL),
    (376, '2024-07-22 08:38:25', '2024-07-22 18:00:00', 'N', 'N', 7, NULL),
    (377, '2024-07-23 08:17:49', '2024-07-23 18:00:00', 'N', 'N', 7, NULL),
    (378, '2024-07-24 08:53:14', '2024-07-24 18:00:00', 'N', 'N', 7, NULL),
    (379, '2024-07-25 08:28:37', '2024-07-25 18:00:00', 'N', 'N', 7, NULL),
    (380, '2024-07-26 08:44:53', '2024-07-26 18:00:00', 'N', 'N', 7, NULL),
    (381, '2024-07-29 08:21:19', '2024-07-29 18:00:00', 'N', 'N', 7, NULL),
    (382, '2024-07-30 08:37:45', '2024-07-30 18:00:00', 'N', 'N', 7, NULL),
    (383, '2024-07-31 08:16:32', '2024-07-31 18:00:00', 'N', 'N', 7, NULL),

    -- 8월 (광복절 제외) - employee_id: 7
    (384, '2024-08-01 08:52:28', '2024-08-01 18:00:00', 'N', 'N', 7, NULL),
    (385, '2024-08-02 08:27:45', '2024-08-02 18:00:00', 'N', 'N', 7, NULL),
    (386, '2024-08-05 08:43:19', '2024-08-05 18:00:00', 'N', 'N', 7, NULL),
    (387, '2024-08-06 08:19:54', '2024-08-06 18:00:00', 'N', 'N', 7, NULL),
    (388, '2024-08-07 08:36:27', '2024-08-07 18:00:00', 'N', 'N', 7, NULL),
    (389, '2024-08-08 08:15:43', '2024-08-08 18:00:00', 'N', 'N', 7, NULL),
    (390, '2024-08-09 08:51:16', '2024-08-09 18:00:00', 'N', 'N', 7, NULL),
    (391, '2024-08-12 08:26:32', '2024-08-12 18:00:00', 'N', 'N', 7, NULL),
    (392, '2024-08-13 08:42:58', '2024-08-13 18:00:00', 'N', 'N', 7, NULL),
    (393, '2024-08-14 08:19:25', '2024-08-14 18:00:00', 'N', 'N', 7, NULL),
    (394, '2024-08-16 08:35:51', '2024-08-16 18:00:00', 'N', 'N', 7, NULL),
    (395, '2024-08-19 08:14:17', '2024-08-19 18:00:00', 'N', 'N', 7, NULL),
    (396, '2024-08-20 08:50:43', '2024-08-20 18:00:00', 'N', 'N', 7, NULL),
    (397, '2024-08-21 08:25:19', '2024-08-21 18:00:00', 'N', 'N', 7, NULL),
    (398, '2024-08-22 08:41:45', '2024-08-22 18:00:00', 'N', 'N', 7, NULL),
    (399, '2024-08-23 08:18:22', '2024-08-23 18:00:00', 'N', 'N', 7, NULL),
    (400, '2024-08-26 08:34:48', '2024-08-26 18:00:00', 'N', 'N', 7, NULL),
    (401, '2024-08-27 08:13:15', '2024-08-27 18:00:00', 'N', 'N', 7, NULL),
    (402, '2024-08-28 08:49:41', '2024-08-28 18:00:00', 'N', 'N', 7, NULL),
    (403, '2024-08-29 08:24:27', '2024-08-29 18:00:00', 'N', 'N', 7, NULL),
    (404, '2024-08-30 08:40:53', '2024-08-30 18:00:00', 'N', 'N', 7, NULL),

    -- 9월 (추석 연휴 제외: 16-18일) - employee_id: 7
    (405, '2024-09-02 08:17:29', '2024-09-02 18:00:00', 'N', 'N', 7, NULL),
    (406, '2024-09-03 08:33:55', '2024-09-03 18:00:00', 'N', 'N', 7, NULL),
    (407, '2024-09-04 08:12:22', '2024-09-04 18:00:00', 'N', 'N', 7, NULL),
    (408, '2024-09-05 08:48:48', '2024-09-05 18:00:00', 'N', 'N', 7, NULL),
    (409, '2024-09-06 08:23:15', '2024-09-06 18:00:00', 'N', 'N', 7, NULL),
    (410, '2024-09-09 08:39:41', '2024-09-09 18:00:00', 'N', 'N', 7, NULL),
    (411, '2024-09-10 08:16:27', '2024-09-10 18:00:00', 'N', 'N', 7, NULL),
    (412, '2024-09-11 08:32:53', '2024-09-11 18:00:00', 'N', 'N', 7, NULL),
    (413, '2024-09-12 08:11:19', '2024-09-12 18:00:00', 'N', 'N', 7, NULL),
    (414, '2024-09-13 08:47:45', '2024-09-13 18:00:00', 'N', 'N', 7, NULL),
    (415, '2024-09-19 08:22:12', '2024-09-19 18:00:00', 'N', 'N', 7, NULL),
    (416, '2024-09-20 08:38:38', '2024-09-20 18:00:00', 'N', 'N', 7, NULL),
    (417, '2024-09-23 08:15:14', '2024-09-23 18:00:00', 'N', 'N', 7, NULL),
    (418, '2024-09-24 08:31:40', '2024-09-24 18:00:00', 'N', 'N', 7, NULL),
    (419, '2024-09-25 08:10:17', '2024-09-25 18:00:00', 'N', 'N', 7, NULL),
    (420, '2024-09-26 08:46:43', '2024-09-26 18:00:00', 'N', 'N', 7, NULL),
    (421, '2024-09-27 08:21:19', '2024-09-27 18:00:00', 'N', 'N', 7, NULL),
    (422, '2024-09-30 08:37:45', '2024-09-30 18:00:00', 'N', 'N', 7, NULL),

    -- 10월 (개천절, 한글날 제외) - employee_id: 7
    (423, '2024-10-01 08:14:22', '2024-10-01 18:00:00', 'N', 'N', 7, NULL),
    (424, '2024-10-02 08:30:48', '2024-10-02 18:00:00', 'N', 'N', 7, NULL),
    (425, '2024-10-04 08:09:15', '2024-10-04 18:00:00', 'N', 'N', 7, NULL),
    (426, '2024-10-07 08:45:41', '2024-10-07 18:00:00', 'N', 'N', 7, NULL),
    (427, '2024-10-08 08:20:17', '2024-10-08 18:00:00', 'N', 'N', 7, NULL),
    (428, '2024-10-10 08:36:43', '2024-10-10 18:00:00', 'N', 'N', 7, NULL),
    (429, '2024-10-11 08:13:19', '2024-10-11 18:00:00', 'N', 'N', 7, NULL),
    (430, '2024-10-14 08:29:45', '2024-10-14 18:00:00', 'N', 'N', 7, NULL),
    (431, '2024-10-15 08:08:12', '2024-10-15 18:00:00', 'N', 'N', 7, NULL),
    (432, '2024-10-16 08:44:38', '2024-10-16 18:00:00', 'N', 'N', 7, NULL),
    (433, '2024-10-17 08:19:15', '2024-10-17 18:00:00', 'N', 'N', 7, NULL),
    (434, '2024-10-18 08:35:41', '2024-10-18 18:00:00', 'N', 'N', 7, NULL),
    (435, '2024-10-21 08:12:17', '2024-10-21 18:00:00', 'N', 'N', 7, NULL),
    (436, '2024-10-22 08:28:43', '2024-10-22 18:00:00', 'N', 'N', 7, NULL),
    (437, '2024-10-23 08:07:19', '2024-10-23 18:00:00', 'N', 'N', 7, NULL),
    (438, '2024-10-24 08:43:45', '2024-10-24 18:00:00', 'N', 'N', 7, NULL),
    (439, '2024-10-25 08:18:22', '2024-10-25 18:00:00', 'N', 'N', 7, NULL),
    (440, '2024-10-28 08:34:48', '2024-10-28 18:00:00', 'N', 'N', 7, NULL),
    (441, '2024-10-29 08:11:15', '2024-10-29 18:00:00', 'N', 'N', 7, NULL),
    (442, '2024-10-30 08:27:41', '2024-10-30 18:00:00', 'N', 'N', 7, NULL),
    (443, '2024-10-31 08:06:17', '2024-10-31 18:00:00', 'N', 'N', 7, NULL),

    -- 11월 - employee_id: 7
    (444, '2024-11-01 08:42:43', '2024-11-01 18:00:00', 'N', 'N', 7, NULL),
    (445, '2024-11-04 08:17:19', '2024-11-04 18:00:00', 'N', 'N', 7, NULL),
    (446, '2024-11-05 08:33:45', '2024-11-05 18:00:00', 'N', 'N', 7, NULL),
    (447, '2024-11-06 08:10:22', '2024-11-06 18:00:00', 'N', 'N', 7, NULL),
    (448, '2024-11-07 08:26:48', '2024-11-07 18:00:00', 'N', 'N', 7, NULL),
    (449, '2024-11-08 08:05:15', '2024-11-08 18:00:00', 'N', 'N', 7, NULL),
    (450, '2024-11-11 08:41:41', '2024-11-11 18:00:00', 'N', 'N', 7, NULL),
    (451, '2024-11-12 08:16:17', '2024-11-12 18:00:00', 'N', 'N', 7, NULL),
    (452, '2024-11-13 08:32:43', '2024-11-13 18:00:00', 'N', 'N', 7, NULL),
    (453, '2024-11-14 08:09:19', '2024-11-14 18:00:00', 'N', 'N', 7, NULL),
    (454, '2024-11-15 08:25:45', '2024-11-15 18:00:00', 'N', 'N', 7, NULL),
    (455, '2024-11-18 08:04:12', '2024-11-18 18:00:00', 'N', 'N', 7, NULL),
    (456, '2024-11-19 08:40:38', '2024-11-19 18:00:00', 'N', 'N', 7, NULL),
    (457, '2024-11-20 08:15:15', '2024-11-20 18:00:00', 'N', 'N', 7, NULL),
    (458, '2024-11-21 08:31:41', '2024-11-21 18:00:00', 'N', 'N', 7, NULL),
    (459, '2024-11-22 08:08:17', '2024-11-22 18:00:00', 'N', 'N', 7, NULL),
    (460, '2024-11-25 08:24:43', '2024-11-25 18:00:00', 'N', 'N', 7, NULL),
    (461, '2024-11-26 08:03:19', '2024-11-26 18:00:00', 'N', 'N', 7, NULL),
    (462, '2024-11-27 08:39:45', '2024-11-27 18:00:00', 'N', 'N', 7, NULL),
    (463, '2024-11-28 08:14:22', '2024-11-28 18:00:00', 'N', 'N', 7, NULL),
    (464, '2024-11-29 08:30:48', '2024-11-29 18:00:00', 'N', 'N', 7, NULL),

    -- 12월 (성탄절 제외, 12월 10일까지) - employee_id: 7
    (465, '2024-12-02 08:07:15', '2024-12-02 18:00:00', 'N', 'N', 7, NULL),
    (466, '2024-12-03 08:23:41', '2024-12-03 18:00:00', 'N', 'N', 7, NULL),
    (467, '2024-12-04 08:02:17', '2024-12-04 18:00:00', 'N', 'N', 7, NULL),
    (468, '2024-12-05 08:38:43', '2024-12-05 18:00:00', 'N', 'N', 7, NULL),
    (469, '2024-12-06 08:13:19', '2024-12-06 18:00:00', 'N', 'N', 7, NULL),
    (470, '2024-12-09 08:29:45', '2024-12-09 18:00:00', 'N', 'N', 7, NULL),
    (471, '2024-12-10 08:06:12', '2024-12-10 18:00:00', 'N', 'N', 7, NULL),

    -- employee_id : 1 2023년 출퇴근 데이터
    (472, '2023-01-02 08:15:23', '2023-01-02 18:00:00', 'N', 'N', 1, NULL),
    (473, '2023-01-03 08:45:12', '2023-01-03 18:00:00', 'N', 'N', 1, NULL),
    (474, '2023-01-04 08:32:45', '2023-01-04 18:00:00', 'N', 'N', 1, NULL),
    (475, '2023-01-05 08:05:34', '2023-01-05 18:00:00', 'N', 'N', 1, NULL),
    (476, '2023-01-06 08:22:56', '2023-01-06 18:00:00', 'N', 'N', 1, NULL),
    (477, '2023-01-09 08:17:23', '2023-01-09 18:00:00', 'N', 'N', 1, NULL),
    (478, '2023-01-10 08:28:45', '2023-01-10 18:00:00', 'N', 'N', 1, NULL),
    (479, '2023-01-11 08:38:12', '2023-01-11 18:00:00', 'N', 'N', 1, NULL),
    (480, '2023-01-12 08:12:34', '2023-01-12 18:00:00', 'N', 'N', 1, NULL),
    (481, '2023-01-13 08:25:45', '2023-01-13 18:00:00', 'N', 'N', 1, NULL),
    (482, '2023-01-16 08:42:23', '2023-01-16 18:00:00', 'N', 'N', 1, NULL),
    (483, '2023-01-17 08:15:56', '2023-01-17 18:00:00', 'N', 'N', 1, NULL),
    (484, '2023-01-18 08:33:12', '2023-01-18 18:00:00', 'N', 'N', 1, NULL),
    (485, '2023-01-19 08:27:45', '2023-01-19 18:00:00', 'N', 'N', 1, NULL),
    (486, '2023-01-20 08:18:34', '2023-01-20 18:00:00', 'N', 'N', 1, NULL),
    (487, '2023-01-25 08:22:23', '2023-01-25 18:00:00', 'N', 'N', 1, NULL),
    (488, '2023-01-26 08:35:45', '2023-01-26 18:00:00', 'N', 'N', 1, NULL),
    (489, '2023-01-27 08:28:12', '2023-01-27 18:00:00', 'N', 'N', 1, NULL),
    (490, '2023-01-30 08:15:34', '2023-01-30 18:00:00', 'N', 'N', 1, NULL),
    (491, '2023-01-31 08:42:56', '2023-01-31 18:00:00', 'N', 'N', 1, NULL),

    -- 2023년 2월
    (492, '2023-02-01 08:25:23', '2023-02-01 18:00:00', 'N', 'N', 1, NULL),
    (493, '2023-02-02 08:38:45', '2023-02-02 18:00:00', 'N', 'N', 1, NULL),
    (494, '2023-02-03 08:17:12', '2023-02-03 18:00:00', 'N', 'N', 1, NULL),
    (495, '2023-02-06 08:28:34', '2023-02-06 18:00:00', 'N', 'N', 1, NULL),
    (496, '2023-02-07 08:35:56', '2023-02-07 18:00:00', 'N', 'N', 1, NULL),
    (497, '2023-02-08 08:22:23', '2023-02-08 18:00:00', 'N', 'N', 1, NULL),
    (498, '2023-02-09 08:45:45', '2023-02-09 18:00:00', 'N', 'N', 1, NULL),
    (499, '2023-02-10 08:32:12', '2023-02-10 18:00:00', 'N', 'N', 1, NULL),
    (500, '2023-02-13 08:18:34', '2023-02-13 18:00:00', 'N', 'N', 1, NULL),
    (501, '2023-02-14 08:27:56', '2023-02-14 18:00:00', 'N', 'N', 1, NULL),
    (502, '2023-02-15 08:35:23', '2023-02-15 18:00:00', 'N', 'N', 1, NULL),
    (503, '2023-02-16 08:42:45', '2023-02-16 18:00:00', 'N', 'N', 1, NULL),
    (504, '2023-02-17 08:15:12', '2023-02-17 18:00:00', 'N', 'N', 1, NULL),
    (505, '2023-02-20 08:28:34', '2023-02-20 18:00:00', 'N', 'N', 1, NULL),
    (506, '2023-02-21 08:37:56', '2023-02-21 18:00:00', 'N', 'N', 1, NULL),
    (507, '2023-02-22 08:22:23', '2023-02-22 18:00:00', 'N', 'N', 1, NULL),
    (508, '2023-02-23 08:45:45', '2023-02-23 18:00:00', 'N', 'N', 1, NULL),
    (509, '2023-02-24 08:32:12', '2023-02-24 18:00:00', 'N', 'N', 1, NULL),
    (510, '2023-02-27 08:18:34', '2023-02-27 18:00:00', 'N', 'N', 1, NULL),
    (511, '2023-02-28 08:27:56', '2023-02-28 18:00:00', 'N', 'N', 1, NULL),

    -- 2023년 3월 (3/1 삼일절 제외)
    (512, '2023-03-02 08:35:23', '2023-03-02 18:00:00', 'N', 'N', 1, NULL),
    (513, '2023-03-03 08:42:45', '2023-03-03 18:00:00', 'N', 'N', 1, NULL),
    (514, '2023-03-06 08:15:12', '2023-03-06 18:00:00', 'N', 'N', 1, NULL),
    (515, '2023-03-07 08:28:34', '2023-03-07 18:00:00', 'N', 'N', 1, NULL),
    (516, '2023-03-08 08:37:56', '2023-03-08 18:00:00', 'N', 'N', 1, NULL),
    (517, '2023-03-09 08:22:23', '2023-03-09 18:00:00', 'N', 'N', 1, NULL),
    (518, '2023-03-10 08:45:45', '2023-03-10 18:00:00', 'N', 'N', 1, NULL),
    (519, '2023-03-13 08:32:12', '2023-03-13 18:00:00', 'N', 'N', 1, NULL),
    (520, '2023-03-14 08:18:34', '2023-03-14 18:00:00', 'N', 'N', 1, NULL),
    (521, '2023-03-15 08:27:56', '2023-03-15 18:00:00', 'N', 'N', 1, NULL),
    (522, '2023-03-16 08:35:23', '2023-03-16 18:00:00', 'N', 'N', 1, NULL),
    (523, '2023-03-17 08:42:45', '2023-03-17 18:00:00', 'N', 'N', 1, NULL),
    (524, '2023-03-20 08:15:12', '2023-03-20 18:00:00', 'N', 'N', 1, NULL),
    (525, '2023-03-21 08:28:34', '2023-03-21 18:00:00', 'N', 'N', 1, NULL),
    (526, '2023-03-22 08:37:56', '2023-03-22 18:00:00', 'N', 'N', 1, NULL),
    (527, '2023-03-23 08:22:23', '2023-03-23 18:00:00', 'N', 'N', 1, NULL),
    (528, '2023-03-24 08:45:45', '2023-03-24 18:00:00', 'N', 'N', 1, NULL),
    (529, '2023-03-27 08:32:12', '2023-03-27 18:00:00', 'N', 'N', 1, NULL),
    (530, '2023-03-28 08:18:34', '2023-03-28 18:00:00', 'N', 'N', 1, NULL),
    (531, '2023-03-29 08:27:56', '2023-03-29 18:00:00', 'N', 'N', 1, NULL),
    (532, '2023-03-30 08:35:23', '2023-03-30 18:00:00', 'N', 'N', 1, NULL),
    (533, '2023-03-31 08:42:45', '2023-03-31 18:00:00', 'N', 'N', 1, NULL),

    (534, '2023-04-03 08:15:23', '2023-04-03 18:00:00', 'N', 'N', 1, NULL),
(535, '2023-04-04 08:38:45', '2023-04-04 18:00:00', 'N', 'N', 1, NULL),
(536, '2023-04-05 08:27:12', '2023-04-05 18:00:00', 'N', 'N', 1, NULL),
(537, '2023-04-06 08:42:34', '2023-04-06 18:00:00', 'N', 'N', 1, NULL),
(538, '2023-04-07 08:18:56', '2023-04-07 18:00:00', 'N', 'N', 1, NULL),
(539, '2023-04-10 08:35:23', '2023-04-10 18:00:00', 'N', 'N', 1, NULL),
(540, '2023-04-11 08:22:45', '2023-04-11 18:00:00', 'N', 'N', 1, NULL),
(541, '2023-04-12 08:45:12', '2023-04-12 18:00:00', 'N', 'N', 1, NULL),
(542, '2023-04-13 08:33:34', '2023-04-13 18:00:00', 'N', 'N', 1, NULL),
(543, '2023-04-14 08:28:56', '2023-04-14 18:00:00', 'N', 'N', 1, NULL),
(544, '2023-04-17 08:17:23', '2023-04-17 18:00:00', 'N', 'N', 1, NULL),
(545, '2023-04-18 08:42:45', '2023-04-18 18:00:00', 'N', 'N', 1, NULL),
(546, '2023-04-19 08:25:12', '2023-04-19 18:00:00', 'N', 'N', 1, NULL),
(547, '2023-04-20 08:38:34', '2023-04-20 18:00:00', 'N', 'N', 1, NULL),
(548, '2023-04-21 08:15:56', '2023-04-21 18:00:00', 'N', 'N', 1, NULL),
(549, '2023-04-24 08:32:23', '2023-04-24 18:00:00', 'N', 'N', 1, NULL),
(550, '2023-04-25 08:27:45', '2023-04-25 18:00:00', 'N', 'N', 1, NULL),
(551, '2023-04-26 08:42:12', '2023-04-26 18:00:00', 'N', 'N', 1, NULL),
(552, '2023-04-27 08:18:34', '2023-04-27 18:00:00', 'N', 'N', 1, NULL),
(553, '2023-04-28 08:35:56', '2023-04-28 18:00:00', 'N', 'N', 1, NULL),

-- 2023년 5월 (5/5 어린이날, 5/27 부처님오신날 제외)
(554, '2023-05-01 08:22:23', '2023-05-01 18:00:00', 'N', 'N', 1, NULL),
(555, '2023-05-02 08:45:45', '2023-05-02 18:00:00', 'N', 'N', 1, NULL),
(556, '2023-05-03 08:33:12', '2023-05-03 18:00:00', 'N', 'N', 1, NULL),
(557, '2023-05-04 08:28:34', '2023-05-04 18:00:00', 'N', 'N', 1, NULL),
(558, '2023-05-08 08:17:56', '2023-05-08 18:00:00', 'N', 'N', 1, NULL),
(559, '2023-05-09 08:42:23', '2023-05-09 18:00:00', 'N', 'N', 1, NULL),
(560, '2023-05-10 08:25:45', '2023-05-10 18:00:00', 'N', 'N', 1, NULL),
(561, '2023-05-11 08:38:12', '2023-05-11 18:00:00', 'N', 'N', 1, NULL),
(562, '2023-05-12 08:15:34', '2023-05-12 18:00:00', 'N', 'N', 1, NULL),
(563, '2023-05-15 08:32:56', '2023-05-15 18:00:00', 'N', 'N', 1, NULL),
(564, '2023-05-16 08:27:23', '2023-05-16 18:00:00', 'N', 'N', 1, NULL),
(565, '2023-05-17 08:42:45', '2023-05-17 18:00:00', 'N', 'N', 1, NULL),
(566, '2023-05-18 08:18:12', '2023-05-18 18:00:00', 'N', 'N', 1, NULL),
(567, '2023-05-19 08:35:34', '2023-05-19 18:00:00', 'N', 'N', 1, NULL),
(568, '2023-05-22 08:22:56', '2023-05-22 18:00:00', 'N', 'N', 1, NULL),
(569, '2023-05-23 08:45:23', '2023-05-23 18:00:00', 'N', 'N', 1, NULL),
(570, '2023-05-24 08:33:45', '2023-05-24 18:00:00', 'N', 'N', 1, NULL),
(571, '2023-05-25 08:28:12', '2023-05-25 18:00:00', 'N', 'N', 1, NULL),
(572, '2023-05-26 08:17:34', '2023-05-26 18:00:00', 'N', 'N', 1, NULL),
(573, '2023-05-29 08:42:56', '2023-05-29 18:00:00', 'N', 'N', 1, NULL),
(574, '2023-05-30 08:25:23', '2023-05-30 18:00:00', 'N', 'N', 1, NULL),
(575, '2023-05-31 08:38:45', '2023-05-31 18:00:00', 'N', 'N', 1, NULL),

-- 2023년 6월 (6/6 현충일 제외)
(576, '2023-06-01 08:15:12', '2023-06-01 18:00:00', 'N', 'N', 1, NULL),
(577, '2023-06-02 08:32:34', '2023-06-02 18:00:00', 'N', 'N', 1, NULL),
(578, '2023-06-05 08:27:56', '2023-06-05 18:00:00', 'N', 'N', 1, NULL),
(579, '2023-06-07 08:42:23', '2023-06-07 18:00:00', 'N', 'N', 1, NULL),
(580, '2023-06-08 08:18:45', '2023-06-08 18:00:00', 'N', 'N', 1, NULL),
(581, '2023-06-09 08:35:12', '2023-06-09 18:00:00', 'N', 'N', 1, NULL),
(582, '2023-06-12 08:22:34', '2023-06-12 18:00:00', 'N', 'N', 1, NULL),
(583, '2023-06-13 08:45:56', '2023-06-13 18:00:00', 'N', 'N', 1, NULL),
(584, '2023-06-14 08:33:23', '2023-06-14 18:00:00', 'N', 'N', 1, NULL),
(585, '2023-06-15 08:28:45', '2023-06-15 18:00:00', 'N', 'N', 1, NULL),
(586, '2023-06-16 08:17:12', '2023-06-16 18:00:00', 'N', 'N', 1, NULL),
(587, '2023-06-19 08:42:34', '2023-06-19 18:00:00', 'N', 'N', 1, NULL),
(588, '2023-06-20 08:25:56', '2023-06-20 18:00:00', 'N', 'N', 1, NULL),
(589, '2023-06-21 08:38:23', '2023-06-21 18:00:00', 'N', 'N', 1, NULL),
(590, '2023-06-22 08:15:45', '2023-06-22 18:00:00', 'N', 'N', 1, NULL),
(591, '2023-06-23 08:32:12', '2023-06-23 18:00:00', 'N', 'N', 1, NULL),
(592, '2023-06-26 08:27:34', '2023-06-26 18:00:00', 'N', 'N', 1, NULL),
(593, '2023-06-27 08:42:56', '2023-06-27 18:00:00', 'N', 'N', 1, NULL),
(594, '2023-06-28 08:18:23', '2023-06-28 18:00:00', 'N', 'N', 1, NULL),
(595, '2023-06-29 08:35:45', '2023-06-29 18:00:00', 'N', 'N', 1, NULL),
(596, '2023-06-30 08:22:12', '2023-06-30 18:00:00', 'N', 'N', 1, NULL),

(597, '2023-07-03 08:25:23', '2023-07-03 18:00:00', 'N', 'N', 1, NULL),
(598, '2023-07-04 08:38:45', '2023-07-04 18:00:00', 'N', 'N', 1, NULL),
(599, '2023-07-05 08:17:12', '2023-07-05 18:00:00', 'N', 'N', 1, NULL),
(600, '2023-07-06 08:42:34', '2023-07-06 18:00:00', 'N', 'N', 1, NULL),
(601, '2023-07-07 08:28:56', '2023-07-07 18:00:00', 'N', 'N', 1, NULL),
(602, '2023-07-10 08:35:23', '2023-07-10 18:00:00', 'N', 'N', 1, NULL),
(603, '2023-07-11 08:22:45', '2023-07-11 18:00:00', 'N', 'N', 1, NULL),
(604, '2023-07-12 08:45:12', '2023-07-12 18:00:00', 'N', 'N', 1, NULL),
(605, '2023-07-13 08:32:34', '2023-07-13 18:00:00', 'N', 'N', 1, NULL),
(606, '2023-07-14 08:18:56', '2023-07-14 18:00:00', 'N', 'N', 1, NULL),
(607, '2023-07-17 08:27:23', '2023-07-17 18:00:00', 'N', 'N', 1, NULL),
(608, '2023-07-18 08:42:45', '2023-07-18 18:00:00', 'N', 'N', 1, NULL),
(609, '2023-07-19 08:15:12', '2023-07-19 18:00:00', 'N', 'N', 1, NULL),
(610, '2023-07-20 08:38:34', '2023-07-20 18:00:00', 'N', 'N', 1, NULL),
(611, '2023-07-21 08:25:56', '2023-07-21 18:00:00', 'N', 'N', 1, NULL),
(612, '2023-07-24 08:32:23', '2023-07-24 18:00:00', 'N', 'N', 1, NULL),
(613, '2023-07-25 08:17:45', '2023-07-25 18:00:00', 'N', 'N', 1, NULL),
(614, '2023-07-26 08:42:12', '2023-07-26 18:00:00', 'N', 'N', 1, NULL),
(615, '2023-07-27 08:28:34', '2023-07-27 18:00:00', 'N', 'N', 1, NULL),
(616, '2023-07-28 08:35:56', '2023-07-28 18:00:00', 'N', 'N', 1, NULL),
(617, '2023-07-31 08:22:23', '2023-07-31 18:00:00', 'N', 'N', 1, NULL),

-- 2023년 8월 (8/15 광복절 제외)
(618, '2023-08-01 08:45:45', '2023-08-01 18:00:00', 'N', 'N', 1, NULL),
(619, '2023-08-02 08:32:12', '2023-08-02 18:00:00', 'N', 'N', 1, NULL),
(620, '2023-08-03 08:18:34', '2023-08-03 18:00:00', 'N', 'N', 1, NULL),
(621, '2023-08-04 08:27:56', '2023-08-04 18:00:00', 'N', 'N', 1, NULL),
(622, '2023-08-07 08:42:23', '2023-08-07 18:00:00', 'N', 'N', 1, NULL),
(623, '2023-08-08 08:15:45', '2023-08-08 18:00:00', 'N', 'N', 1, NULL),
(624, '2023-08-09 08:38:12', '2023-08-09 18:00:00', 'N', 'N', 1, NULL),
(625, '2023-08-10 08:25:34', '2023-08-10 18:00:00', 'N', 'N', 1, NULL),
(626, '2023-08-11 08:32:56', '2023-08-11 18:00:00', 'N', 'N', 1, NULL),
(627, '2023-08-14 08:17:23', '2023-08-14 18:00:00', 'N', 'N', 1, NULL),
(628, '2023-08-16 08:42:45', '2023-08-16 18:00:00', 'N', 'N', 1, NULL),
(629, '2023-08-17 08:28:12', '2023-08-17 18:00:00', 'N', 'N', 1, NULL),
(630, '2023-08-18 08:35:34', '2023-08-18 18:00:00', 'N', 'N', 1, NULL),
(631, '2023-08-21 08:22:56', '2023-08-21 18:00:00', 'N', 'N', 1, NULL),
(632, '2023-08-22 08:45:23', '2023-08-22 18:00:00', 'N', 'N', 1, NULL),
(633, '2023-08-23 08:32:45', '2023-08-23 18:00:00', 'N', 'N', 1, NULL),
(634, '2023-08-24 08:18:12', '2023-08-24 18:00:00', 'N', 'N', 1, NULL),
(635, '2023-08-25 08:27:34', '2023-08-25 18:00:00', 'N', 'N', 1, NULL),
(636, '2023-08-28 08:42:56', '2023-08-28 18:00:00', 'N', 'N', 1, NULL),
(637, '2023-08-29 08:15:23', '2023-08-29 18:00:00', 'N', 'N', 1, NULL),
(638, '2023-08-30 08:38:45', '2023-08-30 18:00:00', 'N', 'N', 1, NULL),
(639, '2023-08-31 08:25:12', '2023-08-31 18:00:00', 'N', 'N', 1, NULL),

-- 2023년 9월 (9/28-30 추석연휴 제외)
(640, '2023-09-01 08:32:34', '2023-09-01 18:00:00', 'N', 'N', 1, NULL),
(641, '2023-09-04 08:17:56', '2023-09-04 18:00:00', 'N', 'N', 1, NULL),
(642, '2023-09-05 08:42:23', '2023-09-05 18:00:00', 'N', 'N', 1, NULL),
(643, '2023-09-06 08:28:45', '2023-09-06 18:00:00', 'N', 'N', 1, NULL),
(644, '2023-09-07 08:35:12', '2023-09-07 18:00:00', 'N', 'N', 1, NULL),
(645, '2023-09-08 08:22:34', '2023-09-08 18:00:00', 'N', 'N', 1, NULL),
(646, '2023-09-11 08:45:56', '2023-09-11 18:00:00', 'N', 'N', 1, NULL),
(647, '2023-09-12 08:32:23', '2023-09-12 18:00:00', 'N', 'N', 1, NULL),
(648, '2023-09-13 08:18:45', '2023-09-13 18:00:00', 'N', 'N', 1, NULL),
(649, '2023-09-14 08:27:12', '2023-09-14 18:00:00', 'N', 'N', 1, NULL),
(650, '2023-09-15 08:42:34', '2023-09-15 18:00:00', 'N', 'N', 1, NULL),
(651, '2023-09-18 08:15:56', '2023-09-18 18:00:00', 'N', 'N', 1, NULL),
(652, '2023-09-19 08:38:23', '2023-09-19 18:00:00', 'N', 'N', 1, NULL),
(653, '2023-09-20 08:25:45', '2023-09-20 18:00:00', 'N', 'N', 1, NULL),
(654, '2023-09-21 08:32:12', '2023-09-21 18:00:00', 'N', 'N', 1, NULL),
(655, '2023-09-22 08:17:34', '2023-09-22 18:00:00', 'N', 'N', 1, NULL),
(656, '2023-09-25 08:42:56', '2023-09-25 18:00:00', 'N', 'N', 1, NULL),
(657, '2023-09-26 08:28:23', '2023-09-26 18:00:00', 'N', 'N', 1, NULL),
(658, '2023-09-27 08:35:45', '2023-09-27 18:00:00', 'N', 'N', 1, NULL),

-- 2023년 10월 (10/3 개천절, 10/9 한글날 제외)
(659, '2023-10-02 08:22:12', '2023-10-02 18:00:00', 'N', 'N', 1, NULL),
(660, '2023-10-04 08:45:34', '2023-10-04 18:00:00', 'N', 'N', 1, NULL),
(661, '2023-10-05 08:32:56', '2023-10-05 18:00:00', 'N', 'N', 1, NULL),
(662, '2023-10-06 08:18:23', '2023-10-06 18:00:00', 'N', 'N', 1, NULL),
(663, '2023-10-10 08:27:45', '2023-10-10 18:00:00', 'N', 'N', 1, NULL),
(664, '2023-10-11 08:42:12', '2023-10-11 18:00:00', 'N', 'N', 1, NULL),
(665, '2023-10-12 08:15:34', '2023-10-12 18:00:00', 'N', 'N', 1, NULL),
(666, '2023-10-13 08:38:56', '2023-10-13 18:00:00', 'N', 'N', 1, NULL),
(667, '2023-10-16 08:25:23', '2023-10-16 18:00:00', 'N', 'N', 1, NULL),
(668, '2023-10-17 08:32:45', '2023-10-17 18:00:00', 'N', 'N', 1, NULL),
(669, '2023-10-18 08:17:12', '2023-10-18 18:00:00', 'N', 'N', 1, NULL),
(670, '2023-10-19 08:42:34', '2023-10-19 18:00:00', 'N', 'N', 1, NULL),
(671, '2023-10-20 08:28:56', '2023-10-20 18:00:00', 'N', 'N', 1, NULL),
(672, '2023-10-23 08:35:23', '2023-10-23 18:00:00', 'N', 'N', 1, NULL),
(673, '2023-10-24 08:22:45', '2023-10-24 18:00:00', 'N', 'N', 1, NULL),
(674, '2023-10-25 08:45:12', '2023-10-25 18:00:00', 'N', 'N', 1, NULL),
(675, '2023-10-26 08:32:34', '2023-10-26 18:00:00', 'N', 'N', 1, NULL),
(676, '2023-10-27 08:18:56', '2023-10-27 18:00:00', 'N', 'N', 1, NULL),
(677, '2023-10-30 08:27:23', '2023-10-30 18:00:00', 'N', 'N', 1, NULL),
(678, '2023-10-31 08:42:45', '2023-10-31 18:00:00', 'N', 'N', 1, NULL),

-- 2023년 11월
(679, '2023-11-01 08:15:12', '2023-11-01 18:00:00', 'N', 'N', 1, NULL),
(680, '2023-11-02 08:38:34', '2023-11-02 18:00:00', 'N', 'N', 1, NULL),
(681, '2023-11-03 08:25:56', '2023-11-03 18:00:00', 'N', 'N', 1, NULL),
(682, '2023-11-06 08:32:23', '2023-11-06 18:00:00', 'N', 'N', 1, NULL),
(683, '2023-11-07 08:17:45', '2023-11-07 18:00:00', 'N', 'N', 1, NULL),
(684, '2023-11-08 08:42:12', '2023-11-08 18:00:00', 'N', 'N', 1, NULL),
(685, '2023-11-09 08:28:34', '2023-11-09 18:00:00', 'N', 'N', 1, NULL),
(686, '2023-11-10 08:35:56', '2023-11-10 18:00:00', 'N', 'N', 1, NULL),
(687, '2023-11-13 08:22:23', '2023-11-13 18:00:00', 'N', 'N', 1, NULL),
(688, '2023-11-14 08:45:45', '2023-11-14 18:00:00', 'N', 'N', 1, NULL),
(689, '2023-11-15 08:32:12', '2023-11-15 18:00:00', 'N', 'N', 1, NULL),
(690, '2023-11-16 08:18:34', '2023-11-16 18:00:00', 'N', 'N', 1, NULL),
(691, '2023-11-17 08:27:56', '2023-11-17 18:00:00', 'N', 'N', 1, NULL),
(692, '2023-11-20 08:42:23', '2023-11-20 18:00:00', 'N', 'N', 1, NULL),
(693, '2023-11-21 08:15:45', '2023-11-21 18:00:00', 'N', 'N', 1, NULL),
(694, '2023-11-22 08:38:12', '2023-11-22 18:00:00', 'N', 'N', 1, NULL),
(695, '2023-11-23 08:25:34', '2023-11-23 18:00:00', 'N', 'N', 1, NULL),
(696, '2023-11-24 08:32:56', '2023-11-24 18:00:00', 'N', 'N', 1, NULL),
(697, '2023-11-27 08:17:23', '2023-11-27 18:00:00', 'N', 'N', 1, NULL),
(698, '2023-11-28 08:42:45', '2023-11-28 18:00:00', 'N', 'N', 1, NULL),
(699, '2023-11-29 08:28:12', '2023-11-29 18:00:00', 'N', 'N', 1, NULL),
(700, '2023-11-30 08:35:34', '2023-11-30 18:00:00', 'N', 'N', 1, NULL),

-- 2023년 12월 (12/25 성탄절 제외)
(701, '2023-12-01 08:22:56', '2023-12-01 18:00:00', 'N', 'N', 1, NULL),
(702, '2023-12-04 08:45:23', '2023-12-04 18:00:00', 'N', 'N', 1, NULL),
(703, '2023-12-05 08:32:45', '2023-12-05 18:00:00', 'N', 'N', 1, NULL),
(704, '2023-12-06 08:18:12', '2023-12-06 18:00:00', 'N', 'N', 1, NULL),
(705, '2023-12-07 08:27:34', '2023-12-07 18:00:00', 'N', 'N', 1, NULL),
(706, '2023-12-08 08:42:56', '2023-12-08 18:00:00', 'N', 'N', 1, NULL),
(707, '2023-12-11 08:15:23', '2023-12-11 18:00:00', 'N', 'N', 1, NULL),
(708, '2023-12-12 08:38:45', '2023-12-12 18:00:00', 'N', 'N', 1, NULL),
(709, '2023-12-13 08:25:12', '2023-12-13 18:00:00', 'N', 'N', 1, NULL),
(710, '2023-12-14 08:32:34', '2023-12-14 18:00:00', 'N', 'N', 1, NULL),
(711, '2023-12-15 08:17:56', '2023-12-15 18:00:00', 'N', 'N', 1, NULL),
(712, '2023-12-18 08:42:23', '2023-12-18 18:00:00', 'N', 'N', 1, NULL),
(713, '2023-12-19 08:28:45', '2023-12-19 18:00:00', 'N', 'N', 1, NULL),
(714, '2023-12-20 08:35:12', '2023-12-20 18:00:00', 'N', 'N', 1, NULL),
(715, '2023-12-21 08:22:34', '2023-12-21 18:00:00', 'N', 'N', 1, NULL),
(716, '2023-12-22 08:45:56', '2023-12-22 18:00:00', 'N', 'N', 1, NULL),
(717, '2023-12-26 08:32:23', '2023-12-26 18:00:00', 'N', 'N', 1, NULL),
(718, '2023-12-27 08:18:45', '2023-12-27 18:00:00', 'N', 'N', 1, NULL),
(719, '2023-12-28 08:27:12', '2023-12-28 18:00:00', 'N', 'N', 1, NULL),
(720, '2023-12-29 08:42:34', '2023-12-29 18:00:00', 'N', 'N', 1, NULL),

-- 2023년 1월 employee_id = 7 한상민 데이터 
(721, '2023-01-02 08:07:23', '2023-01-02 18:00:00', 'N', 'N', 7, NULL),
(722, '2023-01-03 08:12:45', '2023-01-03 18:00:00', 'N', 'N', 7, NULL),
(723, '2023-01-04 08:05:34', '2023-01-04 18:00:00', 'N', 'N', 7, NULL),
(724, '2023-01-05 08:15:56', '2023-01-05 18:00:00', 'N', 'N', 7, NULL),
(725, '2023-01-06 08:22:12', '2023-01-06 18:00:00', 'N', 'N', 7, NULL),
(726, '2023-01-09 08:08:45', '2023-01-09 18:00:00', 'N', 'N', 7, NULL),
(727, '2023-01-10 08:17:23', '2023-01-10 18:00:00', 'N', 'N', 7, NULL),
(728, '2023-01-11 08:25:34', '2023-01-11 18:00:00', 'N', 'N', 7, NULL),
(729, '2023-01-12 08:14:56', '2023-01-12 18:00:00', 'N', 'N', 7, NULL),
(730, '2023-01-13 08:09:23', '2023-01-13 18:00:00', 'N', 'N', 7, NULL),
(731, '2023-01-16 08:18:45', '2023-01-16 18:00:00', 'N', 'N', 7, NULL),
(732, '2023-01-17 08:23:12', '2023-01-17 18:00:00', 'N', 'N', 7, NULL),
(733, '2023-01-18 08:11:34', '2023-01-18 18:00:00', 'N', 'N', 7, NULL),
(734, '2023-01-19 08:16:56', '2023-01-19 18:00:00', 'N', 'N', 7, NULL),
(735, '2023-01-20 08:21:23', '2023-01-20 18:00:00', 'N', 'N', 7, NULL),
(736, '2023-01-25 08:13:45', '2023-01-25 18:00:00', 'N', 'N', 7, NULL),
(737, '2023-01-26 08:19:12', '2023-01-26 18:00:00', 'N', 'N', 7, NULL),
(738, '2023-01-27 08:24:34', '2023-01-27 18:00:00', 'N', 'N', 7, NULL),
(739, '2023-01-30 08:10:56', '2023-01-30 18:00:00', 'N', 'N', 7, NULL),
(740, '2023-01-31 08:15:23', '2023-01-31 18:00:00', 'N', 'N', 7, NULL),

(741, '2023-02-01 08:20:45', '2023-02-01 18:00:00', 'N', 'N', 7, NULL),
(742, '2023-02-02 08:12:12', '2023-02-02 18:00:00', 'N', 'N', 7, NULL),
(743, '2023-02-03 08:17:34', '2023-02-03 18:00:00', 'N', 'N', 7, NULL),
(744, '2023-02-06 08:22:56', '2023-02-06 18:00:00', 'N', 'N', 7, NULL),
(745, '2023-02-07 08:08:23', '2023-02-07 18:00:00', 'N', 'N', 7, NULL),
(746, '2023-02-08 08:14:45', '2023-02-08 18:00:00', 'N', 'N', 7, NULL),
(747, '2023-02-09 08:19:12', '2023-02-09 18:00:00', 'N', 'N', 7, NULL),
(748, '2023-02-10 08:25:34', '2023-02-10 18:00:00', 'N', 'N', 7, NULL),
(749, '2023-02-13 08:11:56', '2023-02-13 18:00:00', 'N', 'N', 7, NULL),
(750, '2023-02-14 08:16:23', '2023-02-14 18:00:00', 'N', 'N', 7, NULL),
(751, '2023-02-15 08:21:45', '2023-02-15 18:00:00', 'N', 'N', 7, NULL),
(752, '2023-02-16 08:13:12', '2023-02-16 18:00:00', 'N', 'N', 7, NULL),
(753, '2023-02-17 08:18:34', '2023-02-17 18:00:00', 'N', 'N', 7, NULL),
(754, '2023-02-20 08:23:56', '2023-02-20 18:00:00', 'N', 'N', 7, NULL),
(755, '2023-02-21 08:09:23', '2023-02-21 18:00:00', 'N', 'N', 7, NULL),
(756, '2023-02-22 08:15:45', '2023-02-22 18:00:00', 'N', 'N', 7, NULL),
(757, '2023-02-23 08:20:12', '2023-02-23 18:00:00', 'N', 'N', 7, NULL),
(758, '2023-02-24 08:25:34', '2023-02-24 18:00:00', 'N', 'N', 7, NULL),
(759, '2023-02-27 08:12:56', '2023-02-27 18:00:00', 'N', 'N', 7, NULL),
(760, '2023-02-28 08:17:23', '2023-02-28 18:00:00', 'N', 'N', 7, NULL),

-- 2023년 3월 (3/1 삼일절 제외)
(761, '2023-03-02 08:22:45', '2023-03-02 18:00:00', 'N', 'N', 7, NULL),
(762, '2023-03-03 08:14:12', '2023-03-03 18:00:00', 'N', 'N', 7, NULL),
(763, '2023-03-06 08:19:34', '2023-03-06 18:00:00', 'N', 'N', 7, NULL),
(764, '2023-03-07 08:24:56', '2023-03-07 18:00:00', 'N', 'N', 7, NULL),
(765, '2023-03-08 08:10:23', '2023-03-08 18:00:00', 'N', 'N', 7, NULL),
(766, '2023-03-09 08:16:45', '2023-03-09 18:00:00', 'N', 'N', 7, NULL),
(767, '2023-03-10 08:21:12', '2023-03-10 18:00:00', 'N', 'N', 7, NULL),
(768, '2023-03-13 08:13:34', '2023-03-13 18:00:00', 'N', 'N', 7, NULL),
(769, '2023-03-14 08:18:56', '2023-03-14 18:00:00', 'N', 'N', 7, NULL),
(770, '2023-03-15 08:23:23', '2023-03-15 18:00:00', 'N', 'N', 7, NULL),
(771, '2023-03-16 08:15:45', '2023-03-16 18:00:00', 'N', 'N', 7, NULL),
(772, '2023-03-17 08:20:12', '2023-03-17 18:00:00', 'N', 'N', 7, NULL),
(773, '2023-03-20 08:25:34', '2023-03-20 18:00:00', 'N', 'N', 7, NULL),
(774, '2023-03-21 08:11:56', '2023-03-21 18:00:00', 'N', 'N', 7, NULL),
(775, '2023-03-22 08:17:23', '2023-03-22 18:00:00', 'N', 'N', 7, NULL),
(776, '2023-03-23 08:22:45', '2023-03-23 18:00:00', 'N', 'N', 7, NULL),
(777, '2023-03-24 08:14:12', '2023-03-24 18:00:00', 'N', 'N', 7, NULL),
(778, '2023-03-27 08:19:34', '2023-03-27 18:00:00', 'N', 'N', 7, NULL),
(779, '2023-03-28 08:24:56', '2023-03-28 18:00:00', 'N', 'N', 7, NULL),
(780, '2023-03-29 08:10:23', '2023-03-29 18:00:00', 'N', 'N', 7, NULL),
(781, '2023-03-30 08:16:45', '2023-03-30 18:00:00', 'N', 'N', 7, NULL),
(782, '2023-03-31 08:21:12', '2023-03-31 18:00:00', 'N', 'N', 7, NULL),

(783, '2023-04-03 08:13:34', '2023-04-03 18:00:00', 'N', 'N', 7, NULL),
(784, '2023-04-04 08:18:56', '2023-04-04 18:00:00', 'N', 'N', 7, NULL),
(785, '2023-04-05 08:23:23', '2023-04-05 18:00:00', 'N', 'N', 7, NULL),
(786, '2023-04-06 08:15:45', '2023-04-06 18:00:00', 'N', 'N', 7, NULL),
(787, '2023-04-07 08:20:12', '2023-04-07 18:00:00', 'N', 'N', 7, NULL),
(788, '2023-04-10 08:25:34', '2023-04-10 18:00:00', 'N', 'N', 7, NULL),
(789, '2023-04-11 08:11:56', '2023-04-11 18:00:00', 'N', 'N', 7, NULL),
(790, '2023-04-12 08:17:23', '2023-04-12 18:00:00', 'N', 'N', 7, NULL),
(791, '2023-04-13 08:22:45', '2023-04-13 18:00:00', 'N', 'N', 7, NULL),
(792, '2023-04-14 08:14:12', '2023-04-14 18:00:00', 'N', 'N', 7, NULL),
(793, '2023-04-17 08:19:34', '2023-04-17 18:00:00', 'N', 'N', 7, NULL),
(794, '2023-04-18 08:24:56', '2023-04-18 18:00:00', 'N', 'N', 7, NULL),
(795, '2023-04-19 08:10:23', '2023-04-19 18:00:00', 'N', 'N', 7, NULL),
(796, '2023-04-20 08:16:45', '2023-04-20 18:00:00', 'N', 'N', 7, NULL),
(797, '2023-04-21 08:21:12', '2023-04-21 18:00:00', 'N', 'N', 7, NULL),
(798, '2023-04-24 08:13:34', '2023-04-24 18:00:00', 'N', 'N', 7, NULL),
(799, '2023-04-25 08:18:56', '2023-04-25 18:00:00', 'N', 'N', 7, NULL),
(800, '2023-04-26 08:23:23', '2023-04-26 18:00:00', 'N', 'N', 7, NULL),
(801, '2023-04-27 08:15:45', '2023-04-27 18:00:00', 'N', 'N', 7, NULL),
(802, '2023-04-28 08:20:12', '2023-04-28 18:00:00', 'N', 'N', 7, NULL),

-- 2023년 5월 (5/5 어린이날, 5/27 부처님오신날 제외)
(803, '2023-05-01 08:25:34', '2023-05-01 18:00:00', 'N', 'N', 7, NULL),
(804, '2023-05-02 08:11:56', '2023-05-02 18:00:00', 'N', 'N', 7, NULL),
(805, '2023-05-03 08:17:23', '2023-05-03 18:00:00', 'N', 'N', 7, NULL),
(806, '2023-05-04 08:22:45', '2023-05-04 18:00:00', 'N', 'N', 7, NULL),
(807, '2023-05-08 08:14:12', '2023-05-08 18:00:00', 'N', 'N', 7, NULL),
(808, '2023-05-09 08:19:34', '2023-05-09 18:00:00', 'N', 'N', 7, NULL),
(809, '2023-05-10 08:24:56', '2023-05-10 18:00:00', 'N', 'N', 7, NULL),
(810, '2023-05-11 08:10:23', '2023-05-11 18:00:00', 'N', 'N', 7, NULL),
(811, '2023-05-12 08:16:45', '2023-05-12 18:00:00', 'N', 'N', 7, NULL),
(812, '2023-05-15 08:21:12', '2023-05-15 18:00:00', 'N', 'N', 7, NULL),
(813, '2023-05-16 08:13:34', '2023-05-16 18:00:00', 'N', 'N', 7, NULL),
(814, '2023-05-17 08:18:56', '2023-05-17 18:00:00', 'N', 'N', 7, NULL),
(815, '2023-05-18 08:23:23', '2023-05-18 18:00:00', 'N', 'N', 7, NULL),
(816, '2023-05-19 08:15:45', '2023-05-19 18:00:00', 'N', 'N', 7, NULL),
(817, '2023-05-22 08:20:12', '2023-05-22 18:00:00', 'N', 'N', 7, NULL),
(818, '2023-05-23 08:25:34', '2023-05-23 18:00:00', 'N', 'N', 7, NULL),
(819, '2023-05-24 08:11:56', '2023-05-24 18:00:00', 'N', 'N', 7, NULL),
(820, '2023-05-25 08:17:23', '2023-05-25 18:00:00', 'N', 'N', 7, NULL),
(821, '2023-05-26 08:22:45', '2023-05-26 18:00:00', 'N', 'N', 7, NULL),
(822, '2023-05-29 08:14:12', '2023-05-29 18:00:00', 'N', 'N', 7, NULL),
(823, '2023-05-30 08:19:34', '2023-05-30 18:00:00', 'N', 'N', 7, NULL),
(824, '2023-05-31 08:24:56', '2023-05-31 18:00:00', 'N', 'N', 7, NULL),

-- 2023년 6월 (6/6 현충일 제외)
(825, '2023-06-01 08:10:23', '2023-06-01 18:00:00', 'N', 'N', 7, NULL),
(826, '2023-06-02 08:16:45', '2023-06-02 18:00:00', 'N', 'N', 7, NULL),
(827, '2023-06-05 08:21:12', '2023-06-05 18:00:00', 'N', 'N', 7, NULL),
(828, '2023-06-07 08:13:34', '2023-06-07 18:00:00', 'N', 'N', 7, NULL),
(829, '2023-06-08 08:18:56', '2023-06-08 18:00:00', 'N', 'N', 7, NULL),
(830, '2023-06-09 08:23:23', '2023-06-09 18:00:00', 'N', 'N', 7, NULL),
(831, '2023-06-12 08:15:45', '2023-06-12 18:00:00', 'N', 'N', 7, NULL),
(832, '2023-06-13 08:20:12', '2023-06-13 18:00:00', 'N', 'N', 7, NULL),
(833, '2023-06-14 08:25:34', '2023-06-14 18:00:00', 'N', 'N', 7, NULL),
(834, '2023-06-15 08:11:56', '2023-06-15 18:00:00', 'N', 'N', 7, NULL),
(835, '2023-06-16 08:17:23', '2023-06-16 18:00:00', 'N', 'N', 7, NULL),
(836, '2023-06-19 08:22:45', '2023-06-19 18:00:00', 'N', 'N', 7, NULL),
(837, '2023-06-20 08:14:12', '2023-06-20 18:00:00', 'N', 'N', 7, NULL),
(838, '2023-06-21 08:19:34', '2023-06-21 18:00:00', 'N', 'N', 7, NULL),
(839, '2023-06-22 08:24:56', '2023-06-22 18:00:00', 'N', 'N', 7, NULL),
(840, '2023-06-23 08:10:23', '2023-06-23 18:00:00', 'N', 'N', 7, NULL),
(841, '2023-06-26 08:16:45', '2023-06-26 18:00:00', 'N', 'N', 7, NULL),
(842, '2023-06-27 08:21:12', '2023-06-27 18:00:00', 'N', 'N', 7, NULL),
(843, '2023-06-28 08:13:34', '2023-06-28 18:00:00', 'N', 'N', 7, NULL),
(844, '2023-06-29 08:18:56', '2023-06-29 18:00:00', 'N', 'N', 7, NULL),
(845, '2023-06-30 08:23:23', '2023-06-30 18:00:00', 'N', 'N', 7, NULL),

(846, '2023-07-03 08:15:45', '2023-07-03 18:00:00', 'N', 'N', 7, NULL),
(847, '2023-07-04 08:20:12', '2023-07-04 18:00:00', 'N', 'N', 7, NULL),
(848, '2023-07-05 08:25:34', '2023-07-05 18:00:00', 'N', 'N', 7, NULL),
(849, '2023-07-06 08:11:56', '2023-07-06 18:00:00', 'N', 'N', 7, NULL),
(850, '2023-07-07 08:17:23', '2023-07-07 18:00:00', 'N', 'N', 7, NULL),
(851, '2023-07-10 08:22:45', '2023-07-10 18:00:00', 'N', 'N', 7, NULL),
(852, '2023-07-11 08:14:12', '2023-07-11 18:00:00', 'N', 'N', 7, NULL),
(853, '2023-07-12 08:19:34', '2023-07-12 18:00:00', 'N', 'N', 7, NULL),
(854, '2023-07-13 08:24:56', '2023-07-13 18:00:00', 'N', 'N', 7, NULL),
(855, '2023-07-14 08:10:23', '2023-07-14 18:00:00', 'N', 'N', 7, NULL),
(856, '2023-07-17 08:16:45', '2023-07-17 18:00:00', 'N', 'N', 7, NULL),
(857, '2023-07-18 08:21:12', '2023-07-18 18:00:00', 'N', 'N', 7, NULL),
(858, '2023-07-19 08:13:34', '2023-07-19 18:00:00', 'N', 'N', 7, NULL),
(859, '2023-07-20 08:18:56', '2023-07-20 18:00:00', 'N', 'N', 7, NULL),
(860, '2023-07-21 08:23:23', '2023-07-21 18:00:00', 'N', 'N', 7, NULL),
(861, '2023-07-24 08:15:45', '2023-07-24 18:00:00', 'N', 'N', 7, NULL),
(862, '2023-07-25 08:20:12', '2023-07-25 18:00:00', 'N', 'N', 7, NULL),
(863, '2023-07-26 08:25:34', '2023-07-26 18:00:00', 'N', 'N', 7, NULL),
(864, '2023-07-27 08:11:56', '2023-07-27 18:00:00', 'N', 'N', 7, NULL),
(865, '2023-07-28 08:17:23', '2023-07-28 18:00:00', 'N', 'N', 7, NULL),
(866, '2023-07-31 08:22:45', '2023-07-31 18:00:00', 'N', 'N', 7, NULL),

-- 2023년 8월 (8/15 광복절 제외)
(867, '2023-08-01 08:14:12', '2023-08-01 18:00:00', 'N', 'N', 7, NULL),
(868, '2023-08-02 08:19:34', '2023-08-02 18:00:00', 'N', 'N', 7, NULL),
(869, '2023-08-03 08:24:56', '2023-08-03 18:00:00', 'N', 'N', 7, NULL),
(870, '2023-08-04 08:10:23', '2023-08-04 18:00:00', 'N', 'N', 7, NULL),
(871, '2023-08-07 08:16:45', '2023-08-07 18:00:00', 'N', 'N', 7, NULL),
(872, '2023-08-08 08:21:12', '2023-08-08 18:00:00', 'N', 'N', 7, NULL),
(873, '2023-08-09 08:13:34', '2023-08-09 18:00:00', 'N', 'N', 7, NULL),
(874, '2023-08-10 08:18:56', '2023-08-10 18:00:00', 'N', 'N', 7, NULL),
(875, '2023-08-11 08:23:23', '2023-08-11 18:00:00', 'N', 'N', 7, NULL),
(876, '2023-08-14 08:15:45', '2023-08-14 18:00:00', 'N', 'N', 7, NULL),
(877, '2023-08-16 08:20:12', '2023-08-16 18:00:00', 'N', 'N', 7, NULL),
(878, '2023-08-17 08:25:34', '2023-08-17 18:00:00', 'N', 'N', 7, NULL),
(879, '2023-08-18 08:11:56', '2023-08-18 18:00:00', 'N', 'N', 7, NULL),
(880, '2023-08-21 08:17:23', '2023-08-21 18:00:00', 'N', 'N', 7, NULL),
(881, '2023-08-22 08:22:45', '2023-08-22 18:00:00', 'N', 'N', 7, NULL),
(882, '2023-08-23 08:14:12', '2023-08-23 18:00:00', 'N', 'N', 7, NULL),
(883, '2023-08-24 08:19:34', '2023-08-24 18:00:00', 'N', 'N', 7, NULL),
(884, '2023-08-25 08:24:56', '2023-08-25 18:00:00', 'N', 'N', 7, NULL),
(885, '2023-08-28 08:10:23', '2023-08-28 18:00:00', 'N', 'N', 7, NULL),
(886, '2023-08-29 08:16:45', '2023-08-29 18:00:00', 'N', 'N', 7, NULL),
(887, '2023-08-30 08:21:12', '2023-08-30 18:00:00', 'N', 'N', 7, NULL),
(888, '2023-08-31 08:13:34', '2023-08-31 18:00:00', 'N', 'N', 7, NULL),

-- 2023년 9월 (9/28-30 추석연휴 제외)
(889, '2023-09-01 08:18:56', '2023-09-01 18:00:00', 'N', 'N', 7, NULL),
(890, '2023-09-04 08:23:23', '2023-09-04 18:00:00', 'N', 'N', 7, NULL),
(891, '2023-09-05 08:15:45', '2023-09-05 18:00:00', 'N', 'N', 7, NULL),
(892, '2023-09-06 08:20:12', '2023-09-06 18:00:00', 'N', 'N', 7, NULL),
(893, '2023-09-07 08:25:34', '2023-09-07 18:00:00', 'N', 'N', 7, NULL),
(894, '2023-09-08 08:11:56', '2023-09-08 18:00:00', 'N', 'N', 7, NULL),
(895, '2023-09-11 08:17:23', '2023-09-11 18:00:00', 'N', 'N', 7, NULL),
(896, '2023-09-12 08:22:45', '2023-09-12 18:00:00', 'N', 'N', 7, NULL),
(897, '2023-09-13 08:14:12', '2023-09-13 18:00:00', 'N', 'N', 7, NULL),
(898, '2023-09-14 08:19:34', '2023-09-14 18:00:00', 'N', 'N', 7, NULL),
(899, '2023-09-15 08:24:56', '2023-09-15 18:00:00', 'N', 'N', 7, NULL),
(900, '2023-09-18 08:10:23', '2023-09-18 18:00:00', 'N', 'N', 7, NULL),
(901, '2023-09-19 08:16:45', '2023-09-19 18:00:00', 'N', 'N', 7, NULL),
(902, '2023-09-20 08:21:12', '2023-09-20 18:00:00', 'N', 'N', 7, NULL),
(903, '2023-09-21 08:13:34', '2023-09-21 18:00:00', 'N', 'N', 7, NULL),
(904, '2023-09-22 08:18:56', '2023-09-22 18:00:00', 'N', 'N', 7, NULL),
(905, '2023-09-25 08:23:23', '2023-09-25 18:00:00', 'N', 'N', 7, NULL),
(906, '2023-09-26 08:15:45', '2023-09-26 18:00:00', 'N', 'N', 7, NULL),
(907, '2023-09-27 08:20:12', '2023-09-27 18:00:00', 'N', 'N', 7, NULL),

-- 2023년 10월 (10/3 개천절, 10/9 한글날 제외)
(908, '2023-10-02 08:25:34', '2023-10-02 18:00:00', 'N', 'N', 7, NULL),
(909, '2023-10-04 08:11:56', '2023-10-04 18:00:00', 'N', 'N', 7, NULL),
(910, '2023-10-05 08:17:23', '2023-10-05 18:00:00', 'N', 'N', 7, NULL),
(911, '2023-10-06 08:22:45', '2023-10-06 18:00:00', 'N', 'N', 7, NULL),
(912, '2023-10-10 08:14:12', '2023-10-10 18:00:00', 'N', 'N', 7, NULL),
(913, '2023-10-11 08:19:34', '2023-10-11 18:00:00', 'N', 'N', 7, NULL),
(914, '2023-10-12 08:24:56', '2023-10-12 18:00:00', 'N', 'N', 7, NULL),
(915, '2023-10-13 08:10:23', '2023-10-13 18:00:00', 'N', 'N', 7, NULL),
(916, '2023-10-16 08:16:45', '2023-10-16 18:00:00', 'N', 'N', 7, NULL),
(917, '2023-10-17 08:21:12', '2023-10-17 18:00:00', 'N', 'N', 7, NULL),
(918, '2023-10-18 08:13:34', '2023-10-18 18:00:00', 'N', 'N', 7, NULL),
(919, '2023-10-19 08:18:56', '2023-10-19 18:00:00', 'N', 'N', 7, NULL),
(920, '2023-10-20 08:23:23', '2023-10-20 18:00:00', 'N', 'N', 7, NULL),
(921, '2023-10-23 08:15:45', '2023-10-23 18:00:00', 'N', 'N', 7, NULL),
(922, '2023-10-24 08:20:12', '2023-10-24 18:00:00', 'N', 'N', 7, NULL),
(923, '2023-10-25 08:25:34', '2023-10-25 18:00:00', 'N', 'N', 7, NULL),
(924, '2023-10-26 08:11:56', '2023-10-26 18:00:00', 'N', 'N', 7, NULL),
(925, '2023-10-27 08:17:23', '2023-10-27 18:00:00', 'N', 'N', 7, NULL),
(926, '2023-10-30 08:22:45', '2023-10-30 18:00:00', 'N', 'N', 7, NULL),
(927, '2023-10-31 08:14:12', '2023-10-31 18:00:00', 'N', 'N', 7, NULL),

-- 2023년 11월
(928, '2023-11-01 08:19:34', '2023-11-01 18:00:00', 'N', 'N', 7, NULL),
(929, '2023-11-02 08:24:56', '2023-11-02 18:00:00', 'N', 'N', 7, NULL),
(930, '2023-11-03 08:10:23', '2023-11-03 18:00:00', 'N', 'N', 7, NULL),
(931, '2023-11-06 08:16:45', '2023-11-06 18:00:00', 'N', 'N', 7, NULL),
(932, '2023-11-07 08:21:12', '2023-11-07 18:00:00', 'N', 'N', 7, NULL),
(933, '2023-11-08 08:13:34', '2023-11-08 18:00:00', 'N', 'N', 7, NULL),
(934, '2023-11-09 08:18:56', '2023-11-09 18:00:00', 'N', 'N', 7, NULL),
(935, '2023-11-10 08:23:23', '2023-11-10 18:00:00', 'N', 'N', 7, NULL),
(936, '2023-11-13 08:15:45', '2023-11-13 18:00:00', 'N', 'N', 7, NULL),
(937, '2023-11-14 08:20:12', '2023-11-14 18:00:00', 'N', 'N', 7, NULL),
(938, '2023-11-15 08:25:34', '2023-11-15 18:00:00', 'N', 'N', 7, NULL),
(939, '2023-11-16 08:11:56', '2023-11-16 18:00:00', 'N', 'N', 7, NULL),
(940, '2023-11-17 08:17:23', '2023-11-17 18:00:00', 'N', 'N', 7, NULL),
(941, '2023-11-20 08:22:45', '2023-11-20 18:00:00', 'N', 'N', 7, NULL),
(942, '2023-11-21 08:14:12', '2023-11-21 18:00:00', 'N', 'N', 7, NULL),
(943, '2023-11-22 08:19:34', '2023-11-22 18:00:00', 'N', 'N', 7, NULL),
(944, '2023-11-23 08:24:56', '2023-11-23 18:00:00', 'N', 'N', 7, NULL),
(945, '2023-11-24 08:10:23', '2023-11-24 18:00:00', 'N', 'N', 7, NULL),
(946, '2023-11-27 08:16:45', '2023-11-27 18:00:00', 'N', 'N', 7, NULL),
(947, '2023-11-28 08:21:12', '2023-11-28 18:00:00', 'N', 'N', 7, NULL),
(948, '2023-11-29 08:13:34', '2023-11-29 18:00:00', 'N', 'N', 7, NULL),
(949, '2023-11-30 08:18:56', '2023-11-30 18:00:00', 'N', 'N', 7, NULL),

-- 2023년 12월 (12/25 성탄절 제외)
(950, '2023-12-01 08:23:23', '2023-12-01 18:00:00', 'N', 'N', 7, NULL),
(951, '2023-12-04 08:15:45', '2023-12-04 18:00:00', 'N', 'N', 7, NULL),
(952, '2023-12-05 08:20:12', '2023-12-05 18:00:00', 'N', 'N', 7, NULL),
(953, '2023-12-06 08:25:34', '2023-12-06 18:00:00', 'N', 'N', 7, NULL),
(954, '2023-12-07 08:11:56', '2023-12-07 18:00:00', 'N', 'N', 7, NULL),
(955, '2023-12-08 08:17:23', '2023-12-08 18:00:00', 'N', 'N', 7, NULL),
(956, '2023-12-11 08:22:45', '2023-12-11 18:00:00', 'N', 'N', 7, NULL),
(957, '2023-12-12 08:14:12', '2023-12-12 18:00:00', 'N', 'N', 7, NULL),
(958, '2023-12-13 08:19:34', '2023-12-13 18:00:00', 'N', 'N', 7, NULL),
(959, '2023-12-14 08:24:56', '2023-12-14 18:00:00', 'N', 'N', 7, NULL),
(960, '2023-12-15 08:10:23', '2023-12-15 18:00:00', 'N', 'N', 7, NULL),
(961, '2023-12-18 08:16:45', '2023-12-18 18:00:00', 'N', 'N', 7, NULL),
(962, '2023-12-19 08:21:12', '2023-12-19 18:00:00', 'N', 'N', 7, NULL),
(963, '2023-12-20 08:13:34', '2023-12-20 18:00:00', 'N', 'N', 7, NULL),
(964, '2023-12-21 08:18:56', '2023-12-21 18:00:00', 'N', 'N', 7, NULL),
(965, '2023-12-22 08:23:23', '2023-12-22 18:00:00', 'N', 'N', 7, NULL),
(966, '2023-12-26 08:15:45', '2023-12-26 18:00:00', 'N', 'N', 7, NULL),
(967, '2023-12-27 08:20:12', '2023-12-27 18:00:00', 'N', 'N', 7, NULL),
(968, '2023-12-28 08:25:34', '2023-12-28 18:00:00', 'N', 'N', 7, NULL),
(969, '2023-12-29 08:11:56', '2023-12-29 18:00:00', 'N', 'N', 7, NULL);

    
-- 휴복직 테이블
INSERT INTO leave_return (
    leave_return_id, start_date, end_date, employee_id, attendance_request_id
)
VALUES
    (1, '2023-11-02 00:00:00', '2024-11-02 00:00:00', 1, 5);

-- 출장파견 테이블
INSERT INTO business_trip (
    business_trip_id, start_date, end_date, trip_type, destination, employee_id, attendance_request_id
)
VALUES
    (1, '2024-11-12 09:00:00', '2024-12-12 18:00:00', 'DISPATCH', '부산 사무소', 4, 4);


-- 과제유형 테이블

INSERT INTO task_type (task_type_id, task_type_name)
VALUES
    (1, '부서과제'),
    (2, '개인과제'),
    (3, '공통과제');

INSERT INTO evaluation_policy (
    evaluation_policy_id, start_date, end_date, year, half, task_ratio,
    min_rel_eval_count, created_at, modifiable_date, policy_description,
    policy_register_id, task_type_id
) VALUES
-- 2023년 상반기 부서별 과제 평가 정책
(1, '2023-06-01', '2023-07-30', 2023, '1st', 0.4,
 4, '2023-05-01', '2023-05-31',
 '부서별 평가 최종 환산 점수: 2023년 상반기 부서별 평가는 사원의 최종 평가 점수에 40%의 비율로 반영됩니다. 과제 반영 비율 제한: 부서별 평가의 총 비율은 40%로 설정되어 있으며, 각 과제별로 10% 단위로 비율이 부여될 수 있습니다. 즉, 각 과제는 4%, 8%, 12%, ... 40% 범위 내에서 비율이 설정되며, 총 비율인 40%를 초과할 수 없습니다. 과제별 최소 점수: 부서별 과제의 최소 점수는 할당된 반영 비율의 10%로 설정됩니다. 예를 들어, 특정 과제가 8%의 비율로 설정된 경우 최소 점수는 0.8%입니다.',
 6, 1),

-- 2023년 상반기 개인 과제 평가 정책
(2, '2023-06-01', '2023-07-30', 2023, '1st', 0.3,
 4, '2023-05-01', '2023-05-31',
 '개인평가 최종 환산 점수: 2023년 상반기 개인평가는 사원의 최종 평가 점수에 30% 비율로 반영됩니다. 과제 반영 비율 제한: 개인평가의 총 비율은 30%로 설정되어 있으며, 각 과제별로 10% 단위로 비율이 부여될 수 있습니다. 즉, 각 과제는 3%, 6%, 9%, ... 30% 범위 내에서 비율이 설정되며, 총 비율인 30%를 초과할 수 없습니다. 과제별 최소 점수: 모든 과제의 최소 점수는 할당된 반영 비율의 10%로 설정됩니다. 예를 들어, 특정 과제가 6%의 비율로 설정된 경우 최소 점수는 0.6%입니다.',
 6, 2),

-- 2023년 상반기 공통 과제 평가 정책
(3, '2023-06-01', '2023-07-30', 2023, '1st', 0.3,
 4, '2023-05-01', '2023-09-01',
 '공통평가 최종 환산 점수: 2023년 상반기 공통평가는 사원의 최종 평가 점수에 30%의 비율로 반영됩니다. 과제 반영 비율 제한: 공통평가의 총 비율은 30%로 설정되어 있으며, 각 과제별로 10% 단위로 비율이 부여될 수 있습니다. 즉, 각 과제는 3%, 6%, 9%, ... 30% 범위 내에서 비율이 설정되며, 총 비율인 30%를 초과할 수 없습니다. 과제별 최소 점수: 공통 과제의 최소 점수는 할당된 반영 비율의 10%로 설정됩니다. 예를 들어, 특정 과제가 9%의 비율로 설정된 경우 최소 점수는 0.9%입니다.',
 6, 3),

 -- 2024년 하반기 부서별 과제 평가 정책
(4, '2024-11-01', '2024-12-31', 2024, '2nd', 0.4,
 4, '2024-11-01', '2024-11-30',
 '부서별 평가 최종 환산 점수: 2024년 하반기 부서별 평가는 사원의 최종 평가 점수에 40%의 비율로 반영됩니다. 과제 반영 비율 제한: 부서별 평가의 총 비율은 40%로 설정되어 있으며, 각 과제별로 10% 단위로 비율이 부여될 수 있습니다. 즉, 각 과제는 4%, 8%, 12%, ... 40% 범위 내에서 비율이 설정되며, 총 비율인 40%를 초과할 수 없습니다. 과제별 최소 점수: 부서별 과제의 최소 점수는 할당된 반영 비율의 10%로 설정됩니다. 예를 들어, 특정 과제가 8%의 비율로 설정된 경우 최소 점수는 0.8%입니다.',
 6, 1),

-- 2024년 하반기 개인 과제 평가 정책
(5, '2024-11-01', '2024-12-31', 2024, '2nd', 0.3,
 4, '2024-11-01', '2024-11-30',
 '개인평가 최종 환산 점수: 2024년 하반기 개인평가는 사원의 최종 평가 점수에 30% 비율로 반영됩니다. 과제 반영 비율 제한: 개인평가의 총 비율은 30%로 설정되어 있으며, 각 과제별로 10% 단위로 비율이 부여될 수 있습니다. 즉, 각 과제는 3%, 6%, 9%, ... 30% 범위 내에서 비율이 설정되며, 총 비율인 30%를 초과할 수 없습니다. 과제별 최소 점수: 모든 과제의 최소 점수는 할당된 반영 비율의 10%로 설정됩니다. 예를 들어, 특정 과제가 6%의 비율로 설정된 경우 최소 점수는 0.6%입니다.',
 6, 2),

-- 2024년 하반기 프로젝트 과제 평가 정책
(6, '2024-11-01', '2024-12-31', 2024, '2nd', 0.3,
 4, '2024-11-01', '2024-11-30',
 '개인평가 최종 환산 점수: 2024년 하반기 개인평가는 사원의 최종 평가 점수에 30% 비율로 반영됩니다. 과제 반영 비율 제한: 개인평가의 총 비율은 30%로 설정되어 있으며, 각 과제별로 10% 단위로 비율이 부여될 수 있습니다. 즉, 각 과제는 3%, 6%, 9%, ... 30% 범위 내에서 비율이 설정되며, 총 비율인 30%를 초과할 수 없습니다. 과제별 최소 점수: 모든 과제의 최소 점수는 할당된 반영 비율의 10%로 설정됩니다. 예를 들어, 특정 과제가 6%의 비율로 설정된 경우 최소 점수는 0.6%입니다.',
 6, 3);


-- 등급

INSERT INTO grade (grade_id, grade_name, start_ratio, end_ratio, absolute_grade_ratio, evaluation_policy_id)
VALUES

-- S 등급
    (1, 'S', 0.00, 0.05, 90, 1),
    (2, 'S', 0.00, 0.05, 90, 2),
    (3, 'S', 0.00, 0.05, 90, 3),
-- A 등급
    (4, 'A', 0.05, 0.15, 80, 1),
    (5, 'A', 0.05, 0.15, 80, 2),
    (6, 'A', 0.05, 0.15, 80, 3),

-- B 등급
    (7, 'B', 0.15, 0.7, 70, 1),
    (8, 'B', 0.15, 0.7, 70, 2),
    (9, 'B', 0.15, 0.7, 70, 3),

-- C 등급
    (10, 'C', 0.7, 0.9, 60, 1),
    (11, 'C', 0.7, 0.9, 60, 2),
    (12, 'C', 0.7, 0.9, 60, 3),

-- D 등급
    (13, 'D', 0.9, 1.0, 50, 1),
    (14, 'D', 0.9, 1.0, 50, 2),
    (15, 'D', 0.9, 1.0, 50, 3),

-- 2024년 하반기 등급 데이터 

-- S 등급
    (16, 'S', 0.00, 0.05, 90., 4),
    (17, 'S', 0.00, 0.05, 90, 5),
    (18, 'S', 0.00, 0.05, 90, 6),
    
-- A 등급
    (19, 'A', 0.05, 0.15, 80, 4),
    (20, 'A', 0.05, 0.15, 80, 5),
    (21, 'A', 0.05, 0.15, 80, 6),

-- B 등급
    (22, 'B', 0.15, 0.7, 70, 4),
    (23, 'B', 0.15, 0.7, 70, 5),
    (24, 'B', 0.15, 0.7, 70, 6),

-- C 등급
    (25, 'C', 0.7, 0.9, 60, 4),
    (26, 'C', 0.7, 0.9, 60, 5),
    (27, 'C', 0.7, 0.9, 60, 6),

-- D 등급
    (28, 'D', 0.9, 1.0, 50, 4),
    (29, 'D', 0.9, 1.0, 50, 5),
    (30, 'D', 0.9, 1.0, 50, 6);

-- 평가 테이블

INSERT INTO evaluation (evaluation_id, evaluation_type, fin_score, fin_grade, year, half, created_at, employee_id, evaluator_id)
VALUES

-- 2023 상반기 한상민의 서진우 평가 데이터
    (1, '자기평가', 100, 'S', 2023, '1st', '2023-05-15', 7, 7),
    (2, '리더평가', 96.04, 'S', 2023, '1st', '2023-05-15', 7, 8),
    -- 2024 하반기 한상민의 서진우 평가 데이터
    (3, '자기평가', 0, 'N/A', 2024, '2nd', '2024-11-01', 7, 7),
    (4, '리더평가', 0, 'N/A', 2024, '2nd', '2024-11-01', 7, 8),

        -- 2024 하반기 한상민의 서진우 평가 데이터 및 서진우의 
    (5, '자기평가', 0, 'N/A', 2024, '2nd', '2024-11-01', 8, 8),
    (6, '리더평가', 0, 'N/A', 2024, '2nd', '2024-11-01', 8, 7);
    
    

--     (1, '자기평가', 100, 'S', 2023, '1st', '2023-05-15', 8, 8),
--     (2, '리더평가', 96.04, 'S', 2023, '1st', '2023-05-15', 8, 7),
--     -- 2024 하반기 한상민의 서진우 평가 데이터
--     (3, '자기평가', 0, 'N/A', 2024, '2nd', '2024-11-01', 8, 8),
--     (4, '리더평가', 0, 'N/A', 2024, '2nd', '2024-11-01', 8, 7);
    
-- 과제 항목

INSERT INTO task_item (task_item_id, task_name, task_content, assigned_employee_count, task_type_id, employee_id, department_code, evaluation_policy_id, is_manager_written)
VALUES
    (1, 'SAP ERP 정기 패치 적용', '분기별 SAP ERP 시스템 보안 패치 및 기능 업데이트 진행', 1, 1, 8, 'T006', 1, TRUE),
    (2, '랜섬웨어 대응 체계 구축', '랜섬웨어 대응 솔루션 도입 및 백업 시스템 이중화', 1, 1, 8, 'T006', 1, TRUE),
    (3, '정보보안 관리체계 인증', 'ISMS-P 인증 획득을 위한 보안 체계 점검 및 개선', 1, 1, 8, 'T006', 1, TRUE),
    (4, '정보처리기사 자격증 취득', '정보처리기사 자격증 취득을 위한 시험 준비 및 합격 달성', 1, 2, 7, 'T006', 2, FALSE),
    (5, 'SQLD 자격증 취득', '데이터베이스 기초 지식 습득 및 SQLD 자격증 시험 합격', 1, 2, 7, 'T006', 2, FALSE),
    (6, '오픽 AL 달성', 'OPIc 시험 준비 및 Advanced Low (AL) 등급 달성', 1, 2, 7, 'T006', 2, FALSE),
    (7, '사내 캡스톤 대회 수상', '사내 캡스톤 프로젝트 대회 참가 및 입상 성과 달성', 1, 2, 7, 'T006', 2, FALSE),
    (8, '데이터 분석 프로젝트 수행', '사내 데이터 분석 프로젝트 참여 및 성공적 수행', 1, 2, 7, 'T006', 2, FALSE),
    (9, '매출액 5000억원 달성', '사업부 목표 매출액 5000억원 달성', 1, 3, 6, 'DP002', 3, FALSE),
    (10, '고객 만족도 90% 이상 달성', '고객 만족도 설문조사에서 90% 이상 달성', 1, 3, 6, 'DP002', 3, FALSE),

    -- 부서 과제 (evaluation_policy_id: 4)
    (11, '클라우드 인프라 전환', '온프레미스 서버의 클라우드 마이그레이션 및 인프라 최적화', 1, 1, 8, 'T006', 4, TRUE),
    (12, '네트워크 보안 강화', '차세대 방화벽 도입 및 네트워크 세그먼트 재구성', 1, 1, 8, 'T006', 4, TRUE),
    (13, '데이터 백업 체계 개선', '실시간 데이터 백업 시스템 구축 및 재해복구 체계 확립', 1, 1, 8, 'T006', 4, TRUE),

    -- 개인 과제 (evaluation_policy_id: 5)
    (14, 'AWS 솔루션 아키텍트 자격증', 'AWS 공인 솔루션 아키텍트 Professional 자격증 취득', 1, 2, 7, 'T006', 5, FALSE),
    (15, '쿠버네티스 관리자 자격증', 'CKA(Certified Kubernetes Administrator) 자격증 취득', 1, 2, 7, 'T006', 5, FALSE),
    (16, '보안 취약점 분석 프로젝트', '시스템 보안 취약점 분석 및 개선 방안 도출', 1, 2, 7, 'T006', 5, FALSE),
    (17, '오픈소스 컨트리뷰션', '쿠버네티스 프로젝트 컨트리뷰션 및 커미터 등급 달성', 1, 2, 7, 'T006', 5, FALSE),

    -- 공통 과제 (evaluation_policy_id: 6)
    (18, '시스템 가용성 99.9% 달성', '연간 시스템 다운타임 0.1% 미만 달성', 1, 3, 6, 'DP002', 6, FALSE),
    (19, '보안 사고 제로화', '연간 보안 사고 0건 달성 및 보안 체계 고도화', 1, 3, 6, 'DP002', 6, FALSE),
    (20, 'IT비용 10% 절감', '클라우드 최적화를 통한 인프라 운영비용 절감', 1, 3, 6, 'DP002', 6, FALSE),

    -- 서진우의 과제
        -- 부서 과제 (evaluation_policy_id: 4)
    (21, '클라우드 인프라 전환', '온프레미스 서버의 클라우드 마이그레이션 및 인프라 최적화', 1, 1, 8, 'T006', 4, TRUE),
    (22, '네트워크 보안 강화', '차세대 방화벽 도입 및 네트워크 세그먼트 재구성', 1, 1, 8, 'T006', 4, TRUE),
    (23, '데이터 백업 체계 개선', '실시간 데이터 백업 시스템 구축 및 재해복구 체계 확립', 1, 1, 8, 'T006', 4, TRUE),

    -- 개인 과제 (evaluation_policy_id: 5)
    (24, 'AWS 솔루션 아키텍트 자격증', 'AWS 공인 솔루션 아키텍트 Professional 자격증 취득', 1, 2, 8, 'T006', 5, FALSE),
    (25, '쿠버네티스 관리자 자격증', 'CKA(Certified Kubernetes Administrator) 자격증 취득', 1, 2, 8, 'T006', 5, FALSE),
    (26, '보안 취약점 분석 프로젝트', '시스템 보안 취약점 분석 및 개선 방안 도출', 1, 2, 8, 'T006', 5, FALSE),
    (27, '오픈소스 컨트리뷰션', '쿠버네티스 프로젝트 컨트리뷰션 및 커미터 등급 달성', 1, 2, 8, 'T006', 5, FALSE);



-- 과제항목별평가 테이블

INSERT INTO task_eval (
    task_eval_id,
    task_eval_name,
    task_eval_content,
    score,
    set_ratio,
    task_grade,
    performance_input,
    created_at,
    rel_eval_status,
    evaluation_id,
    modifiable_date,
    task_type_id,
    task_item_id
) VALUES

(1, 'SAP ERP 패치 적용 평가 - 한상민', '전체 패치 프로세스 관리', 95.5, 0.4, 'S', 'ERP 시스템 패치 적용 완료 및 안정화 100% 달성', '2023-06-01', false, 2, '2023-09-30', 1, 1),
(2, '정보보안 관리체계 인증 평가 - 한상민', '보안 정책 수립 및 구현', 87.5, 0.3, 'A', 'ISMS-P 인증 심사 준비 완료', '2023-06-01', false, 2, '2023-09-30', 1, 3),
(3, '랜섬웨어 대응 평가 - 한상민', '대응체계 구축', 85.5, 0.3, 'B', '랜섬웨어 대응 체계 90% 구축', '2023-06-01', false, 2, '2023-09-30', 1, 2),
(4, '정보처리기사 자격증 취득 평가', '정보처리기사 자격증 취득을 위한 준비 및 합격', 95.0, 0.2, 'S', '정보처리기사 자격증 취득 성공', '2023-06-01', false, 2, '2023-09-30', 2, 4),
(5, 'SQLD 자격증 취득 평가', 'SQLD 자격증을 위한 준비 및 시험 합격', 96.0, 0.2, 'S', 'SQLD 자격증 취득 성공', '2023-06-01', false, 2, '2023-09-30', 2, 5),
(6, '오픽 AL 등급 달성 평가', 'OPIc AL 등급 달성을 위한 준비 및 성취', 97.0, 0.2, 'S', 'OPIc AL 등급 달성', '2023-06-01', false, 2, '2023-09-30', 2, 6),
(7, '사내 캡스톤 대회 수상 평가', '캡스톤 프로젝트 대회 참가 및 입상', 98.0, 0.2, 'S', '사내 캡스톤 대회에서 입상', '2023-06-01', false, 2, '2023-09-30', 2, 7),
(8, '데이터 분석 프로젝트 수행 평가', '데이터 분석 프로젝트 참여 및 성공적 수행', 99.0, 0.2, 'S', '데이터 분석 프로젝트 성공적 수행', '2023-06-01', false, 2, '2023-09-30', 2, 8),
(9, '매출액 5000억원 달성 평가 - 한상민', '사업부 목표 매출액 5000억원 달성 여부 평가', 100, 0.5, 'S', '사업부 목표 매출액 5000억원을 달성하여 기업 성과에 기여', '2023-06-01', false, 2, '2023-09-30', 3, 9),
(10, '고객 만족도 90% 이상 달성 평가 - 한상민', '고객 만족도 90% 이상 달성 여부 평가', 100, 0.5, 'S', '고객 만족도 설문조사 결과 90% 이상의 만족도를 달성하여 긍정적인 기업 이미지를 구축', '2023-06-01', false, 2, '2023-09-30', 3, 10),

-- 리더평가와 동일한 과제항목에 대한 자기평가 점수
(11, 'SAP ERP 패치 적용 평가 - 한상민 (자기평가)', '전체 패치 프로세스 관리', 100, 0.4, 'S', 'ERP 시스템 패치 적용 완료 및 안정화 100% 달성', '2023-06-01', false, 1, '2023-09-30', 1, 1),
(12, '정보보안 관리체계 인증 평가 - 한상민 (자기평가)', '보안 정책 수립 및 구현', 100, 0.3, 'S', 'ISMS-P 인증 심사 준비 완료', '2023-06-01', false, 1, '2023-09-30', 1, 10),
(13, '랜섬웨어 대응 평가 - 한상민 (자기평가)', '대응체계 구축', 100, 0.3, 'S', '랜섬웨어 대응 체계 90% 구축', '2023-06-01', false, 1, '2023-09-30', 1, 9),
(14, '정보처리기사 자격증 취득 평가 (자기평가)', '정보처리기사 자격증 취득을 위한 준비 및 합격', 100, 0.2, 'S', '정보처리기사 자격증 취득 성공', '2023-06-01', false, 1, '2023-09-30', 2, 4),
(15, 'SQLD 자격증 취득 평가 (자기평가)', 'SQLD 자격증을 위한 준비 및 시험 합격', 100, 0.2, 'S', 'SQLD 자격증 취득 성공', '2023-06-01', false, 1, '2023-09-30', 2, 5),
(16, '오픽 AL 등급 달성 평가 (자기평가)', 'OPIc AL 등급 달성을 위한 준비 및 성취', 100, 0.2, 'S', 'OPIc AL 등급 달성', '2023-06-01', false, 1, '2023-09-30', 2, 6),
(17, '사내 캡스톤 대회 수상 평가 (자기평가)', '캡스톤 프로젝트 대회 참가 및 입상', 100, 0.2, 'S', '사내 캡스톤 대회에서 입상', '2023-06-01', false, 1, '2023-09-30', 2, 7),
(18, '데이터 분석 프로젝트 수행 평가 (자기평가)', '데이터 분석 프로젝트 참여 및 성공적 수행', 100, 0.2, 'S', '데이터 분석 프로젝트 성공적 수행', '2023-06-01', false, 1, '2023-09-30', 2, 8),
(19, '매출액 5000억원 달성 평가 - 한상민 (자기평가)', '사업부 목표 매출액 5000억원 달성 여부 평가', 100, 0.5, 'S', '사업부 목표 매출액 5000억원을 달성하여 기업 성과에 기여', '2023-06-01', false, 1, '2023-09-30', 3, 9),
(20, '고객 만족도 90% 이상 달성 평가 - 한상민 (자기평가)', '고객 만족도 90% 이상 달성 여부 평가', 100, 0.5, 'S', '고객 만족도 설문조사 결과 90% 이상의 만족도를 달성하여 긍정적인 기업 이미지를 구축', '2023-06-01', false, 1, '2023-09-30', 3, 10);


-- 평가정책별평가 테이블

INSERT INTO task_type_eval (
    task_type_eval_id,
    task_type_total_score,
    created_at,
    evaluation_id,
    evaluation_policy_id
) VALUES
-- 부서별 과제 평가 총 점수
(1, 36.04, '2023-07-01', 2, 1),

-- 개인 과제 평가 총 점수
(2, 29.1, '2023-07-01', 2, 2),

-- 공통 과제 평가 총 점수
(3, 30, '2023-07-01', 2, 3),

(4, 40.0, '2023-07-01', 1, 1),

-- 개인 과제 평가 총 점수 (자기평가)
(5, 30.0, '2023-07-01', 1, 2),

-- 공통 과제 평가 총 점수 (자기평가)
(6, 30.0, '2023-07-01', 1, 3),

-- 평가정책 4번(2024년 하반기 부서별)에 대한 평가
(7, 0.0, '2024-12-31', 3, 4),  -- 자기평가
(8, 0.0, '2024-12-31', 4, 4),  -- 리더평가

-- 평가정책 5번(2024년 하반기 개인)에 대한 평가
(9, 0.0, '2024-12-31', 3, 5),  -- 자기평가
(10, 0.0, '2024-12-31', 4, 5), -- 리더평가

-- 평가정책 6번(2024년 하반기 공통)에 대한 평가
(11, 0.0, '2024-12-31', 3, 6), -- 자기평가
(12, 0.0, '2024-12-31', 4, 6), -- 리더평가

-- 서진우 2024 하반기 
(13, 0.0, '2024-12-31', 5, 4),  -- 자기평가
(14, 0.0, '2024-12-31', 6, 4),  -- 리더평가

-- 서진우 2024 하반기
(15, 0.0, '2024-12-31', 5, 5),  -- 자기평가
(16, 0.0, '2024-12-31', 6, 5), -- 리더평가

-- 서진우 2024 하반기
(17, 0.0, '2024-12-31', 5, 6), -- 자기평가
(18, 0.0, '2024-12-31', 6, 6); -- 리더평가

-- 피드백 테이블

INSERT INTO feedback (
    feedback_id,
    content,
    created_at,
    evaluation_id
) VALUES
(1, '한상민 사원님, 이번 평가에서 우수한 성적을 거두신 것을 진심으로 축하드립니다! 높은 책임감과 성실함으로 프로젝트를 성공적으로 이끌어주셔서 감사드립니다. 특히 어려운 상황에서도 포기하지 않고 끝까지 노력하는 모습이 매우 인상 깊었습니다. 앞으로도 팀의 든든한 버팀목이 되어주시리라 믿습니다. 더 큰 성과를 이뤄나가시기를 응원합니다!', '2023-07-01', 2);


-- 테이블 조회

-- 부서 및  부서 구성원 및 회사
SELECT * FROM department_member;
SELECT * FROM department;
SELECT * FROM company;

-- 사원 정보
SELECT * FROM employee;
SELECT * FROM appointment_item;
SELECT * FROM appointment;
SELECT * FROM discipline_reward;
SELECT * FROM language_test;
SELECT * FROM `language`;
SELECT * FROM qualification;
SELECT * FROM contract;
SELECT * FROM career;
SELECT * FROM education;
SELECT * FROM family_member;
SELECT * FROM family_relationship;
SELECT * FROM attendance_status_type;

-- 직급, 직위, 직무
SELECT * FROM duty;
SELECT * FROM `role`;
SELECT * FROM `position`;

-- 평가
SELECT * FROM feedback;
SELECT * FROM task_eval;
SELECT * FROM evaluation;
SELECT * FROM grade;
SELECT * FROM evaluation_policy;
SELECT * FROM task_item;
SELECT * FROM task_type;
SELECT * FROM task_type_eval;

-- 근태
SELECT * FROM business_trip;
SELECT * FROM leave_return;
SELECT * FROM commute;
SELECT * FROM attendance_request_file;
SELECT * FROM attendance_request;
SELECT * FROM attendance_request_type;

-- 급여
SELECT * FROM payment;
SELECT * FROM irregular_allowance;
SELECT * FROM public_holiday;
SELECT * FROM tax_credit;
SELECT * FROM non_taxable;
SELECT * FROM major_insurance;
SELECT * FROM earned_income_tax;

-- 휴가
SELECT * FROM annual_vacation_promotion_policy;
SELECT * FROM vacation_request_file;
SELECT * FROM vacation_request;
SELECT * FROM vacation;
SELECT * FROM vacation_policy;
SELECT * FROM vacation_type;
SELECT * FROM evaluation_policy;
