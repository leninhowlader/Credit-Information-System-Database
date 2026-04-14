SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter Procedure LoanSummaryAccountingOutstanding
					@LoanNo Varchar(13), 
					@Date Datetime
With Encryption
AS
Begin
	Set NoCount On;
	Select A.GlName, Sum(DrAmount-CrAmount) Amount
	From BookKeeper.dbo.V_GL_SL A
	Where A.FYear = Year(@Date) And A.VchrDate <= @Date 
			And BookKeeper.dbo.LOANNUMBER(A.SlName) = @LoanNo
			And A.AccCode in (Select AccCode 
							  From BookKeeper.dbo.SLDesc 
							  Where AccCode Like '12%' Or
									AccCode Like '21%' Or
									GenLedCode = '40081')
	Group By A.GlName, BookKeeper.dbo.LOANNUMBER(A.SlName)
	Having Sum(DrAmount-CrAmount) <> 0;
End
GO


-- Exec LoanSummaryAccountingOutstanding '3302','03/13/2012'