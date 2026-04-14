-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter FUNCTION FindLiveLoanList_Rate(@Rate Numeric(4,2))
RETURNS TABLE 
With Encryption
AS
RETURN 
(
	Select LoanNo 
	From tbl_Loan 
	Where InterestRate = @Rate And LoanStatus Not In (5, 6, 7, 8)
)
GO
