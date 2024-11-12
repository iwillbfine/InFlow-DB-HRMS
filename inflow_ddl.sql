DROP TABLE IF EXISTS monthly_employee_num_statistics;
DROP TABLE IF EXISTS monthly_department_overtime_allowance_statistics;
DROP TABLE IF EXISTS semiannual_department_performance_ratio_statistics;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS task_eval;
DROP TABLE IF EXISTS evaluation;
DROP TABLE IF EXISTS grade;
DROP TABLE IF EXISTS evaluation_policy;
DROP TABLE IF EXISTS task_item;
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
DROP TABLE IF EXISTS checklist;
DROP TABLE IF EXISTS appointment;
DROP TABLE IF EXISTS discipline_reward;
DROP TABLE IF EXISTS language_test;
DROP TABLE IF EXISTS `language`;
DROP TABLE IF EXISTS qualification;
DROP TABLE IF EXISTS contract;
DROP TABLE IF EXISTS career;
DROP TABLE IF EXISTS education;
DROP TABLE IF EXISTS family_member;
DROP TABLE IF EXISTS family_relationship;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS duty;
DROP TABLE IF EXISTS `role`;
DROP TABLE IF EXISTS `position`;
DROP TABLE IF EXISTS attendance_status_type;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS company;

CREATE TABLE company (
	company_id BIGINT PRIMARY KEY AUTO_INCREMENT,
	company_name VARCHAR(255) NOT NULL,
	ceo VARCHAR(255) NOT NULL,
	business_registration_number VARCHAR(255) NOT NULL,
	company_address VARCHAR(255) NOT NULL,
	company_phone_number VARCHAR(255) NOT NULL,
	company_stamp_url TEXT NOT NULL
);

CREATE TABLE department (
   department_code VARCHAR(255) PRIMARY KEY,
   department_name VARCHAR(255) NOT NULL,
   created_at TIMESTAMP NOT NULL,
   disbanded_at TIMESTAMP NULL,
   min_employee_num INT NOT NULL DEFAULT 0,
	upper_department_code VARCHAR(255) NULL,
   FOREIGN KEY (upper_department_code) REFERENCES department(department_code)
);

