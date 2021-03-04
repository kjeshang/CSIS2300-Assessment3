CREATE DATABASE SCollege2;
USE SCollege2;

IF EXISTS (SELECT * FROM sysobjects WHERE name='dbCreate')
DROP PROC dbCreate
USE SCollege2
GO
CREATE PROC dbCreate
AS
BEGIN
	-- For each instructor, we need to store the employee ID, name and office number.
	-- EMPLOYEE(EmployeeID,Name,OfficeNumber)
	-- Primary Key = EmployeeID
	CREATE TABLE EMPLOYEE(
	EmployeeID		Char(7)			NOT NULL,
	[Name]			Char(25)		NOT NULL,
	OfficeNumber	Char(5)			NOT NULL,
	CONSTRAINT		EMPLOYEE_PK		PRIMARY KEY(EmployeeID)
	);
	INSERT INTO EMPLOYEE VALUES
	('I004589','James Pitt','E4589'),
	('I006581','Kite Lee','E3562'),
	('I003567','Michael Bell','E2342');
	-- For each student, we need to store the student ID and name.
	-- STUDENT(StudentID,Name)
	-- Primary Key = StudentID
	CREATE TABLE STUDENT(
	StudentID	Int			NOT NULL UNIQUE,
	[Name]		Char(25)	NOT NULL,
	CONSTRAINT	STUDENT_PK	PRIMARY KEY(StudentID)
	);
	INSERT INTO STUDENT VALUES
	(190203,'Marry Ann'),
	(190212,'Jack Little'),
	(190205,'Chris Gold'),
	(190209,'Brad Lee'),
	(190207,'Ella Robson ');
	-- For each course, we need to store the unique course number (e.g., CSIS-2300), the course name (e.g., Database I) and the section numbers. 
	-- COURSE(CourseNumber,Name)
	-- Primary Key = CourseNumber
	CREATE TABLE COURSE(
	CourseNumber	Char(9)			NOT NULL UNIQUE,
	[Name]			Char(25)		NOT NULL,
	CONSTRAINT		COURSE_PK		PRIMARY KEY(CourseNumber)
	);
	INSERT INTO COURSE VALUES
	('CSIS-2300','Database I'),
	('CSIS-2270','Networking');
	-- Each course may have multiple sections.
	-- Each section is taught by exactly one instructor.
	-- COURSE_SECTION(CourseNumber,SectionNumber,EmployeeID)
	-- Primary Key = (SectionNumber,CourseNumber)
	-- Foreign Key = CourseNumber, EmployeeID
	CREATE TABLE COURSE_SECTION(
	SectionNumber	Char(3)				NOT NULL,
	CourseNumber	Char(9)				NOT NULL,
	EmployeeID		Char(7)				NOT NULL,
	CONSTRAINT		COURSE_SECTION_PK	PRIMARY KEY(SectionNumber,CourseNumber),
	CONSTRAINT		COURSE_SECTION_FK1	FOREIGN KEY(CourseNumber)
						REFERENCES COURSE(CourseNumber),
	CONSTRAINT		COURSE_SECTION_FK2	FOREIGN KEY(EmployeeID)
						REFERENCES EMPLOYEE(EmployeeID)
	);
	INSERT INTO COURSE_SECTION VALUES
	('CSIS-2300','001','I004589'),
	('CSIS-2300','002','I003567'),
	('CSIS-2270','020','I003567'),
	('CSIS-2270','022','I006581');
	-- Each student must take at least one course and can only enroll in one section of the same course, but can register to multiple courses.
	-- For each section that a student took, we need to store the final grade.
	-- STUDENT_ENROLLMENT(StudentID,CourseNumber,SectionNumber,FinalGrade)
	-- Primary Key = (StudentID,CourseNumber,SectionNumber)
	-- Foreign Key = StudentID, (CourseNumber, SectionNumber)
	CREATE TABLE STUDENT_ENROLLMENT(
	StudentID		Int						NOT NULL,
	CourseNumber	Char(9)					NOT NULL,
	SectionNumber	Char(3)					NOT NULL,
	FinalGrade		Char(2)					NOT NULL,
	CONSTRAINT		STUDENT_ENROLLMENT_PK	PRIMARY KEY(StudentID,CourseNumber,SectionNumber),
	CONSTRAINT		STUDENT_ENROLLMENT_FK1	FOREIGN KEY(StudentID)
						REFERENCES STUDENT(StudentID),
	CONSTRAINT		STUDENT_ENROLLMENT_FK2	FOREIGN KEY(CourseNumber,SectionNumber)
						REFERENCES COURSE_SECTION(CourseNumber,SectionNumber)
	);
	INSERT INTO STUDENT_ENROLLMENT VALUES
	(190203,'CSIS-2300','001','A'),
	(190212,'CSIS-2300','001','B'),
	(190205,'CSIS-2300','001','A'),
	(190209,'CSIS-2300','002','C'),
	(190203,'CSIS-2270','020','B'),
	(190212,'CSIS-2270','020','C'),
	(190209,'CSIS-2270','020','A'),
	(190207,'CSIS-2270','022','A'),
	(190205,'CSIS-2270','022','C');
END

IF EXISTS (SELECT * FROM sysobjects WHERE name='dbControl')
DROP PROC dbControl
--USE SCollege2
GO
CREATE PROC dbControl(@command VarChar(Max))
AS
BEGIN
	-- CREATE
	IF @command='create'
	BEGIN
		EXEC dbCreate
		PRINT 'Database tables created and values inserted.'
	END
	-- DELETE
	IF @command='delete'
	BEGIN
		DROP TABLE STUDENT_ENROLLMENT;
		DROP TABLE COURSE_SECTION;
		DROP TABLE COURSE;
		DROP TABLE STUDENT;
		DROP TABLE EMPLOYEE;
		PRINT 'Database tables deleted.'
	END
	-- RESET
	IF @command='reset'
	BEGIN
		DROP TABLE STUDENT_ENROLLMENT;
		DROP TABLE COURSE_SECTION;
		DROP TABLE COURSE;
		DROP TABLE STUDENT;
		DROP TABLE EMPLOYEE;
		EXEC dbCreate
		PRINT 'Database reset.'
	END
	ELSE 
		IF @command NOT IN ('create','delete','reset')
			PRINT 'Invalid database command.'
END

EXEC dbControl @command='create';
SELECT * FROM EMPLOYEE;
SELECT * FROM STUDENT;
SELECT * FROM COURSE;
SELECT * FROM COURSE_SECTION;
SELECT * FROM STUDENT_ENROLLMENT;
--EXEC dbControl @command='delete';
EXEC dbControl @command='reset';

-- a)	How many students enrolled in CSIS-2300
SELECT COUNT(*) FROM STUDENT_ENROLLMENT WHERE CourseNumber='CSIS-2300';

-- b)	Who has the student ID as 190207? 
SELECT Student.[Name] FROM STUDENT WHERE StudentID=190207;

-- c)	Which course(s) did the student with ID 190209 take? What is(are) the grade (s)?
SELECT CourseNumber,FinalGrade FROM STUDENT_ENROLLMENT WHERE StudentID=190209;