SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create FUNCTION LoanSummaryOverdueHistory(@LoanNo Varchar(13))
RETURNS @OverdueList Table(ScheduleId Varchar(11), [Date] Datetime, [Type] Varchar(2))
With Encryption
AS
BEGIN
	Declare @List Table(ScheduleId Varchar(11), MaxDate Datetime);
	Insert into @List(ScheduleId, MaxDate)
	Select ScheduleId, Max(Date)
	from tbl_OverdueHistory 
	Where ScheduleId in (Select ScheduleId 
						 From tbl_ChequeSchedule 
						 where LoanNo = @LoanNo) And isPaid = 0
	Group By ScheduleId;

	Insert Into @OverdueList(ScheduleId, [Date], [Type])
	Select A.ScheduleId, A.[Date], C.OverType  
	From tbl_OverdueHistory A join @List B 
				on A.ScheduleId = B.ScheduleId And A.[Date] = B.MaxDate
				join dmn_OverdueType C on A.OverdueType = C.Code;
	RETURN 
END
GO