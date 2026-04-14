SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter FUNCTION DelayedInterestCalculation (@PrdDate Datetime, @RateOfInterest Numeric(4,2))
RETURNS @List TABLE (LoanNo Varchar(13), ClientName Varchar(70), Product Varchar(30), Branch Varchar(20),
					 OverdueNumber Int, OverdueAmount Money, DelayedInterest Money) 
With Encryption
AS
Begin
Set @PrdDate = DateAdd(S, 86399,(select dateadd(m, datediff(m, 0, dateadd(m, 1, @PrdDate)), -1)));

Declare @ListOfSchedule VarcharList;

Insert into @ListOfSchedule
Select A.ScheduleId
From tbl_OverdueHistory A join (Select ScheduleId, Max([Date]) MaxDate
From tbl_OverdueHistory Where [Date] <= @PrdDate
Group By ScheduleId) B on A.ScheduleId = B.ScheduleId And A.[Date] = B.MaxDate
Where A.isPaid = 0;

Insert Into @List(LoanNo, ClientName, Product, Branch, OverdueNumber, OverdueAmount, DelayedInterest)
Select A.LoanNo, C.ClientName, C.GroupName Product, C.BranchName Branch, COUNT(*) OverdueNumber,
		Sum(B.PrincipalPart + B.InterestPart) OverdueAmount, (Sum(B.PrincipalPart) * @RateOfInterest * 0.01) DelayedInterest
From tbl_ChequeSchedule A join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
						  join viewClientInformation C on A.LoanNo = C.LoanNo 
Where B.SdlStatus = 4 And A.ScheduleId in (Select Value From @ListOfSchedule)
Group By A.LoanNo, C.ClientName, C.GroupName, C.BranchName
Having Sum(B.PrincipalPart) > 0;

Return 
End
GO


--- Select * From Dbo.DelayedInterestCalculation('4/30/2012', 2) order by 6