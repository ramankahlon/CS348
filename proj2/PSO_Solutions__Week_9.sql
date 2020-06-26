set serveroutput on size 32000

create or replace procedure students_in_class(class_name IN Enrolled.cname%TYPE) as
stu_number Enrolled.snum%TYPE;
stu_name Student.sname%TYPE;
CURSOR enr_cur is SELECT snum FROM Enrolled WHERE cname=class_name;
enr_rec enr_cur%ROWTYPE;
begin
	for enr_rec in enr_cur loop
		stu_number := enr_rec.snum;
		select sname into stu_name from Student where snum=stu_number;
		dbms_output.put_line(stu_name);
	end loop;
end students_in_class;
/

begin
students_in_class('ENG40000');
end;
/



create or replace procedure add_faculty(fid IN Faculty.fid%TYPE, fname IN Faculty.fname%TYPE, deptid IN Faculty.deptid%TYPE) as

begin
	INSERT INTO Faculty VALUES(fid, fname, deptid);
end add_faculty;
/

select * from Faculty;

begin
add_faculty(2013, 'Smith', 11);
end;
/

select * from Faculty;



create or replace procedure average_ages as

avg_age number;
num_students number;
dept Department.dname%TYPE;
CURSOR dept_cur is SELECT DISTINCT deptid FROM Student;
CURSOR age_cur(did IN Student.deptid%TYPE) is SELECT age FROM Student where deptid=did;

dept_rec dept_cur%ROWTYPE;
age_rec age_cur%ROWTYPE;

begin
	for dept_rec in dept_cur loop
		avg_age := 0;
		num_students := 0;
		for age_rec in age_cur(dept_rec.deptid) loop
			avg_age := avg_age + age_rec.age;
			num_students := num_students + 1;
		end loop;
		avg_age := avg_age/num_students;
		select dname into dept from Department where deptid=dept_rec.deptid;
		dbms_output.put_line(dept || ' ' || avg_age);
	end loop;
end average_ages;
/

begin
average_ages;
end;
/

