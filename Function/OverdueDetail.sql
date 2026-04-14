SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter FUNCTION OverdueDetail(@ProductionDate Datetime, @LoanNo Varchar(13))
RETURNS 
@OverdueList TABLE 
(OverdueDate Datetime, [State] Varchar(50), OverdueType Varchar(20), Amount Money)
With Encryption
AS
BEGIN
	Declare @tmpList Table (ScheduleId Varchar(11), MaxDate Datetime);
	Declare @ScheduleIdList Table (ScheduleId Varchar(11), OverdueType Varchar(50));

	Insert into @tmpList(ScheduleId, MaxDate)
	Select ScheduleId, Max([Date]) MaxDate 
	From tbl_OverdueHistory
	Where [Date] <= @ProductionDate 
	and ScheduleId in (Select ScheduleId From tbl_ChequeSchedule Where LoanNo = @LoanNo)
	Group By ScheduleId;

	Insert Into @ScheduleIdList(ScheduleId, OverdueType)
	Select A.ScheduleId, C.OverType
	From tbl_OverdueHistory A join @tmpList B 
			on A.ScheduleId = B.ScheduleId And A.[Date] = B.MaxDate
			join dmn_OverdueType C on A.OverdueType = C.Code
	Where A.isPaid = 0;

	Insert into @OverdueList(OverdueDate, [State], OverdueType, Amount)
	Select A.DueDate, D.Purpose, C.OverdueType, A.InterestPart + A.PrincipalPart Amount
	From tbl_PaymentSchedule A join tbl_ChequeSchedule B on A.ScheduleId = B.ScheduleId
							join @ScheduleIdList C on B.ScheduleId = C.ScheduleId
							join dmn_ChequePurpose D on B.Purpose = D.Code;	
	RETURN 
END
GO