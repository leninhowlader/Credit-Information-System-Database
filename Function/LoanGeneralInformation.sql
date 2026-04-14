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
CREATE FUNCTION LoanGeneralInformation(@LoanNo Varchar(13))
RETURNS TABLE WITH ENCRYPTION
AS
RETURN 
(
Select LoanNo, IsNull(ProductID,'') ProductId, IsNull(LoanPurpose,-1) LoanPurpose, IsNull(ApprovalAuthority,'') ApprovalAuthority,
	   IsNull(MeetingNo,-1) MeetingNo, IsNull(CounselorID,'') CounselorId, ISNULL(SourceID,'') SourceId,
	   IsNull(BranchID, -1) BranchId, IsNull(ClientType,'') ClientType, IsNull(ClientID,'') ClientId,
	   IsNull(LoanTerm,-1) LoanTerm, IsNull(InterestRate,-1.0) InterestRate, IsNull(LoanStatus,-1) LoanStatus, 
	   IsNull(InterestRest,-1) InterestRest, IsNull(AppliID,'') AppliId, IsNull(ESectorCode,'') ESectorCode,
	   IsNull(InstallmentSize,-1) InstallmentSize, IsNull(PayInterval, -1) PayInterval, 
	   IsNull(EMIStartDate,'01/01/1900') EmiStartDate, IsNull(MortgageType,'') MortgageType
From tbl_Loan Where LoanNo = @LoanNo
)
GO


-- Select * From dbo.LoanGeneralInformation('4100')