CREATE TABLE attendance_status_type (
   attendance_status_type_code VARCHAR(255) PRIMARY KEY,
   attendance_status_type_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE `position` (
   position_code VARCHAR(255) PRIMARY KEY,
   position_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE `role` (
   role_code VARCHAR(255) PRIMARY KEY,
   role_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE duty (
   duty_code VARCHAR(255) PRIMARY KEY,
   duty_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE employee (
   employee_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   employee_number VARCHAR(255) NOT NULL UNIQUE,
   password VARCHAR(255) NOT NULL,
   gender VARCHAR(255) NOT NULL CHECK(gender IN ('MALE', 'FEMALE')),
   name VARCHAR(255) NOT NULL,
   birth_date DATETIME NOT NULL,
   resident_registration_number VARCHAR(255) NOT NULL UNIQUE,
   email VARCHAR(255) NOT NULL UNIQUE,
   phone_number VARCHAR(255) NOT NULL,
   profile_img_url TEXT NOT NULL,
   join_date TIMESTAMP NOT NULL,
   join_type VARCHAR(255) NOT NULL CHECK(join_type IN ('ROOKIE','VETERAN')),
   resignation_date TIMESTAMP NULL,
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
);

CREATE TABLE family_relationship (
   family_relationship_code VARCHAR(255) PRIMARY KEY,
   family_relationship_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE family_member (
   family_member_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   name VARCHAR(255) NOT NULL,
   birth_date DATETIME NOT NULL,
   employee_id BIGINT NOT NULL,
   family_relationship_code VARCHAR(255) NOT NULL,
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
   FOREIGN KEY (family_relationship_code) REFERENCES family_relationship(family_relationship_code)
);

CREATE TABLE education (
   education_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   school_name VARCHAR(255) NOT NULL,
   admission_date TIMESTAMP NOT NULL,
   graduation_date TIMESTAMP NOT NULL,
   degree VARCHAR(255) NOT NULL,
   major VARCHAR(255) NULL,
   employee_id BIGINT NOT NULL,
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE career (
   career_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   company_name VARCHAR(255) NOT NULL,
   role_name VARCHAR(255) NOT NULL,
   join_date TIMESTAMP NOT NULL,
   resignation_date TIMESTAMP NOT NULL,
   employee_id BIGINT NOT NULL,
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE contract (
   contract_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   contract_type VARCHAR(255) NOT NULL,
   created_at TIMESTAMP NOT NULL,
   file_name VARCHAR(255) NOT NULL,
   file_url TEXT NOT NULL UNIQUE,
   review_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(review_status IN ('Y','N')),
   employee_id BIGINT NOT NULL,
   reviewer_id BIGINT NOT NULL,
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
   FOREIGN KEY (reviewer_id) REFERENCES employee(employee_id)
);

CREATE TABLE qualification (
   qualification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   qualification_name VARCHAR(255) NOT NULL,
   qualification_number VARCHAR(255) NOT NULL UNIQUE,
   qualified_at TIMESTAMP NOT NULL,
   issuer VARCHAR(255) NOT NULL,
   grade_score VARCHAR(255) NOT NULL,
   employee_id BIGINT NOT NULL,
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE `language` (
   language_code VARCHAR(255) PRIMARY KEY,
   language_name VARCHAR(255) NOT NULL UNIQUE
);

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
);

CREATE TABLE discipline_reward (
   discipline_reward_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   discipline_reward_name VARCHAR(255) NOT NULL,
   content VARCHAR(255) NOT NULL,
   created_at TIMESTAMP NOT NULL,
   employee_id BIGINT NOT NULL,
	FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE appointment (
   appointment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   appointed_at TIMESTAMP NOT NULL,
   employee_id BIGINT NOT NULL,
   authorizer_id BIGINT NOT NULL,
   department_code VARCHAR(255) NOT NULL,
   duty_code VARCHAR(255) NOT NULL,
   role_code VARCHAR(255) NOT NULL,
   position_code VARCHAR(255) NOT NULL,
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
   FOREIGN KEY (authorizer_id) REFERENCES employee(employee_id),
   FOREIGN KEY (department_code) REFERENCES department(department_code),
   FOREIGN KEY (duty_code) REFERENCES duty(duty_code),
   FOREIGN KEY (role_code) REFERENCES `role`(role_code),
   FOREIGN KEY (position_code) REFERENCES `position`(position_code)
);

CREATE TABLE checklist (
   checklist_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   content VARCHAR(255) NOT NULL,
   check_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(check_status IN ('Y', 'N')),
   created_at TIMESTAMP NOT NULL,
   employee_id BIGINT NOT NULL,
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id)   
);

CREATE TABLE department_member (
   department_member_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   employee_number VARCHAR(255) NOT NULL UNIQUE,
   name VARCHAR(255) NOT NULL,
   role_name VARCHAR(255) NOT NULL,
   email VARCHAR(255) NOT NULL UNIQUE,
   profile_img_url TEXT NOT NULL,
   phone_number VARCHAR(255) NOT NULL,
   attendance_status_type_name VARCHAR(255) NOT NULL,
   manager_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(manager_status IN ('Y', 'N')),
   department_code VARCHAR(255) NOT NULL,
   employee_id BIGINT NOT NULL,
   FOREIGN KEY (department_code) REFERENCES department(department_code),
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE vacation_type (
   vacation_type_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   vacation_type_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE vacation_policy (
   vacation_policy_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   vacation_policy_name VARCHAR(255) NOT NULL,
   vacation_policy_description TEXT NOT NULL,
   allocation_days BIGINT NOT NULL,
   paid_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(paid_status IN ('Y', 'N')),
   year INT NOT NULL,
   created_at TIMESTAMP NOT NULL,
   auto_allocation_cycle VARCHAR(255) NULL,
   vacation_type_id BIGINT NOT NULL,
   policy_register_id BIGINT NOT NULL,
   FOREIGN KEY (vacation_type_id) REFERENCES vacation_type(vacation_type_id),
   FOREIGN KEY (policy_register_id) REFERENCES employee(employee_id)
);

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
);

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
);

CREATE TABLE vacation_request_file (
   vacation_request_file_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   file_name VARCHAR(255) NOT NULL,
   file_url TEXT NOT NULL UNIQUE,
   vacation_request_id BIGINT NOT NULL,
   FOREIGN KEY (vacation_request_id) REFERENCES vacation_request(vacation_request_id)
);

CREATE TABLE annual_vacation_promotion_policy (
   annual_vacation_promotion_policy_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   month INT NOT NULL,
   day INT NOT NULL,
   standard INT NOT NULL
);

CREATE TABLE earned_income_tax (
   earned_income_tax_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   monthly_salary_more BIGINT NOT NULL,
   monthly_salary_under BIGINT NOT NULL,
   child_num INT NOT NULL,
   amount BIGINT NOT NULL
);

CREATE TABLE major_insurance (
   major_insurance_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   insurance_name VARCHAR(255) NOT NULL,
   tax_rates DOUBLE NOT NULL
);

CREATE TABLE non_taxable (
   non_taxable_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   non_taxable_name VARCHAR(255) NOT NULL,
   amount BIGINT NOT NULL
);

CREATE TABLE tax_credit (
   tax_credit_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   valid_child_num INT NOT NULL,
   base_deductible BIGINT NOT NULL,
   additional_deductible_per_child BIGINT NOT NULL
);

CREATE TABLE public_holiday (
   public_holiday_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   year INT NOT NULL,
   month INT NOT NULL,
   day_num INT NOT NULL
);

CREATE TABLE irregular_allowance (
   irregular_allowance_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   irregular_allowance_name VARCHAR(255) NOT NULL,
   amount BIGINT NOT NULL
);

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
   non_taxable_id BIGINT NOT NULL,
   major_insurance_id BIGINT NOT NULL,
   earned_income_tax_id BIGINT NOT NULL,
   tax_credit_id BIGINT NOT NULL,
   irregular_allowance_id BIGINT NOT NULL,
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
   FOREIGN KEY (public_holiday_id) REFERENCES public_holiday(public_holiday_id),
   FOREIGN KEY (non_taxable_id) REFERENCES non_taxable(non_taxable_id),
   FOREIGN KEY (major_insurance_id) REFERENCES major_insurance(major_insurance_id),
   FOREIGN KEY (earned_income_tax_id) REFERENCES earned_income_tax(earned_income_tax_id),
   FOREIGN KEY (tax_credit_id) REFERENCES tax_credit(tax_credit_id),
   FOREIGN KEY (irregular_allowance_id) REFERENCES irregular_allowance(irregular_allowance_id)
);

CREATE TABLE attendance_request_type (
   attendance_request_type_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   attendance_request_type_name VARCHAR(255) NOT NULL UNIQUE,
   attendance_request_type_description TEXT NOT NULL
);

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
);

CREATE TABLE attendance_request_file (
   attendance_request_file_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   file_name VARCHAR(255) NOT NULL,
   file_url TEXT NOT NULL UNIQUE,
   attendance_request_id BIGINT NOT NULL,
   FOREIGN KEY (attendance_request_id) REFERENCES attendance_request(attendance_request_id)
);

CREATE TABLE commute (
   commute_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   start_time TIMESTAMP NOT NULL,
   end_time TIMESTAMP NULL,
   remote_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(remote_status IN ('Y', 'N')),
   overtime_status VARCHAR(255) NOT NULL DEFAULT 'N' CHECK(overtime_status IN ('Y', 'N')),
   employee_id BIGINT NOT NULL,
   attendance_request_id BIGINT NULL,
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
   FOREIGN KEY (attendance_request_id) REFERENCES attendance_request(attendance_request_id)
);

CREATE TABLE leave_return (
   leave_return_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   start_date TIMESTAMP NOT NULL,
   end_date TIMESTAMP NOT NULL,
   employee_id BIGINT NOT NULL,
   attendance_request_id BIGINT NOT NULL,
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
   FOREIGN KEY (attendance_request_id) REFERENCES attendance_request(attendance_request_id)
);

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
);



CREATE TABLE task_type (
   task_type_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   task_type_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE task_item (
   task_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   task_name VARCHAR(255) NOT NULL,
   task_content TEXT NOT NULL,
   assigned_employee_count BIGINT NOT NULL,
   task_type_id BIGINT NOT NULL,
   FOREIGN KEY (task_type_id) REFERENCES task_type(task_type_id)
);

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
);

CREATE TABLE grade (
   grade_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   grade_name VARCHAR(255) NOT NULL UNIQUE,
   start_ratio DOUBLE NOT NULL,
   end_ratio DOUBLE NOT NULL,
   evaluation_policy_id BIGINT NOT NULL,
   FOREIGN KEY (evaluation_policy_id) REFERENCES evaluation_policy(evaluation_policy_id)
);

CREATE TABLE evaluation (
   evaluation_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   evaluation_type VARCHAR(255) NOT NULL,
   final_grade VARCHAR(255) NULL,
   final_score DOUBLE NULL,
   year INT NOT NULL,
   half VARCHAR(255) NOT NULL,
   created_at TIMESTAMP NOT NULL,
   modifiable_date TIMESTAMP NOT NULL,
   evaluator_id BIGINT NOT NULL,
   employee_id BIGINT NOT NULL,
   evaluation_policy_id BIGINT NOT NULL,
   FOREIGN KEY (evaluator_id) REFERENCES employee(employee_id),
   FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
   FOREIGN KEY (evaluation_policy_id) REFERENCES evaluation_policy(evaluation_policy_id)
);

CREATE TABLE feedback (
   feedback_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   content TEXT NOT NULL,
   created_at TIMESTAMP NOT NULL,
   evaluation_id BIGINT NOT NULL,
   FOREIGN KEY (evaluation_id) REFERENCES evaluation(evaluation_id)
);

CREATE TABLE task_eval (
   task_eval_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   task_eval_name VARCHAR(255) NOT NULL,
   task_eval_content TEXT NOT NULL,
   score DOUBLE NOT NULL,
   set_ratio DOUBLE NOT NULL,
   task_grade VARCHAR(255) NOT NULL,
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
);

CREATE TABLE semiannual_department_performance_ratio_statistics (
   statistics_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   year INT NOT NULL,
   half VARCHAR(255) NOT NULL,
   performance_ratio DOUBLE NOT NULL,
   created_at TIMESTAMP NOT NULL,
   department_code VARCHAR(255) NOT NULL,
   FOREIGN KEY (department_code) REFERENCES department(department_code)
);

CREATE TABLE monthly_department_overtime_allowance_statistics (
   statistics_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   year INT NOT NULL,
   month INT NOT NULL,
   total_amount BIGINT NOT NULL,
   created_at TIMESTAMP NOT NULL,
   department_code VARCHAR(255) NOT NULL,
   FOREIGN KEY (department_code) REFERENCES department(department_code)
);

CREATE TABLE monthly_employee_num_statistics (
   statistics_id BIGINT PRIMARY KEY AUTO_INCREMENT,
   year INT NOT NULL,
   month INT NOT NULL,
   half VARCHAR(255) NOT NULL,
   total_employee_num BIGINT NOT NULL,
   joined_employee_num BIGINT NOT NULL,
   lefted_employee_num BIGINT NOT NULL,
   created_at TIMESTAMP NOT NULL
);