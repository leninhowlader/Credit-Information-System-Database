SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION LoanSanctionAmount(@LoanNo Varchar(13))
RETURNS TABLE WITH ENCRYPTION
AS
RETURN 
(
	Select LoanNo, IsNull(Sum(Amount),0) Amount, IsNull(Min(SanctionDate),'01/01/1900') SanctionDate
	From tbl_Sanction
	Where LoanNo = @LoanNo
	Group By LoanNo
)
GO


-- Select * From LoanSanctionAmount('4100')