SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION LoanAlleyList(@LoanNo Varchar(13))
RETURNS TABLE WITH ENCRYPTION
AS
RETURN 
(
	Select AllyID, [Role], isCompany
	From tbl_CoborrowerGuarantor
	Where LoanNo = @LoanNo
)
GO


-- Select * From dbo.LoanAlleyList('4100')