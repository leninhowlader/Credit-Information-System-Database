SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter FUNCTION ReverseSuspenseAmount (@PrdDate Datetime)
RETURNS @List TABLE (LoanNo Varchar(13), ClientName Varchar(70), Product Varchar(30), Branch Varchar(20),
					 OverdueNumber Int, OverdueAmount Money, SuspenseAmount Money, ScheduleId Varchar(11)) 
With Encryption
AS
Begin
Set @PrdDate = DateAdd(S, 86399,(select dateadd(m, datediff(m, 0, dateadd(m, 1, @PrdDate)), -1)));

Declare @ScheduleList Table (ScheduleId Varchar(11), MaxDate Datetime);
Declare @BasicInfo Table (LoanNo Varchar(13), ClientName Varchar(70), Product Varchar(30), 
						  Branch Varchar(20), OverdueNumber Int, OverdueAmount Money);

Declare @ListOfSchedule VarcharList;
Insert into @ListOfSchedule
Select A.ScheduleId
From tbl_OverdueHistory A Join 
(Select ScheduleId, Max([Date]) MaxDate
From tbl_OverdueHistory Where [Date] < @PrdDate
Group By ScheduleId) B on A.ScheduleId = B.ScheduleId And A.[Date] = B.MaxDate
Where A.isPaid = 1 And A.isSuspended = 1;

Insert into @BasicInfo(LoanNo, ClientName, Product, Branch, OverdueNumber, OverdueAmount)
Select A.LoanNo, C.ClientName, C.GroupName, C.BranchName, Count(*) OverdueNumber, Sum(B.PrincipalPart) OverdueAmount
From tbl_ChequeSchedule A Join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
						  Join V_ClientName C on A.LoanNo = C.LoanNo
Where B.SdlStatus = 4
Group By A.LoanNo, C.ClientName, C.GroupName, C.BranchName;

Insert Into @List(LoanNo, ClientName, Product, Branch, OverdueNumber, OverdueAmount, SuspenseAmount, ScheduleId)
Select E.LoanNo, E.ClientName, E.Product, E.Branch, E.OverdueNumber, E.OverdueAmount, B.PrincipalPart, B.ScheduleId
From tbl_ChequeSchedule A Join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
						  Join @BasicInfo E on A.LoanNo = E.LoanNo
Where A.ScheduleId in (Select Value From @ListOfSchedule);

Return 
End
GO


--- Select * From Dbo.ReverseSuspenseAmount('5/31/2012')