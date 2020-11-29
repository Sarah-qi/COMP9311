-- comp9311 20T3 Project 1
--
-- MyMyUNSW Solutions


--Q1
---seeks for the courses_id in 2010
create or replace view Q1_1 as
select courses.id
from courses, semesters
where courses.semester = semesters.id and semesters.year = 2010;

---seeks for the number of courses taught by each staff 
create or replace view Q1_2 as
select course_staff.role, count(distinct course_staff.course)
from course_staff, Q1_1
where course_staff.course = Q1_1.id
group by course_staff.role
having count(distinct course_staff.course) >= 1;

---seeks for the name of staffs and the number fo courses they taught
create or replace view Q1(staff_role, course_num) as
select staff_roles.name, Q1_2.count
from Q1_2, staff_roles
where Q1_2.role = staff_roles.id
order by Q1_2.count;


--Q2
---seeks for information of classes which type is 'Studio'
create or replace view Q2_1 as
select distinct classes.course, classes.id, classes.room
from classes, class_types
where classes.ctype = class_types.id and class_types.name = 'Studio';

---seeks for the courses that the Studio classes in Q2_1 of this course are hold in 3 different buildings
create or replace view Q2(course_id) as
select Q2_1.course
from Q2_1, rooms
where Q2_1.room = rooms.id
group by Q2_1.course
having count(distinct rooms.building) >= 3;


--Q3
---seeks for the courses enrolled by at least one international student
create or replace view Q3_1 as
select course_enrolments.course from course_enrolments, students where course_enrolments.student = students.id
and students.stype = 'intl';

---seeks for classesrooms which equipped with both Student and Teacher wheelchair access
create or replace view Q3_2 as
(select room_facilities.room from room_facilities where room_facilities.facility in 
(select facilities.id from facilities where facilities.description = 'Student wheelchair access'))
intersect
(select room_facilities.room from room_facilities where room_facilities.facility in
(select facilities.id from facilities where facilities.description = 'Teacher wheelchair access')); 

---seeks for the courses which have at least one classesroom in Q3_2
create or replace view Q3_3 as
select classes.course from classes where classes.room in (select * from Q3_2);

---seeks for the distinct number of courses in Q3_3 and also enrolled by at least one intl student
create or replace view Q3(course_num) as
select count(distinct Q3_3.course) from Q3_3
where Q3_3.course in (select * from Q3_1);


--Q4
---seeks for unswid and name of local students who enrolled course offered by School of Chemical Science and
---got a mark hiogher than 87
create or replace view Q4(unswid, name) as
select people.unswid, people.name
from people
where people.id in (select students.id from course_enrolments, students where
course_enrolments.student = students.id and course_enrolments.mark > 87 and students.stype = 'local' and
course_enrolments.course in (select courses.id from courses where courses.subject in
(select subjects.id from subjects where subjects.offeredby in 
(select orgunits.id from orgunits where orgunits.name = 'School of Chemical Sciences'))))
order by people.unswid desc;


--Q5
---seeks for the number of enrolled students and average mark in valid courses which have at least 10 students
create or replace view Q5_1 as
select course_enrolments.course, cast(count(course_enrolments.student) as decimal(10,3)), avg(course_enrolments.mark)::numeric(10,3)
from course_enrolments
where course_enrolments.mark is not null 
group by course_enrolments.course having count(course_enrolments.student) >= 10;

---seeks for the number of students in courses that receive marks higher than Q5_1.avg
create or replace view Q5_2 as
select Q5_1.course, cast(count(course_enrolments.student) as decimal(10,3)) from Q5_1, course_enrolments
where Q5_1.course = course_enrolments.course and course_enrolments.mark > Q5_1.avg
group by Q5_1.course;

---seeks for the courses in Q5_2 which have more than 4/5 students in Q5_1.count
create or replace view Q5(course_id) as
select Q5_1.course from Q5_1, Q5_2
where Q5_1.course = Q5_2.course and Q5_2.count > 0.8 * Q5_1.count;


--Q6
---seeks for the numebr of courses in each semester
create or replace view Q6_1 as
select courses.semester, count(distinct courses.id)
from courses
where courses.id in (select course_enrolments.course from course_enrolments 
group by course_enrolments.course having count(course_enrolments.student) >= 10)
group by courses.semester;

---seeks for the semesters.longname for each semester and combined with Q6_1.count
create or replace view Q6_2 as
select semesters.longname, Q6_1.count num
from semesters, Q6_1
where semesters.id = Q6_1.semester;

