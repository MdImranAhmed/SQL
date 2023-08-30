USE Master
GO
IF DB_ID('ProjectDB') is not null
DROP DATABASE ProjectDB
GO
CREATE DATABASE ProjectDB
ON
(
	Name='ProjectDB_Data_1',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ProjectDB_Data_1.mdf',
	Size=25MB,
	MaxSize=100MB,
	FileGrowth=5%
)
LOG ON
(
	Name='ProjectDB_Log_1',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ProjectDB_Log_1.ldf',
	Size=2MB,
	MaxSize=50MB,
	FileGrowth=1MB
)
GO

USE ProjectDB
GO

CREATE TABLE Department
(
	DeptCode varchar(15) primary key nonclustered  not null ,
	DeptName Varchar(12) not null,
)
CREATE Clustered index ix_Department_DeptName
on Department(DeptName)
GO
CREATE TABLE Manager
(
	ManCode varchar(15) primary key not null ,
	ManFname Varchar(10) not null,
	ManLname Varchar(10) not null
)

GO
CREATE TABLE Employee
(
	EmpCode varchar(15) primary key  not null ,
	EmpFname Varchar(10) not null,
	EmpLname Varchar(10) not null,
	DeptCode varchar(15) references Department(DeptCode) 
)

GO
CREATE TABLE ProjectDetails
(
	ProCode varchar(15) not null,
	ProTitle varchar(20) not null,
	ManCode varchar(15) references Manager(ManCode),
	EmpCode varchar(15) references Employee(EmpCode),
	ProBudget money not null,
	HourlyRate money not null,
	Primary Key (ProCode,ManCode,EmpCode)
)

GO
--View 
Create view vw_ProjectDetails
AS
SELECT p.ProCode as "Project Code",p.ProTitle As "Project Title", e.EmpCode AS "Employee Code",e.EmpFname+' '+e.EmpLname as "Employee Name" , 
M.ManFname+' '+M.ManLname as "Project Manager",p.ProBudget As "Project Budget",d.DeptCode AS "Department Code",D.DeptName as "Department Name",
P.HourlyRate as "Hourly Rate"
FROM ProjectDetails p
JOIN Manager m on m.ManCode=p.ManCode
JoIN Employee e on e.EmpCode=p.EmpCode
join Department d on d.DeptCode=e.DeptCode

--
Create view vw_ProjectDetailsWithEncp
With encryption
AS
SELECT p.ProCode as "Project Code",p.ProTitle As "Project Title", e.EmpCode AS "Employee Code",e.EmpFname+' '+e.EmpLname as "Employee Name" , 
M.ManFname+' '+M.ManLname as "Project Manager",p.ProBudget As "Project Budget",d.DeptCode AS "Department Code",D.DeptName as "Department Name",
P.HourlyRate as "Hourly Rate"
FROM ProjectDetails p
JOIN Manager m on m.ManCode=p.ManCode
JoIN Employee e on e.EmpCode=p.EmpCode
join Department d on d.DeptCode=e.DeptCode

--
Create view vw_ProjectDetailsWithChk
AS
SELECT p.ProCode as "Project Code",p.ProTitle As "Project Title", e.EmpCode AS "Employee Code",e.EmpFname+' '+e.EmpLname as "Employee Name" , 
M.ManFname+' '+M.ManLname as "Project Manager",p.ProBudget As "Project Budget",d.DeptCode AS "Department Code",D.DeptName as "Department Name",
P.HourlyRate as "Hourly Rate"
FROM ProjectDetails p
JOIN Manager m on m.ManCode=p.ManCode
JoIN Employee e on e.EmpCode=p.EmpCode
join Department d on d.DeptCode=e.DeptCode
With check option



GO

-- Create Procedure
CREATE PROC InsertUpdateDeleteOutputErrorTran
@Processtype varchar(10),
@DeptCode varchar(15),
@DeptName Varchar(12),
@ProcessCount int output
AS
BEGIN
BEGIN TRY
BEGIN TRAN
--select
IF @Processtype='Select'
BEGIN
SELECT * FROM Department
END
--insert
IF @Processtype='Insert'
BEGIN
INSERT INTO Department VALUES (@DeptCode,@DeptName)
END
--Update
IF @Processtype='Update'
BEGIN
UPDATE  Department SET DeptName=@DeptName WHERE DeptCode=@DeptCode
END

--Delete
IF @Processtype='Delete'
BEGIN
DELETE FROM Department  WHERE DeptCode=@DeptCode
END
--count
IF @Processtype='Count'
BEGIN
SELECT @ProcessCount=Count(*) from Department
END
COMMIT TRAN
END TRY
BEGIN CATCH
SELECT ERROR_LINE() as ErrorLine,
ERROR_MESSAGE() as Msg,
ERROR_NUMBER() as ErrorNO,
ERROR_SEVERITY() as Severiaty,
ERROR_STATE() as ErrorState
ROLLBACK TRAN
END CATCH
END

GO
--Create Scalar function
CREATE FUNCTION fn_EmpCode
	(@EmpFname varchar(15))
	Returns varchar(15)
BEGIN
	REturn(SELECT EmpCode FROM Employee WHere EmpFname=@EmpFname)
END

GO
--Create Multi-Statement Table-Valued function

Create FUNCTION fnAllPersons()
Returns @Persons Table
(
	PersonId varchar(15),
	PersonFName varchar(15),
	PersonLName Varchar(15),
	PersonType varchar(15)
)
AS 
BEGIN
	INSERT INTO @Persons
	SELECT EmpCode,EmpFname,EmpLname,'Employee' FROm Employee

	INSERT INTO @Persons
	SELECT ManCode,ManFname,ManLname,'Project Manager' FROm Manager
Return;
END

go

--Trigger
CREATE TABLE Trigger_Log
(
	ActivityNo varchar(30),
	ActivityDate datetime,
)
GO
CREATE TRIGGER tr_AfterTrigger
On Employee
After Insert,Update, delete
AS
BEgin
Insert Into Trigger_Log Values ('Data Inserted after',GETDATE())
END

GO
CREATE TRIGGER tr_insteadoftrigger
On manager
INSTEAD OF Insert,Update, delete
AS
BEgin
Insert Into Trigger_Log Values ('Data tried to modify',GETDATE())
END

go

-- table for cursor
CREATE TABLE ProjectDetailsCopy
(
	ProCode varchar(15) not null,
	ProTitle varchar(20) not null,
	ManCode varchar(15) references Manager(ManCode),
	EmpCode varchar(15) references Employee(EmpCode),
	ProBudget money not null,
	HourlyRate money not null,
	Primary Key (ProCode,ManCode,EmpCode)
)

GO

--table For MErge
Create Table Candidate
(
	ID int  not null,
	Name varchar(20) not null
)

Go

Create Table Person
(
	Name varchar(20) not null,
	Age int null
)

GO
CREATE TABLE Student
(
	ID int  not null IDENTITY,
	Name varchar(20) not null,
	Age int null
)

go
--SELECT INTO
DROP TABLE EMPloyeeCOPY

--Sequence
go
CREATE SEQUENCE se_SequenceTest
AS INT
START WITH 100 INCREMENT BY 5
MINVALUE 0 MAXVALUE 10000
CYCLE CACHE 10;

go
CREATE TABLE SequenceTable
(
	SequenceNo int,  
	SeDescription varchar(30)
)
go
