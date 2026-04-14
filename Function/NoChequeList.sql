-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create FUNCTION NoChequeList(@StartDate Datetime, @EndDate Datetime)
RETURNS TABLE 
AS
RETURN 
(
Select 1 [Checked], C.LoanNo [Loan No], D.ClientName [Client Name], A.DueDate [Due Date], A.InterestPart + A.PrincipalPart Amount, 
			D.BranchName Branch, D.GroupName Product, A.ScheduleId, A.SdlStatus
From tbl_PaymentSchedule A join tbl_ChequeSchedule B on A.ScheduleId = B.ScheduleId And ChequeId Is Null
							join tbl_Loan C on B.LoanNo = C.LoanNo 
							join V_ClientName D on C.LoanNo = D.LoanNo 
Where A.SdlStatus In (1, 2) And (A.DueDate between @StartDate and @EndDate)
)
GO
