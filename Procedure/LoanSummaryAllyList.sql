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
CREATE Procedure LoanSummaryAllyList
				@LoanNo Varchar(13) 
With Encryption
AS
Begin
	Set NoCount On;
	Select A.AllyId, Case When A.isCompany = 0 Then (Select Name From tbl_Person Where PersonId = A.AllyId) 
	   Else (Select TradeName From tbl_Company Where CompanyID = A.AllyId) End Name,
	   B.[Role]
	From tbl_CoborrowerGuarantor A Join dmn_AllyRole B on A.[Role] = B.Code
	Where LoanNo = @LoanNo
End
GO


-- Select * from LoanSummaryAllyList('4100')