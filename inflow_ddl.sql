DROP TABLE IF EXISTS monthly_employee_num_statistics;
DROP TABLE IF EXISTS monthly_department_overtime_allowance_statistics;
DROP TABLE IF EXISTS semiannual_department_performance_ratio_statistics;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS task;
DROP TABLE IF EXISTS task_eval;
DROP TABLE IF EXISTS task_type_eval;
DROP TABLE IF EXISTS grade;
DROP TABLE IF EXISTS evaluation;
DROP TABLE IF EXISTS task_item;
DROP TABLE IF EXISTS evaluation_policy;
DROP TABLE IF EXISTS task_type;
DROP TABLE IF EXISTS business_trip;
DROP TABLE IF EXISTS leave_return;
DROP TABLE IF EXISTS commute;
DROP TABLE IF EXISTS attendance_request_file;
DROP TABLE IF EXISTS attendance_request;
DROP TABLE IF EXISTS attendance_request_type;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS irregular_allowance;
DROP TABLE IF EXISTS public_holiday;
DROP TABLE IF EXISTS tax_credit;
DROP TABLE IF EXISTS non_taxable;
DROP TABLE IF EXISTS major_insurance;
DROP TABLE IF EXISTS earned_income_tax;
DROP TABLE IF EXISTS annual_vacation_promotion_policy;
DROP TABLE IF EXISTS vacation_request_file;
DROP TABLE IF EXISTS vacation_request;
DROP TABLE IF EXISTS vacation;
DROP TABLE IF EXISTS vacation_policy;
DROP TABLE IF EXISTS vacation_type;
DROP TABLE IF EXISTS department_member;
DROP TABLE IF EXISTS appointment;
DROP TABLE IF EXISTS appointment_item;
DROP TABLE IF EXISTS discipline_reward;
DROP TABLE IF EXISTS language_test;
DROP TABLE IF EXISTS `language`;
DROP TABLE IF EXISTS qualification;
DROP TABLE IF EXISTS contract;
DROP TABLE IF EXISTS career;
DROP TABLE IF EXISTS education;
DROP TABLE IF EXISTS family_member;
DROP TABLE IF EXISTS family_relationship;
DROP TABLE IF EXISTS session_history;
DROP TABLE IF EXISTS chatbot_session;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS duty;
DROP TABLE IF EXISTS `role`;
DROP TABLE IF EXISTS `position`;
DROP TABLE IF EXISTS attendance_status_type;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS company;
DROP TABLE IF EXISTS BATCH_STEP_EXECUTION_CONTEXT;
DROP TABLE IF EXISTS batch_job_execution_context;
DROP TABLE IF EXISTS BATCH_STEP_EXECUTION;
DROP TABLE IF EXISTS BATCH_JOB_EXECUTION_PARAMS;
DROP TABLE IF EXISTS BATCH_JOB_EXECUTION;
DROP TABLE IF EXISTS BATCH_JOB_INSTANCE;
DROP SEQUENCE IF EXISTS BATCH_JOB_SEQ;
DROP SEQUENCE IF EXISTS BATCH_STEP_SEQ;
DROP SEQUENCE IF EXISTS BATCH_JOB_EXECUTION_SEQ;
DROP SEQUENCE IF EXISTS BATCH_STEP_EXECUTION_SEQ;
DROP SEQUENCE IF EXISTS BATCH_JOB_EXECUTION_CONTEXT_SEQ;
DROP SEQUENCE IF EXISTS BATCH_STEP_EXECUTION_CONTEXT_SEQ;

-- 회사 테이블
CREATE TABLE company (
                         company_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                         company_name VARCHAR(255) NOT NULL,
                         ceo VARCHAR(255) NOT NULL,
                         ceo_signature VARCHAR(255) NOT NULL,
                         business_registration_number VARCHAR(255) NOT NULL,
                         company_address VARCHAR(255) NOT NULL,
                         company_phone_number VARCHAR(255) NOT NULL,
                         company_stamp_url TEXT NOT NULL,
                         company_logo_url TEXT NOT NULL
) ENGINE=INNODB COMMENT '회사' CHARACTER SET utf8mb4;

-- 부서 테이블
CREATE TABLE department (
                            department_code VARCHAR(255) PRIMARY KEY,
                            department_name VARCHAR(255) NOT NULL,
                            created_at TIMESTAMP NOT NULL,
                            disbanded_at TIMESTAMP NULL,
                            min_employee_num INT NOT NULL DEFAULT 0,
                            upper_department_code VARCHAR(255) NULL,
                            FOREIGN KEY (upper_department_code) REFERENCES department(department_code)
) ENGINE=INNODB COMMENT '부서' CHARACTER SET utf8mb4;

