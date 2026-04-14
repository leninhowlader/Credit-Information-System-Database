SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter FUNCTION AccountingOutstanding(@LoanNo Varchar(13), @Date Datetime)
RETURNS TABLE With Encryption
AS
RETURN 
(
	Select A.GlName, Sum(DrAmount-CrAmount) Amount
	From BookKeeper.dbo.V_GL_SL A
	Where A.FYear = Year(@Date) And A.VchrDate <= @Date 
			And BookKeeper.dbo.LOANNUMBER(A.SlName) = @LoanNo
	Group By A.GlName, BookKeeper.dbo.LOANNUMBER(A.SlName)
	Having Sum(DrAmount-CrAmount) <> 0
)
GO


-- Select * From dbo.AccountingOutstanding('4100','03/13/2012')