SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION LoanSecurityList(@LoanNo Varchar(13))
RETURNS TABLE WITH ENCRYPTION
AS
RETURN 
(
	Select LoanNo, SlNo, IsNull([Type],-1) [Type], IsNull(Value,0) Value, 
			IsNull([Description],'') [Description]
	From tbl_Security
	Where LoanNo = @LoanNo
)
GO

-- Select * From dbo.LoanSecurityList('4100')