---seeks for the highest course_num in that semester
create or replace view Q6(semester, course_num) as
select Q6_2.longname, Q6_2.num
from Q6_2
where Q6_2.num = (select max(Q6_2.num) from Q6_2);


--Q7
---seeks for the semesters and courses in 2007 and 2008
create or replace view Q7_1 as
select semesters.name, courses.id 
from semesters, courses
where semesters.id = courses.semester and (semesters.year = 2007 or semesters.year = 2008);

---seeks forr the courses in Q7_1 and its avgerage mark that have at least 20 not full mark  and 75 < avg < 80
create or replace view Q7_2 as
select Q7_1.id, avg(course_enrolments.mark)::numeric(4,2) 
from Q7_1, course_enrolments
where Q7_1.id = course_enrolments.course and mark is not null
group by Q7_1.id having count(course_enrolments.mark is not null) >= 20 and 
avg(course_enrolments.mark) > 75 and avg(course_enrolments.mark) < 80;

---seeks for the courses, its avg in Q7_2 and its corresponds semester in Q7_1 
create or replace view Q7(course_id, avgmark, semester) as
select Q7_2.id, Q7_2.avg, Q7_1.name
from Q7_1, Q7_2
where Q7_1.id = Q7_2.id
order by Q7_1.id desc;


--Q8
---seeks for unswid of students in 2009 and 2010 enrolled in the Medicine stream
create or replace view Q8_1 as
select people.unswid from people where people.id in
(select program_enrolments.student from program_enrolments 
where program_enrolments.semester in 
(select semesters.id from semesters where semesters.year = 2009 or semesters.year = 2010) and
program_enrolments.id in 
(select stream_enrolments.partOf from stream_enrolments where stream_enrolments.stream in 
(select streams.id from streams where streams.name = 'Medicine')));

---seeks for the unswid of students who enrolled in any courses offered by organizations having 'Engineering' in the name
create or replace view Q8_2 as
select people.unswid from people where people.id in (select course_enrolments.student from course_enrolments 
where course_enrolments.course in (select courses.id from courses where courses.subject in 
(select subjects.id from subjects where subjects.offeredby in 
(select orgunits.id from orgunits where orgunits.name like '%Engineering%'))));

---seeks for unswid in Q8_1 but of students never enrolled in any courses offered by organizations having 'Engineering' in the name
create or replace view Q8_3 as
select * from Q8_1 except select * from Q8_2;

---seeks for international students in students
create or replace view Q8_4 as select students.id from students where students.stype = 'intl';


---seeks for unswid in Q8_3 which has only intl students
create or replace view Q8_5 as
select Q8_3.unswid from Q8_3 where Q8_3.unswid in (select people.unswid from people where 
people.id in (select * from Q8_4));

---seeks for the number of distinct unswid in Q8_5
create or replace view  Q8(num) as
select count(distinct Q8_5.unswid) from Q8_5;


--Q9
---seeks for semesters and all the courses
create or replace view Q9_1 as
select semesters.year, semesters.term, courses.subject, courses.id 
from semesters, courses 
where semesters.id = courses.semester;

---seeks for the semesters which has 'Database Systems' subjects
create or replace view Q9_2 as
select Q9_1.year, Q9_1.term, Q9_1.id, subjects.name from Q9_1, subjects 
where Q9_1.subject = subjects.id and subjects.name = 'Database Systems';

---seeks for avgerage mark which is not null mark in each semesters in Q9_2
create or replace view Q9(year, term, average_mark) as
select Q9_2.year, Q9_2.term, avg(course_enrolments.mark)::numeric(4,2) 
from Q9_2, course_enrolments 
where Q9_2.id = course_enrolments.course and course_enrolments.mark is not null
group by Q9_2.year, Q9_2.term, Q9_2.name;


--Q10
---seeks for the orgunits and programs
create or replace view Q10_1 as
select orgunits.longname, programs.id from orgunits, programs where orgunits.id = programs.offeredby;

---seeks for years, orgunits longname and its semester
create or replace view Q10_2 as
select Q10_1.longname, program_enrolments.student, program_enrolments.semester from Q10_1, program_enrolments 
where Q10_1.id = program_enrolments.program;

---seeks for internatinal studens in Q10_2
create or replace view Q10_3 as 
select semesters.year, Q10_2.student, Q10_2.longname from Q10_2, semesters
where Q10_2.semester = semesters.id and Q10_2.student in 
(select students.id from students where students.stype = 'intl');

