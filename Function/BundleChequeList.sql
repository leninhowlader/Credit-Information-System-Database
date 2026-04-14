
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
alter FUNCTION BundleChequeList(@BundleId Numeric(8,0))
RETURNS TABLE With Encryption
AS
RETURN 
(
Select C.LoanNo 'Loan No.', D.Purpose, B.ChqDate 'Date', B.Amount, B.ChequeNo 'Cheque No.', B.Bank,
	   IsNull(A.Remarks,'') 'Reason', A.ChequeId, E.BranchID 'Branch', F.GroupName 'Product', A.ChqReturn 'Return' 
From tbl_ChequeEncash A join tbl_Cheque B on A.ChequeId = B.ChequeId 
			join tbl_ChequeSchedule C on A.ChequeId = C.ChequeId
			join dmn_ChequePurpose D on D.Code = C.Purpose and A.BundleId = @BundleId 
			join tbl_Loan E on E.LoanNo = C.LoanNo
			join tbl_Product F on F.ID = E.ProductID
)
GO
