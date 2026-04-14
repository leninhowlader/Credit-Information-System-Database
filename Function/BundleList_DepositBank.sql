SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION BundleList_DepositBank(@FromDate Datetime, @ToDate Datetime, @DepositBank Varchar(200))
RETURNS TABLE 
AS
RETURN 
(
	Select Distinct BundleId, DepositDate 
	From tbl_ChequeEncash 
	Where (DepositDate Between @FromDate And @ToDate) And (DepositBank = @DepositBank)
)
GO


-- Select * From dbo.BundleList_DepositBank('4/1/2012','4/30/2012','AB Bank - FC        # 605395026')
