-- ================================================
-- Template generated from Template Explorer using:
-- Create Multi-Statement Function (New Menu).SQL
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
Create Procedure LoanSummaryGeneralInfo
					@LoanNo Varchar(13)
With Encryption
AS
BEGIN
	Set NoCount On;
	-- Fill the table variable with the rows for your result set
	Declare @Table TABLE (ProductName Varchar(30), BranchName Varchar(30), Purpose Varchar(30), ClientId Varchar(12), 
							ClientName Varchar(100), Address Varchar(150), Term Int, [Status] Varchar(20),
							ExecutionDate Datetime, RemainingLoanTerm Int, InstallmentSize Money, Rate Numeric(4,2));
	Declare @ClientType Varchar;
	Set @ClientType = (Select ClientType From tbl_Loan Where LoanNo = @LoanNo);
	If @ClientType = 'P'
		Begin
		Insert into @Table(ProductName, BranchName, Purpose, ClientId, ClientName, [Address], Term, [Status], ExecutionDate,
						   RemainingLoanTerm, InstallmentSize, Rate)
		Select B.GroupName, D.BranchName, B.Name, A.ClientID, Ltrim(IsNull(E.Title,'') + ' ' + IsNull(E.Name,'')) ClientName,
				Replace(IsNull(E.PntAddStreet,'') + ', ' + IsNull(E.PntAddPostOffice,'') + ', ' +
				IsNull(E.PntAddPoliceStation,'') + ', ' + IsNull(E.PntAddDistrictCode,'') + ', ' +
				IsNull(E.PntAddPostalCode,'') + ', ' + IsNull(G.Country,''), ' ,', '') [Address],
				A.LoanTerm, F.StatusName, A.EMIStartDate, A.LoanTerm - DateDiff(M, A.EmiStartDate, sysdatetime()) RemainingLoanTerm, 
				A.InstallmentSize, A.InterestRate
		From tbl_Loan A Left Join tbl_Product B on A.ProductID = B.ID
						Left Join tbl_Branch D on A.BranchID = D.BranchCode
						Left Join tbl_Person E on A.ClientID = E.PersonID
						Left Join dmn_LoanStatus F on A.LoanStatus = F.StatusCode
						Left Join dmn_CountryCurrency G on E.PntAddCountryCode = G.CountryCode  
		Where LoanNo = @LoanNo
		End

	Else
		Begin
		Insert into @Table(ProductName, BranchName, Purpose, ClientId, ClientName, [Address], Term, [Status], ExecutionDate,
						   RemainingLoanTerm, InstallmentSize, Rate)
		Select B.GroupName, D.BranchName, B.Name, A.ClientID, Ltrim(IsNull(E.Title,'') + ' ' + IsNull(E.TradeName,'')) ClientName,
				Replace(IsNull(E.AddStreet,'') + ', ' + IsNull(E.AddPostalOffice,'') + ', ' +
				IsNull(E.AddPoliceStation,'') + ', ' + IsNull(E.AddDistrictCode,'') + ', ' +
				IsNull(E.AddPostalCode,'') + ', ' + IsNull(G.Country,''), ' ,', '') [Address],
				A.LoanTerm, F.StatusName, A.EMIStartDate, A.LoanTerm - DateDiff(M, A.EmiStartDate, sysdatetime()) RemainingLoanTerm, 
				A.InstallmentSize, A.InterestRate
		From tbl_Loan A Left Join tbl_Product B on A.ProductID = B.ID 
						Left Join tbl_Branch D on A.BranchID = D.BranchCode
						Left Join tbl_Company E on A.ClientID = E.CompanyID
						Left Join dmn_LoanStatus F on A.LoanStatus = F.StatusCode
						Left Join dmn_CountryCurrency G on E.AddCountryCode = G.CountryCode 
		Where LoanNo = @LoanNo
		End
	Select * From @Table
END
GO

-- Select * From LoanAlleyList('4100')