
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter PROCEDURE LoanYearEndReconciliation
					@ProductionDate Datetime
With Encryption			
AS
BEGIN
	SET NOCOUNT ON;
	Declare @LoanList VarcharList;
	
	Insert into @LoanList(Value)
	Select LoanNo From tbl_Loan 
	Where Month(EMIStartDate) = Month(@ProductionDate)
		And LoanStatus = 2;
	
    Select B.LoanNo, B.AccountingOutstanding, B.OverduePrincipalOutstanding,
		   B.CalculatedOutstanding, B.ScheduledOutstanding, B.OutstandingDeviation
    From @LoanList A Left join dbo.OutstandingReconciliation(@ProductionDate) B
					 on A.Value = B.LoanNo
	Where B.OutstandingDeviation > 0
	Order By Case When IsNumeric(B.LoanNo) = 1 Then CONVERT(Integer, B.LoanNo) Else 0 End;
END
GO


-- Exec LoanYearEndReconciliation '4/30/2012'

-- Select * From dbo.OutstandingReconciliation('4/30/2012')