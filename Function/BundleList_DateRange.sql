SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION BundleList_DateRange(@FromDate Datetime, @ToDate Datetime)
RETURNS TABLE 
AS
RETURN 
(
	Select Distinct BundleId, DepositDate 
	From tbl_ChequeEncash 
	Where DepositDate Between @FromDate And @ToDate
)
GO


-- Select * From dbo.BundleList_DateRange('4/1/2012','4/30/2012')
