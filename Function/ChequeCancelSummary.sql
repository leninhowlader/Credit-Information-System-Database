SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create FUNCTION ChequeCancelSummary(@LoanNo Varchar(13))
RETURNS TABLE With Encryption
AS
RETURN 
(
	Select DateOfCancelation [Date], COUNT(*) [No. of Cheque]
	From tbl_ChequeCanceled
	Where ChequeId in (Select ChequeId 
			   From tbl_Cheque 
			   Where LoanNo = @LoanNo)
	Group By DateOfCancelation
)
GO

-- Select * From ChequeCancelSummary('4100')