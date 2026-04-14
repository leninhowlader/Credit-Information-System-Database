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
Alter FUNCTION InterestChargeList(@ProductionDate Datetime)
RETURNS @List TABLE 
([Loan Number] Varchar(13), [Client Name] Varchar(150), [Recv. Amount] Money,
[Product Name] Varchar(50), Branch Varchar(30), ScheduleId Varchar(11)
) With Encryption
AS
BEGIN

DECLARE @StartDate DATETIME, @EndDate DATETIME; 

SET @StartDate = (SELECT DATEADD(M,DATEDIFF(M,1,DATEADD(M,1,@ProductionDate)),0));
SET @EndDate = (SELECT DATEADD(M,DATEDIFF(M,0,DATEADD(M,2,@ProductionDate)),-1));

Insert into @List([Loan Number], [Client Name], [Recv. Amount], [Product Name], Branch, ScheduleId)
Select C.LoanNo 'Loan Number', D.ClientName 'Client Name', A.InterestPart 'Recv. Amount', 
	F.GroupName 'Product Name', E.BranchName 'Branch', A.ScheduleId
From tbl_PaymentSchedule A Join tbl_ChequeSchedule B on A.DueDate Between @StartDate And @EndDate
		And A.SdlStatus = 1 And A.ScheduleId = B.ScheduleId
	Join tbl_Loan C on C.LoanNo = B.LoanNo And C.LoanStatus in (1,2,3,4,5,9)
	Join V_ClientName D on D.LoanNo = C.LoanNo 
	Join tbl_Branch E on E.BranchCode = C.BranchID 
	Join tbl_Product F on F.ID = C.ProductID 
	
	RETURN 
END
GO