---seeks for the number of distinct students in Q10_2 each unit and year
create or replace view Q10_4 as
select Q10_3.year, count(distinct Q10_3.student), Q10_3.longname from Q10_3 group by Q10_3.year, Q10_3.longname;

---seeks for the unit with greatest number of distinct intl student enrolled  
create or replace view Q10_5 as
select max(Q10_4.count), Q10_4.longname from Q10_4 group by Q10_4.longname;

---seeks for each unit, the year with the greatest number of distinct students enrolled
create or replace view Q10(year, num, unit) as
select Q10_4.year, Q10_5.max, Q10_5.longname from Q10_4, Q10_5 
where Q10_4.count = Q10_5.max and Q10_4.longname = Q10_5.longname and Q10_4.year in 
(select Q10_4.year from Q10_4, Q10_5 where Q10_4.count = Q10_5.max);


--Q11
---seeks for valid students and their marks and courses in 2011 S1, who have mark >= 0
create or replace view Q11_1 as
select course_enrolments.course, course_enrolments.student, course_enrolments.mark
from course_enrolments, courses
where courses.id = course_enrolments.course and course_enrolments.mark >= 0 and courses.semester in 
(select semesters.id from semesters where semesters.year = 2011 and semesters.term = 'S1');

---seeks for students who complete at least 3 courses in Q11_1
create or replace view Q11_2 as
select Q11_1.student from Q11_1 group by Q11_1.student having count(Q11_1.course) >=3;

---seeks for students in Q11_2 and their correspinds marks
create or replace view Q11_3 as
select Q11_2.student, Q11_1.mark from Q11_1, Q11_2 where Q11_1.student = Q11_2.student;

---seeks for unswid, name of students and calculate their average mark
create or replace view Q11_4 as
select people.unswid, people.name, avg(Q11_3.mark)::numeric(4,2)
from people, Q11_3
where people.id = Q11_3.student
group by people.unswid, people.name
order by avg(Q11_3.mark) desc;

---seeks for the rank of their average mark
create or replace view Q11_5 as select Q11_4.avg, rank() over (order by Q11_4.avg desc) from Q11_4;

---seeks for unswid, name of ranking 10
create or replace view Q11(unswid, name, avg_mark) as
select distinct Q11_4.unswid, Q11_4.name, Q11_4.avg from Q11_4, Q11_5 
where Q11_4.avg = Q11_5.avg and Q11_5.rank <= 10 order by Q11_4.avg desc;


--Q12
---seeks for rooms which type is Lecture Theatre in Mathews Building
create or replace view Q12_1 as
select rooms.id, rooms.unswid, rooms.longname, rooms.capacity from rooms 
where rooms.rtype in (select room_types.id from room_types where room_types.description = 'Lecture Theatre') and
rooms.building in (select buildings.id from buildings where buildings.name = 'Mathews Building');

---seeks for classes and the number of its enrolled student in 2010 S1
create or replace view Q12_2 as
select classes.id, classes.room, cast(count(course_enrolments.student) as decimal(10,2))
from classes, courses, course_enrolments
where classes.course = courses.id and courses.id = course_enrolments.course and
classes.room in (select Q12_1.id from Q12_1) and courses.semester in 
(select semesters.id from semesters where semesters.year = 2010 and semesters.term = 'S1')
group by classes.id;

---seeks for classroom which have the biggest number of students enrolled
create or replace view Q12_3 as
select Q12_2.room, cast(max(Q12_2.count) as decimal(10,2)) from Q12_2 group by Q12_2.room;

---seeks for unswid, longname of the highest usage rate of classes that use this theatre
create or replace view Q12_4 as
select Q12_1.unswid, Q12_1.longname, (Q12_3.max/Q12_1.capacity)::numeric(4,2)
from Q12_1, Q12_3
where Q12_1.id = Q12_3.room;

---seeks for classes of the lecture theatre which haven't used by any classes
create or replace view Q12_5 as
select Q12_1.id from Q12_1 except select Q12_3.room from Q12_3;

---seeks for unswid, longname of Q12_5
create or replace view Q12_6 as
select Q12_1.unswid, Q12_1.longname from Q12_1, Q12_5 where Q12_5.id = Q12_1.id;

---add the usage rate 0.00 if lecture theatre is not used by any classes
create view Q12_7(unswid, longname, rate) as select Q12_6.unswid, Q12_6.longname, 0.00 from Q12_6;

---union Q12_4 and Q12_7
create or replace view Q12(unswid, longname, rate) as
select * from Q12_4 union select * from Q12_7;

