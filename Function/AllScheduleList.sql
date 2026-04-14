
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
alter FUNCTION AllScheduleList(@LoanNo Varchar(13))
RETURNS @Table TABLE (InstlNo Int, 
					  Purpose Int,
					  DueDate Datetime, 
					  PrincipalPart Money,
					  InterestPart Money, 
					  [Status] Varchar(20),
					  ScheduleId Varchar(11),
					  ChequeId Varchar(11))
WITH ENCRYPTION
AS
BEGIN
	Insert into @Table(InstlNo, Purpose, DueDate, PrincipalPart, InterestPart, [Status], ScheduleId, ChequeId)
	Select A.InstlNo, A.Purpose, B.DueDate, B.PrincipalPart, 
			B.InterestPart, B.SdlStatus, B.ScheduleId, IsNull(A.ChequeId,'')
	From tbl_ChequeSchedule A join tbl_PaymentSchedule B on A.ScheduleId = B.ScheduleId
	Where A.LoanNo = @LoanNo; 
	RETURN 
END
GO

-- Select * From dbo.AllScheduleList('1981') Order by DueDate