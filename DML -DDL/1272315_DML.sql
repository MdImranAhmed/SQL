USE ProjectDB
GO
/*
Insert INTO Department values
('L004','IT'),
('L023','HR'),
('L008','PAY ROLL'),
('L009','SALES')

--Justify
--SELECT * FROM Department

GO
Insert INTO Manager values
('M2001','Morgan','Philips'),
('M2002','Hubert','Martin'),
('M2003','Kennedy','Lewis')


--Justify
--SELECT * FROM Manager
GO

Insert into Employee values
('S10001','Allen','Smith','L004'),
('S10030','Lewis','Jones','L023'),
('S21010','Prince','Lewis','L004'),
('S10010','Barbara','Jones','L004'),
('S13210','Frank','Richards','L008'),
('S31002','Tony','Gilbert','L023'),
('S10034','Robert','James','L009'),
('S10050','Alex','Brown','L023'),
('S10051','Emily','Brown','L009'),
('S10052','James','Lee','L023'),
('S10053','Pitter','Doe','L009')




--Justify
--SELECT * FROM Employee
GO

Insert into ProjectDetails values
('PC010','Pensions System','M2001','S10001',1000000,220),
('PC010','Pensions System','M2001','S10030',1000000,180.50),
('PC010','Pensions System','M2001','S21010',1000000,210),
('PC045','Salaries System','M2002','S10010',1500000,210),
('PC045','Salaries System','M2002','S10001',1500000,180),
('PC045','Salaries System','M2002','S31002',1500000,25),
('PC045','Salaries System','M2002','S13210',1500000,170),
('PC064','HR System','M2003','S31002',1200000,230),
('PC064','HR System','M2003','S21010',1200000,170),
('PC064','HR System','M2003','S10034',1200000,160)


--Justify
--SELECT * FROM ProjectDetails
GO

--Clustered non-clustered justify
exec sp_helpindex Department

GO
--Update Query
Update  Employee
Set EmpFname='Oliver' where EmpCode='S10050'

--justify
--SELECT * FROM Employee where EmpCode='S10050'

GO

-- DELETE Query
DELETE FROM Employee where EmpCode='S10050'

--justify
--SELECT * FROM Employee where EmpCode='S10050'

go
--Group by +  having + Join Query

SELECT p.ProTitle As "Project Title", e.EmpFname+' '+e.EmpLname as "Employee Name" , M.ManFname+' '+M.ManLname as "Project Manager",
P.HourlyRate as "Hourly Rate" FROm ProjectDetails p
JOIN Manager m on m.ManCode=p.ManCode
JoIN Employee e on e.EmpCode=p.EmpCode
where p.ProCode in
(SELECT ProCode FROM ProjectDetails 
Group By ProTitle,ProBudget,ProCode
having count(EmpCode)>=4)

GO
--a sub-query to show all the information of Project HR System
SELECT p.ProCode as "Project Code",p.ProTitle As "Project Title", e.EmpCode AS "Employee Code",e.EmpFname+' '+e.EmpLname as "Employee Name" , 
M.ManFname+' '+M.ManLname as "Project Manager",p.ProBudget As "Project Budget",d.DeptCode AS "Department Code",D.DeptName as "Department Name",
P.HourlyRate as "Hourly Rate"
FROM ProjectDetails p
JOIN Manager m on m.ManCode=p.ManCode
JoIN Employee e on e.EmpCode=p.EmpCode
join Department d on d.DeptCode=e.DeptCode
Where p.ProCode in
(SELECT ProCode FROm ProjectDetails 
WHERE ProTitle='HR System')

GO
--View justify
exec sp_helptext vw_ProjectDetails

Select * from vw_ProjectDetails

--view with encryption justify
exec sp_helptext vw_ProjectDetailsWithEncp

Select * from vw_ProjectDetailsWithEncp

--view with check option justify
exec sp_helptext vw_ProjectDetailsWithChk

Select * from vw_ProjectDetailsWithChk

GO


--Procedure

InsertUpdateDeleteOutputErrorTran 'Select','','',''
InsertUpdateDeleteOutputErrorTran 'Insert','L050','Marketing',''
InsertUpdateDeleteOutputErrorTran 'Update','L050','Development',''
InsertUpdateDeleteOutputErrorTran 'Delete','L050','',''

Declare @DeptCount int
EXEC InsertUpdateDeleteOutputErrorTran 'Count','','',@DeptCount output
Print @DeptCount

GO


--Scalar function

SELECT * FROM ProjectDetails where EmpCode=dbo.fn_EmpCode('Allen')

go
--Create Multi-Statement Table-Valued function 

SELECT * FROm fnAllPersons()
go


--After Trigger
Insert INTo Employee values('S150247','Jhon','Doe','L023')
update Employee set EmpFname='James' where EmpCode='S150247'
DELETE from Employee where EmpCode='S150247'
--justify
select * from Trigger_Log

go
--insted trigger
Insert INTo Manager values('M150247','Jhon','Doe')
update Manager set manFname='James' where ManCode='M150247'
DELETE from Manager where ManCode='S150247'
--justify
select * from Trigger_Log

GO
--Transaction
BEGIN TRAN
DELETE From Employee WHERE EmpCode='S10051'
if @@RowCOUNT>1
BEGIN
ROLLBACK
Print'Employee id not deleted, RollBack occure'
END 
ELSE
BEGIN
COMMIT TRAN
Print'Task Complited Successfully'
END

--Cte

with cte_ProjectThatHaveMaxEmp
as
(
SELECT p.ProTitle As "Project Title", e.EmpFname+' '+e.EmpLname as "Employee Name" , M.ManFname+' '+M.ManLname as "Project Manager",
P.HourlyRate as "Hourly Rate" FROm ProjectDetails p
JOIN Manager m on m.ManCode=p.ManCode
JoIN Employee e on e.EmpCode=p.EmpCode
where p.ProCode in
(SELECT ProCode FROM ProjectDetails 
Group By ProTitle,ProBudget,ProCode
having count(EmpCode)>=4))

Select * from cte_ProjectThatHaveMaxEmp

GO
--Simple case

SELECT P.ProTitle AS "Project Title",e.EmpFname+' '+e.EmpLname as "Employee Name",
Case DeptCode
	When 'L004' Then 'IT'
	When 'L023' Then 'HR'
	When 'L008' Then 'Pay Roll'
	When 'L009' Then 'Sales'
End as "Department name"
FROM ProjectDetails p
join Employee e on p.EmpCode=e.EmpCode

GO
--Search Case

SELECT P.ProTitle AS "Project Title",e.EmpFname+' '+e.EmpLname as "Employee Name",p.ProBudget,
Case 
	When p.ProBudget>=1500000 Then 'Maximum Budget'
	When p.ProBudget>=1200000 Then 'Medium Budget'
	Else 'Low Budget'
End as "Budget Status"
FROM ProjectDetails p
join Employee e on p.EmpCode=e.EmpCode

GO
--Cursor

DECLARE @Procode varchar(10)
Declare @Protitle varchar(15)
Declare @manCode Varchar(10)
Declare @EmpCode varchar(10)
Declare @Probudget money
Declare @HourlyRate money
Declare @RowCount int
Set @RowCount=0;
Declare ProjectDetails_cursor Cursor
For Select * From ProjectDetails
Open ProjectDetails_cursor
Fetch Next From ProjectDetails_cursor into @Procode,@Protitle,@manCode,@EmpCode,@Probudget,@HourlyRate
While @@FETCH_STATUS<>-1
BEgin
Insert into ProjectDetailsCopy values (@Procode,@Protitle,@manCode,@EmpCode,@Probudget,@HourlyRate)
Set @RowCount=@RowCount+1;
Fetch Next From ProjectDetails_cursor into @Procode,@Protitle,@manCode,@EmpCode,@Probudget,@HourlyRate
End
Close ProjectDetails_cursor
Deallocate ProjectDetails_cursor
Print convert(Varchar,@RowCount)+' Rows Inserted'

--Select * FROM ProjectDetailsCopy


GO
--IIF Choose

SELECT ProTitle,avg(ProBudget) as AvgProBudget, avg(hourlyrate) as avgHourlyRate,
IIF(avg(ProBudget)>=1500000,'High Budget','Low Budget') as iif_f,
Choose(avg(hourlyrate),'High Budget','Low Budget') as choose_f
FROM ProjectDetails
Group By ProTitle,HourlyRate

GO
--Isnull Coalesce
SELECT ProTitle,
isnull(HourlyRate,'0.00') as NewHourlyPrice_Isnull,
Coalesce(HourlyRate,'0.00') as NewHourlyPrice_Coalesce
FROM ProjectDetails

GO
--ranking
SELECT ProTitle,
Rank() over (Order by Protitle) as rank_f,
DENSE_RANK () over (Order by ProBudget) as DenseRank_f,
ROW_NUMBER() over (Partition by ProCode order by Protitle) as RowNumber_f,
NTILE(1) over (Order by Protitle) as Ntile_f
from ProjectDetails

GO
--Merge
BEGIN TRY
Insert Into Candidate values
(1,'AA'),
(2,'BB')
END TRY
BEGIN CATCH
SELECT ERROR_MESSAGE() AS meg,
ERROR_NUMBER() as errorNumber,
ERROR_SEVERITY() AS severity, 
ERROR_STATE() AS State
END CATCH

go

Insert Into Person values
('AA',25),
('CC',22)

GO

MERGE INTO Student s USING
(
SELECT c.ID, C.Name, p.Age FROM Candidate c
JOin Person p on c.Name=p.Name
) s1 on s.ID=s1.ID
WHEN MATCHED THEN 
	UPDATE SET s.Name=s1.Name , s.Age=s1.Age
WHEN NOT MATCHED THEN
	INSERT (Name,Age) VALUES (s1.Name, s1.Age);

GO
--DELETE COLUMN and Table
Alter table student
Drop column age

GO

Drop table student


GO
----SEQUENCE
INSERT INTO SequenceTable VALUES
(NEXT VALUE FOR se_SequenceTest,'First Row inserted')

INSERT INTO SequenceTable VALUES
(NEXT VALUE FOR se_SequenceTest,'Second Row inserted')

INSERT INTO SequenceTable VALUES
(NEXT VALUE FOR se_SequenceTest,'Third Row inserted')

--justify
--SELECT * FROM SequenceTable

go

--Different Queries

--distinct
select Distinct ProTitle,ProCode,ProBudget  from ProjectDetails
GO
--top + orderby
select top 3 with ties ProTitle, HourlyRate  from ProjectDetails
Order by HourlyRate DESC

GO
--where+and+between
SELECT * from ProjectDetails 
Where HourlyRate =230 or HourlyRate=220 and ProBudget>=1200000

GO
SELECT * from ProjectDetails 
Where HourlyRate between 180 and 210

GO

SELECT * from ProjectDetails 
Where HourlyRate not between 180 and 210

Go
--join
SELECT e.empcode,e.empFname,e.empLname,p.Protitle,P.hourlyRate from Employee e
join projectDetails p on p.empCode=e.empcode where EmpFname like'ALL%'  

go
--inner join
SELECT e.empcode,e.empFname,e.empLname,p.Protitle,P.hourlyRate from Employee e
join projectDetails p on p.empCode=e.empcode where EmpLname like'_ones'  

go
--left join
SELECT e.empcode,e.empFname,e.empLname,p.Protitle,P.hourlyRate from Employee e
Left join projectDetails p on p.empCode=e.empcode

go
--right join
SELECT e.empcode,e.empFname,e.empLname,p.Protitle,P.hourlyRate from Employee e
Right join projectDetails p on p.empCode=e.empcode

go
--full join
SELECT e.empcode,e.empFname,e.empLname,p.Protitle,P.hourlyRate from Employee e
Full join projectDetails p on p.empCode=e.empcode

go
--cross join
SELECT e.empcode,e.empFname,e.empLname,p.Protitle,P.hourlyRate from Employee  e
cross join projectDetails  p

go
--self join
select * from employee
select distinct e1.EmpCode,e1.EmpFname,e1.EmpLname,e1.DeptCode from Employee  e1
join Employee e2 on (e1.DeptCode=e2.DeptCode) and(e1.EmpCode<>e2.EmpCode)
order by e1.EmpFname,e1.EmpLname

go

--outer+inner join
SELECT p.ProTitle As "Project Title",D.DeptName as "Department Name",e.EmpFname+' ' +e.EmpLname as "Employee Name" FROm Employee e 
join Department d on d.DeptCode=e.DeptCode
Left join ProjectDetails p on p.EmpCode=e.EmpCode
order by p.ProTitle

go
--complex Query + not in

SELECT p.ProTitle As "Project Title", e.EmpFname+' '+e.EmpLname as "Employee Name" , M.ManFname+' '+M.ManLname as "Project Manager",
P.HourlyRate as "Hourly Rate" FROm ProjectDetails p
JOIN Manager m on m.ManCode=p.ManCode
JoIN Employee e on e.EmpCode=p.EmpCode
where p.ProCode not in
(SELECT ProCode FROM ProjectDetails 
Group By ProTitle,ProBudget,ProCode
having count(EmpCode)>=4)

go
--corelated subquery
SELECT p1.ProCode,p1.ProTitle, p1.HourlyRate FROM ProjectDetails p1
Where p1.HourlyRate>
(SELECT avg(p2.HourlyRate) from ProjectDetails p2 where p1.ProCode<>p2.ProCode)


-- subquery with Exists 
select e.EmpCode,EmpFname from Employee e
where not exists (select * from ProjectDetails p where e.EmpCode=p.EmpCode)

go
--Different data type
Declare @string varchar(10)
set @string='December'
select @string  as "String Data Type"

Declare @int int
set @int=2022
select @int  as "Int Data Type"

Declare @Temporal datetime
set @Temporal='12-01-2022'
select @Temporal  as "Tempral Data Type"

Declare @Other varchar(max)
set @Other='December'
select @Other  as "Other Data Type"

Declare @decimal decimal
set @decimal=200.75
select @decimal  as "Decimal Data Type"

Declare @real real
set @real=200.75
select @real  as "Real Data Type"

Declare @float float
set @float=200.75
select @float  as "Float Data Type"

Declare @Char nchar
set @Char='Imran'
select @Char  as "Char Data Type"




go
--Covert, try convert, cast
DECLARE @StartDate datetime
Set @StartDate='01-December-2022 3:00PM'
SELECT CONVERT(varchar,@StartDate,100) as "Today's Date"

DECLARE @SDate datetime
Set @SDate='01-December-2022 3:00PM'
SELECT Try_CONVERT(varchar,@SDate,100) as "Today's Date"

DECLARE @EndDate datetime
Set @EndDate='01-December-2022 3:00PM'
SELECT cast(@EndDate as Time) as "Today's Time"

go
--diffrrent use of functions

SELECT LEN(' IMRAN ') as len_f
SELECT LTRIM(' SQL SERVER ')as ltrim_f
SELECT RTRIM(' SQL SERVER ') as Rtrim_f
SELECT LTRIM(RTRIM ('         SQL SERVER           ')) as ltrim_rtrim_f
SELECT PATINDEX('%v_r%', 'SQL SERVER') as patindex_f
SELECT PATINDEX('%R_N%', 'IMRAN') as patindex_f
SELECT CHARINDEX('SQL', '        SQL SERVER') as charindex_f
SELECT CHARINDEX('l', '(599) 555-2514')as charindex_f
SELECt REPLACE(RIGHT('(599) 555-2514',13), ')', '-')as replace_f
SELECT CONCAT('RUM TIME:',1.52,' Seconds') as concat_f
SELECT ROUND(26, +1)as round_f
SELECT ROUND(235.415, 2, 1) as round_f
SELECT REVERSE(EmpLname)as reverse_f FROM Employee ;
SELECT LOWER(EmpLname) AS LowercaseEmpLName FROM Employee;
SELECT Upper(EmpLname) AS uppercaseEmpLName FROM Employee;
SELECT NCHAR(65) AS NumberCodeToUnicode;
SELECT REPLICATE(EmpFname, 2) as Replicate_f FROM Employee;
SELECT RIGHT(EmpFname, 3) AS right_f FROM Employee;
SELECT Left(EmpFname, 2) AS left_f FROM Employee;
SELECT SPACE(10) as space_f;
SELECT SUBSTRING(ManFname, 1, 3) AS substring_f FROM Manager;
SELECT UNICODE(ManLname) AS UnicodeOfFirstChar FROM Manager;
SELECT Abs(-243.5) AS AbsNum;
SELECT ACOS(-0.8) as acos_f;
SELECT * FROM ProjectDetails WHERE HourlyRate>= (SELECT AVG(HourlyRate) FROM ProjectDetails);
SELECT CEILING(-20.5) AS CeilValue;
SELECT Floor(-5.5) AS FloorValue;
SELECT COUNT(ProCode) AS NumberOfProject FROM ProjectDetails group by ProCode;
SELECT MAX(HourlyRate) AS MaxHourypay FROM ProjectDetails;
SELECT MIN(HourlyRate) AS MinHourypay FROM ProjectDetails;
SELECT FLOOR(RAND()*(50-5)+5) AS rand_f;
SELECT SQUARE(25) as Square_f;
SELECT SQRT(10) as Sqrt_f;
SELECT ISNUMERIC(25) As isnumeric_f;
SELECT ISNUMERIC('Imran Ahmed')As isnumeric_f;
SELECT SUM(ProBudget) AS totalprobudget FROM ProjectDetails Group By ProCode with rollup;
SELECT GETDATE() as getdate_f;
SELECT GETUTCDATE() as getutcdate_f;
SELECT SYSDATETIME() as sysdatetime_f;
SELECT SYSDATETIMEOFFSET() as SYSDATETIMEOFFSET_f;
SELECT DAY('2022/12/01') AS DayOfMonth_f;
SELECT MONTH('2022/12/01') AS Month_f;
SELECT YEAR('2022/12/01') AS year_f;
SELECT DATEPART(day,'2022/12/01') as Datepart_f;
SELECT DATEADD(month, 1, '2022/12/01') AS DateAdd_f;
SELECT DATEDIFF(hour, '2022/12/01 15:00', '2022/12/01 19:00') AS DateDiff_f;
SELECT EOMONTH('2022/12/01') AS EOMonth_f;
SELECT ISDATE('2022/12/01') AS IsDate_f;
SELECT ISDATE('IMRAN') AS IsDate_f;
SELECT FIRST_VALUE(Protitle) OVER (PARTITION BY ProCode ORDER BY ProCode) as FirstValue FROM ProjectDetails;
SELECT LAST_VALUE(ProBudget) OVER (PARTITION BY ProTITLE ORDER BY ProCode) as LASTValue FROM ProjectDetails;
SELECT EmpFname, HourlyRate,LAG(HourlyRate) OVER(ORDER BY hourlyrate) as Lag_f FROM ProjectDetails p
join Employee e on e.EmpCode=p.EmpCode;
SELECT EmpFname, HourlyRate,Lead(HourlyRate) OVER(ORDER BY hourlyrate) as Lead_f FROM ProjectDetails p
join Employee e on e.EmpCode=p.EmpCode;

SELECT D.DeptName, EmpLName, HourlyRate,   
CUME_DIST () OVER (PARTITION BY DeptName ORDER BY HourlyRate) AS CumeDist,   
PERCENT_RANK() OVER (PARTITION BY DeptName ORDER BY hourlyRate ) AS PctRank  
FROM ProjectDetails p
join Employee e on e.EmpCode=p.EmpCode
join Department d on e.deptCode=d.deptCode;

SELECT DISTINCT DeptName AS DepartmentName ,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY p.hourlyRate)   OVER (PARTITION BY d.DeptName) AS PERCENTILE_CONT_f,
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY p.hourlyRate)   OVER (PARTITION BY d.DeptName) AS PERCENTILE_DISC  
FROM ProjectDetails p
join Employee e on e.EmpCode=p.EmpCode
join Department d on e.deptCode=d.deptCode;


go
--union
SELECT EmpCode, EmpFname,EmpLname FROm Employee
UNION
SELECT ManCode,ManFname,ManLname FROM Manager

go
--except
SELECT EmpCode, EmpFname,EmpLname FROm Employee
EXCEPT
SELECT ManCode,ManFname,ManLname FROM Manager

GO
--intersect
SELECT EmpCode, EmpFname,EmpLname FROm Employee
Intersect
SELECT ManCode,ManFname,ManLname FROM Manager

go
--rollup
SELECT ProTitle,EmpCode, count(*) as "Number of Employees" FROM ProjectDetails
GROUP bY ProTitle,EmpCode With ROllUP

go
--cube
SELECT ProTitle,EmpCode, count(*) as "Number of Employees" FROM ProjectDetails
GROUP bY ProTitle,EmpCode With Cube

GO
--grouping sets
SELECT ProTitle,EmpCode, count(*) as "Number of Employees" FROM ProjectDetails
GROUP bY grouping SETS( (ProTitle),(EmpCode),()) order by ProTitle,EmpCode

GO
--select into
SELECT * INTO EMPloyeeCOPY FROm Employee

GO

--Top, offset fetch

SELECT top 5 hourlyrate as "Top 5 Hourly Payment" FROM ProjectDetails
order by HourlyRate desc

SELECT hourlyrate as "Top 3 Hourly Payment" FROM ProjectDetails
order by HourlyRate desc
offset 0 rows fetch next 3 rows only;

---user
SELECT SESSION_USER as sessionUser;
SELECT SYSTEM_USER as systemUser;
SELECT USER_NAME() as userName;

go
sp_helpsrvrole  @srvrolename =sysadmin 
go
sp_helpsrvrole  @srvrolename =securityadmin
go
sp_helpsrvrole  @srvrolename =serveradmin 
go 





