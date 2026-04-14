SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION OverdueList(@ProductionDate Datetime)
RETURNS 
@OverdueList TABLE 
(LoanNo Varchar(13), NoOfOverdue Integer, InterestAmount Money, PrincipalAmount Money, TotalOverdueAmount Money)
With Encryption
AS
BEGIN
	Declare @tmpList Table (ScheduleId Varchar(11), MaxDate Datetime);
	Declare @ScheduleIdList Table (ScheduleId Varchar(11));

	Insert into @tmpList(ScheduleId, MaxDate)
	Select ScheduleId, Max([Date]) MaxDate 
	From tbl_OverdueHistory
	Where [Date] <= @ProductionDate
	Group By ScheduleId;

	Insert Into @ScheduleIdList(ScheduleId)
	Select A.ScheduleId
	From tbl_OverdueHistory A join @tmpList B 
			on A.ScheduleId = B.ScheduleId And A.[Date] = B.MaxDate
	Where A.isPaid = 0

	Insert into @OverdueList(LoanNo, NoOfOverdue, InterestAmount, PrincipalAmount, TotalOverdueAmount)
	Select B.LoanNo, Count(*) NoOfOverdue, Sum(A.InterestPart) OverdueInterestPart, 
		   Sum(A.PrincipalPart) OverduePrincipalPart, 
		   Sum(A.InterestPart + A.PrincipalPart) OverdueAmount
	From tbl_PaymentSchedule A join tbl_ChequeSchedule B on A.ScheduleId = B.ScheduleId 
	Where A.ScheduleId in (Select ScheduleId From @ScheduleIdList)
	Group By B.LoanNo;
	
	RETURN 
END
GO