-- 출퇴근 상태 유형 테이블
CREATE TABLE attendance_status_type (
                                        attendance_status_type_code VARCHAR(255) PRIMARY KEY,
                                        attendance_status_type_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=INNODB COMMENT '출퇴근 상태' CHARACTER SET utf8mb4;

-- 직위 테이블
CREATE TABLE `position` (
                            position_code VARCHAR(255) PRIMARY KEY,
                            position_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=INNODB COMMENT '직위' CHARACTER SET utf8mb4;

-- 직책 테이블
CREATE TABLE `role` (
                        role_code VARCHAR(255) PRIMARY KEY,
                        role_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=INNODB COMMENT '직책' CHARACTER SET utf8mb4;

-- 직무 테이블
CREATE TABLE duty (
                      duty_code VARCHAR(255) PRIMARY KEY,
                      duty_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=INNODB COMMENT '직책' CHARACTER SET utf8mb4;

-- 사원 테이블
CREATE TABLE employee (
                          employee_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                          employee_number VARCHAR(255) NOT NULL UNIQUE,
                          employee_role VARCHAR(255) NOT NULL CHECK(employee_role IN ('EMPLOYEE','HR','MANAGER','ADMIN')),
                          password VARCHAR(255) NOT NULL,
                          gender VARCHAR(255) NOT NULL CHECK(gender IN ('MALE', 'FEMALE')),
                          name VARCHAR(255) NOT NULL,
                          birth_date DATE NOT NULL,
                          email VARCHAR(255) NOT NULL,
                          phone_number VARCHAR(255) NOT NULL,
                          profile_img_url TEXT NOT NULL,
                          join_date DATE NOT NULL,
                          join_type VARCHAR(255) NOT NULL CHECK(join_type IN ('ROOKIE','VETERAN')), -- 신입사원 또는 경력직
                          resignation_date DATE NULL,
                          resignation_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(resignation_status IN ('Y','N')),
                          salary BIGINT NOT NULL,
                          monthly_salary BIGINT NOT NULL,
                          street_address VARCHAR(255) NOT NULL,
                          detailed_address VARCHAR(255) NOT NULL,
                          postcode VARCHAR(255) NOT NULL,
                          department_code VARCHAR(255) NOT NULL,
                          attendance_status_type_code VARCHAR(255) NOT NULL,
                          position_code VARCHAR(255) NOT NULL,
                          role_code VARCHAR(255) NOT NULL,
                          duty_code VARCHAR(255) NOT NULL,
                          FOREIGN KEY (department_code) REFERENCES department(department_code),
                          FOREIGN KEY (attendance_status_type_code) REFERENCES attendance_status_type(attendance_status_type_code),
                          FOREIGN KEY (position_code) REFERENCES `position`(position_code),
                          FOREIGN KEY (role_code) REFERENCES `role`(role_code),
                          FOREIGN KEY (duty_code) REFERENCES duty(duty_code)
) ENGINE=INNODB COMMENT '사원' CHARACTER SET utf8mb4;

-- 사원별 챗봇 세션 테이블
CREATE TABLE chatbot_session (
                                 session_id VARCHAR(255) NOT NULL PRIMARY KEY,
                                 employee_id BIGINT NOT NULL,
                                 created_at TIMESTAMP NOT NULL,
                                 first_question VARCHAR(255) NOT NULL
) ENGINE=INNODB COMMENT '사원별챗봇세션' CHARACTER SET utf8mb4;


-- 세션별 대화 이력 테이블
CREATE TABLE session_history (
    session_history_id VARCHAR(255) NOT NULL PRIMARY KEY,
    chatbot_type VARCHAR(255) NOT NULL CHECK(chatbot_type IN ('CHATBOT','HUMAN')), -- 챗봇 또는 사람
    chatbot_content TEXT,
    session_id VARCHAR(255) NOT NULL,
    selected_keyword VARCHAR(255) NULL,
    FOREIGN KEY (session_id) REFERENCES chatbot_session(session_id)
) ENGINE=INNODB COMMENT '세션별대화이력' CHARACTER SET utf8mb4;



-- 가구원 관계 테이블
CREATE TABLE family_relationship (
                                     family_relationship_code VARCHAR(255) PRIMARY KEY ,
                                     family_relationship_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=INNODB COMMENT '가구원 관계' CHARACTER SET utf8mb4;

-- 가족 구성원 테이블
CREATE TABLE family_member (
                               family_member_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                               name VARCHAR(255) NOT NULL,
                               birth_date DATETIME NOT NULL,
                               employee_id BIGINT NOT NULL,
                               family_relationship_code VARCHAR(255) NOT NULL,
                               FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                               FOREIGN KEY (family_relationship_code) REFERENCES family_relationship(family_relationship_code)
) ENGINE=INNODB COMMENT '가족 구성원' CHARACTER SET utf8mb4;

-- 학력 테이블
CREATE TABLE education (
                           education_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                           school_name VARCHAR(255) NOT NULL,
                           admission_date TIMESTAMP NOT NULL,
                           graduation_date TIMESTAMP NOT NULL,
                           degree VARCHAR(255) NOT NULL,
                           major VARCHAR(255) NULL,
                           employee_id BIGINT NOT NULL,
                           FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=INNODB COMMENT '학력' CHARACTER SET utf8mb4;

-- 경력 테이블
CREATE TABLE career (
                        career_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                        company_name VARCHAR(255) NOT NULL,
                        role_name VARCHAR(255) NOT NULL,
                        join_date TIMESTAMP NOT NULL,
                        resignation_date TIMESTAMP NOT NULL,
                        employee_id BIGINT NOT NULL,
                        FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=INNODB COMMENT '경력' CHARACTER SET utf8mb4;

-- 계약서 테이블
CREATE TABLE contract (
                          contract_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                          contract_type VARCHAR(255) NOT NULL CHECK(contract_type IN ('EMPLOYMENT', 'SECURITY')), -- 근로 계약서, 비밀 유지서약서 등 자유롭게 기입
                          created_at TIMESTAMP NULL,
                          file_name VARCHAR(255) NULL,
                          file_url TEXT NULL UNIQUE,
                          contract_status VARCHAR(255) NOT NULL DEFAULT 'SIGNING'
                              CHECK(contract_status IN ('SIGNING', 'REGISTERED')), -- 계약서 상태
                          consent_status VARCHAR(255) NOT NULL DEFAULT 'N'
                              CHECK(consent_status IN ('Y', 'N')), -- 동의 여부

                          employee_id BIGINT NOT NULL,
                          FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=INNODB COMMENT '계약서' CHARACTER SET utf8mb4;

-- 자격증 테이블
CREATE TABLE qualification (
                               qualification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                               qualification_name VARCHAR(255) NOT NULL,
                               qualification_number VARCHAR(255) NOT NULL UNIQUE,
                               qualified_at TIMESTAMP NOT NULL,
                               issuer VARCHAR(255) NOT NULL,
                               grade_score VARCHAR(255) NOT NULL,
                               employee_id BIGINT NOT NULL,
                               FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=INNODB COMMENT '자격증' CHARACTER SET utf8mb4;

-- 어학 테이블
CREATE TABLE `language` (
                            language_code VARCHAR(255) PRIMARY KEY,
                            language_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=INNODB COMMENT '어학' CHARACTER SET utf8mb4;

-- 어학시험  테이블
CREATE TABLE language_test (
                               language_test_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                               language_test_name VARCHAR(255) NOT NULL,
                               qualification_number VARCHAR(255) NOT NULL UNIQUE,
                               issuer VARCHAR(255) NOT NULL,
                               qualified_at TIMESTAMP NOT NULL,
                               grade_score VARCHAR(255) NOT NULL,
                               employee_id BIGINT NOT NULL,
                               language_code VARCHAR(255) NOT NULL,
                               FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                               FOREIGN KEY (language_code) REFERENCES `language`(language_code)
) ENGINE=INNODB COMMENT '어학시험' CHARACTER SET utf8mb4;

-- 징계/포상 테이블
CREATE TABLE discipline_reward (
                                   discipline_reward_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                   discipline_reward_name VARCHAR(255) NOT NULL,
                                   content VARCHAR(255) NOT NULL,
                                   created_at TIMESTAMP NOT NULL,
                                   employee_id BIGINT NOT NULL,
                                   FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=INNODB COMMENT '징계/포상' CHARACTER SET utf8mb4;

-- 인사발령 항목 테이블
CREATE TABLE appointment_item (
                                  appointment_item_code VARCHAR(255) PRIMARY KEY,
                                  appointment_item_name VARCHAR(255) NOT NULL
) ENGINE=INNODB COMMENT '인사발령 항목' CHARACTER SET utf8mb4;

-- 인사발령 테이블
CREATE TABLE appointment (
                             appointment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                             appointed_at TIMESTAMP NOT NULL,
                             employee_id BIGINT NOT NULL,
                             authorizer_id BIGINT NOT NULL, -- 발령권자
                             department_code VARCHAR(255) NOT NULL,
                             duty_code VARCHAR(255) NOT NULL,
                             role_code VARCHAR(255) NOT NULL,
                             position_code VARCHAR(255) NOT NULL,
                             appointment_item_code VARCHAR(255) NOT NULL,
                             FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                             FOREIGN KEY (authorizer_id) REFERENCES employee(employee_id),
                             FOREIGN KEY (department_code) REFERENCES department(department_code),
                             FOREIGN KEY (duty_code) REFERENCES duty(duty_code),
                             FOREIGN KEY (role_code) REFERENCES `role`(role_code),
                             FOREIGN KEY (position_code) REFERENCES `position`(position_code),
                             FOREIGN KEY (appointment_item_code) REFERENCES appointment_item(appointment_item_code)
) ENGINE=INNODB COMMENT '인사발령' CHARACTER SET utf8mb4;

-- 부서 구성원 테이블
CREATE TABLE department_member (
                                   department_member_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                   employee_number VARCHAR(255) NOT NULL UNIQUE,
                                   name VARCHAR(255) NOT NULL,
                                   role_name VARCHAR(255) NOT NULL,
                                   email VARCHAR(255) NOT NULL,
                                   profile_img_url TEXT NOT NULL,
                                   phone_number VARCHAR(255) NOT NULL,
                                   attendance_status_type_name VARCHAR(255) NOT NULL,
                                   manager_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(manager_status IN ('Y', 'N')),
                                   department_code VARCHAR(255) NOT NULL,
                                   employee_id BIGINT NOT NULL,
                                   FOREIGN KEY (department_code) REFERENCES department(department_code),
                                   FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=INNODB COMMENT '부서 구성원' CHARACTER SET utf8mb4;

-- 휴가 유형 테이블
CREATE TABLE vacation_type (
                               vacation_type_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                               vacation_type_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=INNODB COMMENT '휴가 유형' CHARACTER SET utf8;

-- 휴가 정책 테이블
CREATE TABLE vacation_policy (
                                 vacation_policy_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                 vacation_policy_name VARCHAR(255) NOT NULL,
                                 vacation_policy_description TEXT NOT NULL,
                                 vacation_policy_status VARCHAR(255) NOT NULL DEFAULT 'NORMAL',
                                 allocation_days BIGINT NOT NULL,
                                 paid_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(paid_status IN ('Y', 'N')),
                                 year INT NOT NULL,
                                 created_at TIMESTAMP NOT NULL,
                                 auto_allocation_cycle VARCHAR(255) NULL,
                                 vacation_type_id BIGINT NOT NULL,
                                 policy_register_id BIGINT NOT NULL,
                                 FOREIGN KEY (vacation_type_id) REFERENCES vacation_type(vacation_type_id),
                                 FOREIGN KEY (policy_register_id) REFERENCES employee(employee_id)
) ENGINE=INNODB COMMENT '휴가 정책' CHARACTER SET utf8mb4;

-- 휴가 테이블
CREATE TABLE vacation (
                          vacation_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                          vacation_name VARCHAR(255) NOT NULL,
                          vacation_left BIGINT NOT NULL,
                          vacation_used BIGINT NOT NULL DEFAULT 0,
                          created_at TIMESTAMP NOT NULL,
                          expired_at TIMESTAMP NOT NULL,
                          expiration_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(expiration_status IN ('Y', 'N')),
                          employee_id BIGINT NOT NULL,
                          vacation_policy_id BIGINT NOT NULL,
                          vacation_type_id BIGINT NOT NULL,
                          FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                          FOREIGN KEY (vacation_policy_id) REFERENCES vacation_policy(vacation_policy_id),
                          FOREIGN KEY (vacation_type_id) REFERENCES vacation_type(vacation_type_id)
) ENGINE=INNODB COMMENT '휴가' CHARACTER SET utf8mb4;

-- 휴가 신청 테이블
CREATE TABLE vacation_request (
                                  vacation_request_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                  start_date TIMESTAMP NOT NULL,
                                  end_date TIMESTAMP NOT NULL,
                                  created_at TIMESTAMP NOT NULL,
                                  request_reason VARCHAR(255) NOT NULL,
                                  request_status VARCHAR(255) NOT NULL DEFAULT 'WAIT' CHECK(request_status IN ('WAIT','ACCEPT','REJECT')),
                                  rejection_reason VARCHAR(255) NULL,
                                  canceled_at TIMESTAMP NULL,
                                  cancel_reason VARCHAR(255) NULL,
                                  cancel_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(cancel_status IN ('Y', 'N')),
                                  employee_id BIGINT NOT NULL,
                                  vacation_id BIGINT NOT NULL,
                                  FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                                  FOREIGN KEY (vacation_id) REFERENCES vacation(vacation_id)
) ENGINE=INNODB COMMENT '휴가 신청' CHARACTER SET utf8mb4;

-- 휴가 신청 파일 테이블
CREATE TABLE vacation_request_file (
                                       vacation_request_file_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                       file_name VARCHAR(255) NOT NULL,
                                       file_url TEXT NOT NULL UNIQUE,
                                       vacation_request_id BIGINT NOT NULL,
                                       FOREIGN KEY (vacation_request_id) REFERENCES vacation_request(vacation_request_id)
) ENGINE=INNODB COMMENT '휴가 신청 파일' CHARACTER SET utf8mb4;

-- 연차 촉진 제도 테이블
CREATE TABLE annual_vacation_promotion_policy (
                                                  annual_vacation_promotion_policy_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  month INT NOT NULL,
                                                  day INT NOT NULL,
                                                  standard INT NOT NULL
) ENGINE=INNODB COMMENT '연차 촉진 제도' CHARACTER SET utf8mb4;

-- 근로 소득세 테이블
CREATE TABLE earned_income_tax (
                                   earned_income_tax_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                   monthly_salary_more BIGINT NOT NULL,
                                   monthly_salary_under BIGINT NOT NULL,
                                   child_num INT NOT NULL,
                                   amount BIGINT NOT NULL
) ENGINE=INNODB COMMENT '근로 소득세' CHARACTER SET utf8mb4;

-- 4대 보험 테이블
CREATE TABLE major_insurance (
                                 major_insurance_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                 insurance_name VARCHAR(255) NOT NULL,
                                 tax_rates DOUBLE NOT NULL
) ENGINE=INNODB COMMENT '4대 보험' CHARACTER SET utf8mb4;

-- 비과세 항목 테이블
CREATE TABLE non_taxable (
                             non_taxable_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                             non_taxable_name VARCHAR(255) NOT NULL,
                             amount BIGINT NOT NULL
) ENGINE=INNODB COMMENT '비과세 항목' CHARACTER SET utf8mb4;

-- 세액 공제 테이블
CREATE TABLE tax_credit (
                            tax_credit_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                            valid_child_num INT NOT NULL,
                            base_deductible BIGINT NOT NULL,
                            additional_deductible_per_child BIGINT NOT NULL
) ENGINE=INNODB COMMENT '세액 공제' CHARACTER SET utf8mb4;

-- 공휴일 테이블
CREATE TABLE public_holiday (
                                public_holiday_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                year INT NOT NULL,
                                month INT NOT NULL,
                                day_num INT NOT NULL
) ENGINE=INNODB COMMENT '공휴일' CHARACTER SET utf8mb4;

-- 비정기 수당 테이블
CREATE TABLE irregular_allowance (
                                     irregular_allowance_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                     irregular_allowance_name VARCHAR(255) NOT NULL,
                                     amount BIGINT NOT NULL
) ENGINE=INNODB COMMENT '비정기 수당' CHARACTER SET utf8mb4;

-- 급여 테이블
CREATE TABLE payment (
                         payment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                         paid_at TIMESTAMP NOT NULL,
                         monthly_salary BIGINT NOT NULL,
                         actual_salary BIGINT NOT NULL,
                         non_taxable_amount BIGINT NOT NULL,
                         family_member_num INT NOT NULL,
                         valid_child_num INT NOT NULL,
                         total_working_day_num INT NOT NULL,
                         actual_working_day_num INT NOT NULL,
                         paid_vacation_num INT NOT NULL,
                         unpaid_vacation_num INT NOT NULL,
                         public_holiday_num INT NOT NULL,
                         bonus BIGINT NOT NULL,
                         annual_vacation_allowance BIGINT NOT NULL,
                         overtime_allowance BIGINT NOT NULL,
                         national_pension_deductible BIGINT NOT NULL,
                         health_insurance_deductible BIGINT NOT NULL,
                         long_term_care_insurance_deductible BIGINT NOT NULL,
                         employment_insurance_deductible BIGINT NOT NULL,
                         income_tax_deductible BIGINT NOT NULL,
                         local_income_tax_deductible BIGINT NOT NULL,
                         child_deductible BIGINT NOT NULL,
                         total_deductible BIGINT NOT NULL,
                         employee_id BIGINT NOT NULL,
                         public_holiday_id BIGINT NOT NULL,
                         earned_income_tax_id BIGINT NOT NULL,
                         FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                         FOREIGN KEY (public_holiday_id) REFERENCES public_holiday(public_holiday_id),
                         FOREIGN KEY (earned_income_tax_id) REFERENCES earned_income_tax(earned_income_tax_id)
) ENGINE=INNODB COMMENT '급여' CHARACTER SET utf8mb4;

-- 근태 신청 유형 테이블
CREATE TABLE attendance_request_type (
                                         attendance_request_type_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                         attendance_request_type_name VARCHAR(255) NOT NULL UNIQUE,
                                         attendance_request_type_description TEXT NOT NULL
) ENGINE=INNODB COMMENT '근태 신청 유형' CHARACTER SET utf8mb4;

-- 근태 신청 테이블
CREATE TABLE attendance_request (
                                    attendance_request_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                    request_reason VARCHAR(255) NOT NULL,
                                    start_date TIMESTAMP NOT NULL,
                                    end_date TIMESTAMP NOT NULL,
                                    created_at TIMESTAMP NOT NULL,
                                    rejection_reason VARCHAR(255) NULL,
                                    request_status VARCHAR(255) NOT NULL DEFAULT 'WAIT' CHECK(request_status IN ('WAIT','ACCEPT','REJECT')),
                                    canceled_at TIMESTAMP NULL,
                                    cancel_reason VARCHAR(255) NULL,
                                    cancel_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(cancel_status IN ('Y', 'N')),
                                    destination VARCHAR(255) NULL,
                                    employee_id BIGINT NOT NULL,
                                    attendance_request_type_id BIGINT NOT NULL,
                                    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                                    FOREIGN KEY (attendance_request_type_id) REFERENCES attendance_request_type(attendance_request_type_id)
) ENGINE=INNODB COMMENT '근태 신청' CHARACTER SET utf8mb4;

-- 근태 신청 파일 테이블
CREATE TABLE attendance_request_file (
                                         attendance_request_file_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                         file_name VARCHAR(255) NOT NULL,
                                         file_url TEXT NOT NULL UNIQUE,
                                         attendance_request_id BIGINT NOT NULL,
                                         FOREIGN KEY (attendance_request_id) REFERENCES attendance_request(attendance_request_id)
) ENGINE=INNODB COMMENT '근태 신청 파일' CHARACTER SET utf8mb4;

-- 출퇴근 테이블
CREATE TABLE commute (
                         commute_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                         start_time TIMESTAMP NULL,
                         end_time TIMESTAMP NULL,
                         remote_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(remote_status IN ('Y', 'N')),
                         overtime_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(overtime_status IN ('Y', 'N')),
                         employee_id BIGINT NOT NULL,
                         attendance_request_id BIGINT NULL,
                         FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                         FOREIGN KEY (attendance_request_id) REFERENCES attendance_request(attendance_request_id)
) ENGINE=INNODB COMMENT '출퇴근' CHARACTER SET utf8mb4;

-- 휴복직 테이블
CREATE TABLE leave_return (
                              leave_return_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                              start_date TIMESTAMP NOT NULL,
                              end_date TIMESTAMP NOT NULL,
                              employee_id BIGINT NOT NULL,
                              attendance_request_id BIGINT NOT NULL,
                              FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                              FOREIGN KEY (attendance_request_id) REFERENCES attendance_request(attendance_request_id)
) ENGINE=INNODB COMMENT '휴복직' CHARACTER SET utf8mb4;

-- 출장/파견 테이블
CREATE TABLE business_trip (
                               business_trip_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                               start_date TIMESTAMP NOT NULL,
                               end_date TIMESTAMP NOT NULL,
                               trip_type VARCHAR(255) NOT NULL CHECK(trip_type IN ('BUSINESS', 'DISPATCH')),
                               destination VARCHAR(255) NOT NULL,
                               employee_id BIGINT NOT NULL,
                               attendance_request_id BIGINT NOT NULL,
                               FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                               FOREIGN KEY (attendance_request_id) REFERENCES attendance_request(attendance_request_id)
) ENGINE=INNODB COMMENT '출장/파견' CHARACTER SET utf8mb4;

-- 과제 유형 테이블
CREATE TABLE task_type (
                           task_type_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                           task_type_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=INNODB COMMENT '과제 유형' CHARACTER SET utf8mb4;

-- 평가 정책 테이블
CREATE TABLE evaluation_policy (
                                   evaluation_policy_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                   start_date TIMESTAMP NOT NULL,
                                   end_date TIMESTAMP NOT NULL,
                                   year INT NOT NULL,
                                   half VARCHAR(255) NOT NULL,
                                   task_ratio DOUBLE NOT NULL,
                                   min_rel_eval_count BIGINT NOT NULL,
                                   created_at TIMESTAMP NOT NULL,
                                   modifiable_date TIMESTAMP NOT NULL,
                                   policy_description TEXT NOT NULL,
                                   policy_register_id BIGINT NOT NULL,
                                   task_type_id BIGINT NOT NULL,
                                   FOREIGN KEY (policy_register_id) REFERENCES employee(employee_id),
                                   FOREIGN KEY (task_type_id) REFERENCES task_type(task_type_id)
) ENGINE=INNODB COMMENT '평가 정책' CHARACTER SET utf8mb4;

-- 과제 항목 테이블
CREATE TABLE task_item (
                           task_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                           task_name VARCHAR(255) NOT NULL,
                           task_content TEXT NOT NULL,
                           assigned_employee_count BIGINT NOT NULL,
                           is_manager_written BOOLEAN DEFAULT FALSE,
                           task_type_id BIGINT NOT NULL,
                           employee_id BIGINT NOT NULL,
                           department_code VARCHAR(255) NOT NULL,
                           evaluation_policy_id BIGINT NOT NULL,
                           FOREIGN KEY (task_type_id) REFERENCES task_type(task_type_id),
                           FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
                           FOREIGN KEY (department_code) REFERENCES department(department_code),
                           FOREIGN KEY (evaluation_policy_id) REFERENCES evaluation_policy(evaluation_policy_id)
) ENGINE=INNODB COMMENT '과제 항목' CHARACTER SET utf8mb4;


-- 평가 테이블
CREATE TABLE evaluation (
                            evaluation_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                            evaluation_type VARCHAR(255) NOT NULL,
                            fin_grade VARCHAR(255) NULL,
                            fin_score DOUBLE NULL,
                            year INT NOT NULL,
                            half VARCHAR(255) NOT NULL,
                            created_at TIMESTAMP NOT NULL,
                            evaluator_id BIGINT NOT NULL,
                            employee_id BIGINT NOT NULL,
                            FOREIGN KEY (evaluator_id) REFERENCES employee(employee_id),
                            FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=INNODB COMMENT '평가' CHARACTER SET utf8mb4;

-- 평가정책별평가 테이블
CREATE TABLE task_type_eval (
                                task_type_eval_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                task_type_total_score DOUBLE NOT NULL,
                                created_at TIMESTAMP NOT NULL,
                                evaluation_id BIGINT NOT NULL,
                                evaluation_policy_id BIGINT NOT NULL,
                                FOREIGN KEY (evaluation_id) REFERENCES evaluation(evaluation_id),
                                FOREIGN KEY (evaluation_policy_id) REFERENCES evaluation_policy(evaluation_policy_id)
) ENGINE=INNODB COMMENT '평가 정책별 평가' CHARACTER SET utf8mb4;

-- 등급 테이블
CREATE TABLE grade (
                       grade_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                       grade_name VARCHAR(255) NOT NULL,
                       start_ratio DOUBLE NOT NULL,
                       end_ratio DOUBLE NOT NULL,
                       absolute_grade_ratio Double NOT NULL,
                       evaluation_policy_id BIGINT NOT NULL,
                       FOREIGN KEY (evaluation_policy_id) REFERENCES evaluation_policy(evaluation_policy_id)
) ENGINE=INNODB COMMENT '등급' CHARACTER SET utf8mb4;

-- 피드백 테이블
CREATE TABLE feedback (
                          feedback_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                          content TEXT NOT NULL,
                          created_at TIMESTAMP NOT NULL,
                          evaluation_id BIGINT NOT NULL,
                          FOREIGN KEY (evaluation_id) REFERENCES evaluation(evaluation_id)
) ENGINE=INNODB COMMENT '피드백' CHARACTER SET utf8mb4;

-- 과제별 평가 테이블
CREATE TABLE task_eval (
                           task_eval_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                           task_eval_name VARCHAR(255) NOT NULL,
                           task_eval_content TEXT NOT NULL,
                           score DOUBLE NOT NULL,
                           set_ratio DOUBLE NOT NULL,
                           task_grade VARCHAR(255) NULL,
                           performance_input TEXT NOT NULL,
                           created_at TIMESTAMP NOT NULL,
                           rel_eval_status BOOLEAN NOT NULL,
                           evaluation_id BIGINT NOT NULL,
                           modifiable_date TIMESTAMP NOT NULL,
                           task_type_id BIGINT NOT NULL,
                           task_item_id BIGINT NOT NULL,
                           FOREIGN KEY (evaluation_id) REFERENCES evaluation(evaluation_id),
                           FOREIGN KEY (task_type_id) REFERENCES task_type(task_type_id),
                           FOREIGN KEY (task_item_id) REFERENCES task_item(task_item_id)
) ENGINE=INNODB COMMENT '과제별 평가' CHARACTER SET utf8mb4;

-- 반기별 부서 평가 통계 테이블
CREATE TABLE semiannual_department_performance_ratio_statistics (
                                                                    statistics_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                    year INT NOT NULL,
                                                                    half VARCHAR(255) NOT NULL,
                                                                    created_at TIMESTAMP NOT NULL,
                                                                    department_code VARCHAR(255) NOT NULL,
                                                                    task_eval_id BIGINT NOT NULL,
                                                                    FOREIGN KEY (department_code) REFERENCES department(department_code),
                                                                    FOREIGN KEY (task_eval_id) REFERENCES task_eval(task_eval_id)
) ENGINE=INNODB COMMENT '반기별 부서 평가 통계' CHARACTER SET utf8mb4;

-- 월별 부서 초과 근무 수당 통계 테이블
CREATE TABLE monthly_department_overtime_allowance_statistics (
                                                                  statistics_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                  year INT NOT NULL,
                                                                  month INT NOT NULL,
                                                                  total_amount BIGINT NOT NULL,
                                                                  created_at TIMESTAMP NOT NULL,
                                                                  department_code VARCHAR(255) NOT NULL,
                                                                  FOREIGN KEY (department_code) REFERENCES department(department_code)
) ENGINE=INNODB COMMENT '월별 부서 초과 근무 수당 통계' CHARACTER SET utf8mb4;

-- 월별 사원수 통계 테이블
CREATE TABLE monthly_employee_num_statistics (
                                                 statistics_id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                 year INT NOT NULL,
                                                 month INT NOT NULL,
                                                 half VARCHAR(255) NOT NULL,
                                                 total_employee_num BIGINT NOT NULL,
                                                 joined_employee_num BIGINT NOT NULL,
                                                 lefted_employee_num BIGINT NOT NULL,
                                                 created_at TIMESTAMP NOT NULL
) ENGINE=INNODB COMMENT '월별 사원수 통계' CHARACTER SET utf8mb4;

CREATE TABLE BATCH_JOB_INSTANCE  (
                                     JOB_INSTANCE_ID BIGINT  NOT NULL PRIMARY KEY ,
                                     VERSION BIGINT ,
                                     JOB_NAME VARCHAR(100) NOT NULL,
                                     JOB_KEY VARCHAR(32) NOT NULL,
                                     constraint JOB_INST_UN unique (JOB_NAME, JOB_KEY)
) ENGINE=InnoDB CHARACTER SET utf8mb4;

CREATE TABLE BATCH_JOB_EXECUTION  (
                                      JOB_EXECUTION_ID BIGINT  NOT NULL PRIMARY KEY ,
                                      VERSION BIGINT  ,
                                      JOB_INSTANCE_ID BIGINT NOT NULL,
                                      CREATE_TIME DATETIME(6) NOT NULL,
                                      START_TIME DATETIME(6) DEFAULT NULL ,
                                      END_TIME DATETIME(6) DEFAULT NULL ,
                                      STATUS VARCHAR(10) ,
                                      EXIT_CODE VARCHAR(2500) ,
                                      EXIT_MESSAGE VARCHAR(2500) ,
                                      LAST_UPDATED DATETIME(6),
                                      constraint JOB_INST_EXEC_FK foreign key (JOB_INSTANCE_ID)
                                          references BATCH_JOB_INSTANCE(JOB_INSTANCE_ID)
) ENGINE=InnoDB CHARACTER SET utf8mb4;

CREATE TABLE BATCH_JOB_EXECUTION_PARAMS  (
                                             JOB_EXECUTION_ID BIGINT NOT NULL ,
                                             PARAMETER_NAME VARCHAR(100) NOT NULL ,
                                             PARAMETER_TYPE VARCHAR(100) NOT NULL ,
                                             PARAMETER_VALUE VARCHAR(2500) ,
                                             IDENTIFYING CHAR(1) NOT NULL ,
                                             constraint JOB_EXEC_PARAMS_FK foreign key (JOB_EXECUTION_ID)
                                                 references BATCH_JOB_EXECUTION(JOB_EXECUTION_ID)
) ENGINE=InnoDB CHARACTER SET utf8mb4;

CREATE TABLE BATCH_STEP_EXECUTION  (
                                       STEP_EXECUTION_ID BIGINT  NOT NULL PRIMARY KEY ,
                                       VERSION BIGINT NOT NULL,
                                       STEP_NAME VARCHAR(100) NOT NULL,
                                       JOB_EXECUTION_ID BIGINT NOT NULL,
                                       CREATE_TIME DATETIME(6) NOT NULL,
                                       START_TIME DATETIME(6) DEFAULT NULL ,
                                       END_TIME DATETIME(6) DEFAULT NULL ,
                                       STATUS VARCHAR(10) ,
                                       COMMIT_COUNT BIGINT ,
                                       READ_COUNT BIGINT ,
                                       FILTER_COUNT BIGINT ,
                                       WRITE_COUNT BIGINT ,
                                       READ_SKIP_COUNT BIGINT ,
                                       WRITE_SKIP_COUNT BIGINT ,
                                       PROCESS_SKIP_COUNT BIGINT ,
                                       ROLLBACK_COUNT BIGINT ,
                                       EXIT_CODE VARCHAR(2500) ,
                                       EXIT_MESSAGE VARCHAR(2500) ,
                                       LAST_UPDATED DATETIME(6),
                                       constraint JOB_EXEC_STEP_FK foreign key (JOB_EXECUTION_ID)
                                           references BATCH_JOB_EXECUTION(JOB_EXECUTION_ID)
) ENGINE=InnoDB CHARACTER SET utf8mb4;

CREATE TABLE BATCH_STEP_EXECUTION_CONTEXT  (
                                               STEP_EXECUTION_ID BIGINT NOT NULL PRIMARY KEY,
                                               SHORT_CONTEXT VARCHAR(2500) NOT NULL,
                                               SERIALIZED_CONTEXT TEXT ,
                                               constraint STEP_EXEC_CTX_FK foreign key (STEP_EXECUTION_ID)
                                                   references BATCH_STEP_EXECUTION(STEP_EXECUTION_ID)
) ENGINE=InnoDB CHARACTER SET utf8mb4;

CREATE TABLE batch_job_execution_context  (
                                              JOB_EXECUTION_ID BIGINT NOT NULL PRIMARY KEY,
                                              SHORT_CONTEXT VARCHAR(2500) NOT NULL,
                                              SERIALIZED_CONTEXT TEXT ,
                                              constraint JOB_EXEC_CTX_FK foreign key (JOB_EXECUTION_ID)
                                                  references BATCH_JOB_EXECUTION(JOB_EXECUTION_ID)
) ENGINE=InnoDB CHARACTER SET utf8mb4;

CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 MINVALUE 1 MAXVALUE 9223372036854775806 INCREMENT BY 1 NOCACHE NOCYCLE ENGINE=InnoDB;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 MINVALUE 1 MAXVALUE 9223372036854775806 INCREMENT BY 1 NOCACHE NOCYCLE ENGINE=InnoDB;
CREATE SEQUENCE BATCH_JOB_SEQ START WITH 1 MINVALUE 1 MAXVALUE 9223372036854775806 INCREMENT BY 1 NOCACHE NOCYCLE ENGINE=InnoDB;
