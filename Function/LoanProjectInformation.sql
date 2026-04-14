SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION LoanProjectInformation(@LoanNo Varchar(13))
RETURNS TABLE WITH ENCRYPTION
AS
RETURN 
(
	Select LoanNo, IsNull(DeveloperName,'') DeveloperName, IsNull(ProjectName,'') ProjectName
	From tbl_Project
	Where LoanNo = @LoanNo
)
GO

-- Select * From dbo.LoanProjectInformation('4100')
