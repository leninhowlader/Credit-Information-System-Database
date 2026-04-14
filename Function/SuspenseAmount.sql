SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter FUNCTION SuspenseAmount (@PrdDate Datetime)
RETURNS @List TABLE (LoanNo Varchar(13), ClientName Varchar(70), Product Varchar(30), Branch Varchar(20),
					 OverdueNumber Int, OverdueAmount Money, SuspenseAmount Money, ScheduleId Varchar(11)) 
With Encryption
AS
Begin
Set @PrdDate = DateAdd(S, 86399,(select dateadd(m, datediff(m, 0, dateadd(m, 1, @PrdDate)), -1)));

Declare @BasicInfo Table (LoanNo Varchar(13), ClientName Varchar(70), Product Varchar(30), 
						  Branch Varchar(20), OverdueNumber Int, OverdueAmount Money);

Insert into @BasicInfo(LoanNo, ClientName, Product, Branch, OverdueNumber, OverdueAmount)
Select A.LoanNo, C.ClientName, C.GroupName, C.BranchName, Count(*) OverdueNumber, Sum(B.PrincipalPart) OverdueAmount
From tbl_ChequeSchedule A Join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
						  Join V_ClientName C on A.LoanNo = C.LoanNo
Where B.SdlStatus = 4
Group By A.LoanNo, C.ClientName, C.GroupName, C.BranchName;

Declare @ListOfSchedule VarcharList;
Insert into @ListOfSchedule
Select A.ScheduleId
From tbl_OverdueHistory A join (Select ScheduleId, Max([Date]) MaxDate
From tbl_OverdueHistory Where [Date] <= @PrdDate
Group By ScheduleId) B on A.ScheduleId = B.ScheduleId And A.[Date] = B.MaxDate
Where isSuspended = 1 And A.isPaid = 0;

Insert Into @List(LoanNo, ClientName, Product, Branch, OverdueNumber, OverdueAmount, SuspenseAmount, ScheduleId)
Select E.LoanNo, E.ClientName, E.Product, E.Branch, E.OverdueNumber, E.OverdueAmount, B.PrincipalPart, B.ScheduleId
From tbl_ChequeSchedule A Join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
						  Join @BasicInfo E on A.LoanNo = E.LoanNo
Where B.ScheduleId in (Select value From @ListOfSchedule);
Return 
End
GO


--- Select * From Dbo.SuspenseAmount('4/30/2012')