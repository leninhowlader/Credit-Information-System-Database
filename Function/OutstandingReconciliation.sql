-- ================================================
-- Template generated from Template Explorer using:
-- Create Multi-Statement Function (New Menu).SQL
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
CREATE FUNCTION OutstandingReconciliation 
(@ProductionDate Datetime)
RETURNS @OutstandingReconciliation TABLE 
(LoanNo Varchar(13), AccountingOutstanding Money, OverduePrincipalOutstanding Money,
CalculatedOutstanding Money, ScheduledOutstanding Money, OutstandingDeviation Money)
With Encryption
AS
BEGIN
	Declare @FinancialYear Integer;
	Set @FinancialYear = Year(@ProductionDate);

	Declare @AccountingOutstanding Table(LoanNo Varchar(13), AccountingOutstanding Money);
	Declare @ScheduledOutstanding Table(LoanNo Varchar(13), ScheduledOutstanding Money);

	Insert into @AccountingOutstanding(LoanNo, AccountingOutstanding)
	Select bookkeeper.dbo.LOANNUMBER(A.SlName) LoanNo, Sum(A.DrAmount - A.CrAmount) as PrnOutstd 
	From bookkeeper.dbo.V_GL_SL A
	Where	(A.GlName = 'Home Mortgage Loan' or
			 A.GlName = 'Commercial Mortgage Loan' or
			 A.GlName = 'Project Mortgage Loan') and A.FYear = @FinancialYear 
			 and A.VchrDate <= @ProductionDate 
	Group by A.SlName
	Having Sum(A.DrAmount - A.CrAmount) <> 0;

	Insert into @ScheduledOutstanding(LoanNo, ScheduledOutstanding)
	Select A.LoanNo, Sum(B.PrincipalPart) ScheduledOutstanding
	From tbl_ChequeSchedule A join tbl_PaymentSchedule B
		 on A.ScheduleId = B.ScheduleId 
	Where B.DueDate > @ProductionDate
	Group By A.LoanNo;
	
	Insert into @OutstandingReconciliation(LoanNo, AccountingOutstanding, OverduePrincipalOutstanding,
						CalculatedOutstanding, ScheduledOutstanding, OutstandingDeviation)
	Select A.LoanNo, A.AccountingOutstanding, IsNull(C.PrincipalAmount,0) OverduePrincipalOutstanding, 
		A.AccountingOutstanding - IsNull(C.PrincipalAmount,0) CalculatedOutstanding,
		IsNull(B.ScheduledOutstanding,0) ScheduledOutstanding,
		A.AccountingOutstanding - IsNull(C.PrincipalAmount,0) - IsNull(B.ScheduledOutstanding,0) OutstandingDeviation
	From @AccountingOutstanding A left join @ScheduledOutstanding B on A.LoanNo = B.LoanNo
			left join OverdueList(@ProductionDate) C on B.LoanNo = C.LoanNo;
	
	RETURN 
END
GO

--- select * from dbo.OutstandingReconciliation('4/30/2012')