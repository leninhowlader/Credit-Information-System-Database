SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Procedure LoanSummarySecurityList
				@LoanNo Varchar(13)
With Encryption
AS
Begin
Set NoCount On;
Select B.Name, Sum(A.Value * B.ValuePercent) Amount
From tbl_Security A join dmn_Security B on A.[Type] = B.Code
Where LoanNo = @LoanNo
Group by B.Name
End
