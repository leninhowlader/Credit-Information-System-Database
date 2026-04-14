SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
Create FUNCTION DelayedInterestPosted(@PrdDate Datetime)
RETURNS Bit With Encryption
AS
BEGIN
	DECLARE @Return Bit;
	
	If (Select Count(*) 
		From system_DelayedInterest 
		Where Year(AccountingDate) = Year(@PrdDate) And Month(AccountingDate) = Month(@PrdDate)) > 0
		Set @Return = 1;
	Else Set @Return = 0;
	
	RETURN @Return;

END
GO


--- Select dbo.DelayedInterestPosted('3/1/2012')
