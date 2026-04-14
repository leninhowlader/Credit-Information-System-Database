SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION BundleList_BundleId(@BundleId Numeric(8,0))
RETURNS TABLE 
AS
RETURN 
(
	Select Distinct BundleId, DepositDate 
	From tbl_ChequeEncash 
	Where BundleId = @BundleId
)
GO


-- Select * From dbo.BundleList_BundleId(1)
