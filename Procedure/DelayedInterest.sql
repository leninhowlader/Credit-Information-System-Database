SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter PROCEDURE DelayedInterest 
	@DelayedInterest AmountList ReadOnly,
	@PostBy Varchar(15)
With Encryption
AS
BEGIN
	SET NOCOUNT ON;
	Declare @Branch Varchar(50), @Product Varchar(30), @VchrRef Numeric(5,0), @VchrType Int, @Category Varchar(50),
			@BrCode Int, @Remarks Varchar(Max), @RollbackQuery Varchar(Max), @QueryWithCommit Varchar(Max),
			@PostDate Datetime, @GenLedCode Varchar(5), @AccCode Varchar(9), @SumAmount Money,
			@SerialNumber Numeric(5,0), @Return Int;
	
	Set @Return = 0;
	
	Declare @Voucher Table(VchrRef Numeric(5,0), VchrType Int, Category Varchar(50), BrCode Int);
	Declare @VoucherDetail Table(VchrRef Numeric(5,0), SerialNo Numeric(5,0), AccCode Varchar(9), GenLedCode Varchar(5),
							DrAmount Money, CrAmount Money, LoanNo Varchar(13), Name Varchar(70));
	Declare @BasicData Table(LoanNo Varchar(13), Name Varchar(70), Branch Varchar(50), Product Varchar(30), Amount Money);
	
	Insert Into @BasicData(LoanNo, Name, Branch, Product, Amount)
	Select A.LoanNo, B.ClientName, B.BranchName, B.GroupName, A.Amount
	From @DelayedInterest A Join V_ClientName B on A.LoanNo = B.LoanNo
	Where B.GroupName in ('Home Mortgage Loan', 'Project Mortgage Loan', 'Commercial Mortgage Loan');
	
	Set @VchrType = 3;
	Set @Category = 'Delayed Interest';
	
	Declare DelayedInterest Cursor For Select Distinct Branch From @BasicData;
	Open DelayedInterest;
	Fetch Next From DelayedInterest Into @Branch;
	While @@Fetch_Status = 0
		Begin
		Set @VchrRef = (Select IsNull(Max(VchrRef),0) From @Voucher) + 1;
		Set @GenLedCode = '12095'; -- (Select GenLedCode From BookKeeper.dbo.GLDesc Where GlName = 'Additional Interest (A/R)');
		Insert Into @VoucherDetail(VchrRef, SerialNo, AccCode, GenLedCode, DrAmount, CrAmount, LoanNo, Name)
		Select @VchrRef, Row_Number() Over (Order By LoanNo) SerialNo, AccCode, @GenLedCode, Amount, 0, LoanNo, Name
		From @BasicData A Left join BookKeeper.dbo.SLDesc B on B.GenLedCode = @GenLedCode 
									And BookKeeper.dbo.LOANNUMBER(B.SlName) = A.LoanNo 
		Where A.Branch = @Branch;
		
		Set @GenLedCode = '30019';  --(Select GenLedCode From BookKeeper.dbo.GLDesc Where GlName = 'Additional Interest')
		Set @AccCode = '300190252'; --(Select AccCode From BookKeeper.dbo.SLDesc Where GenLedCode = '30019' and SlName = 'Additional Interest')
		Set @SumAmount = (Select Sum(DrAmount) From @VoucherDetail Where VchrRef = @VchrRef);
		Set @SerialNumber = (Select IsNull(Max(SerialNo),0) From @VoucherDetail Where VchrRef = @VchrRef) + 1;
		
		Insert Into @VoucherDetail(VchrRef, SerialNo, AccCode, GenLedCode, DrAmount, CrAmount)
		Values(@VchrRef, @SerialNumber, @AccCode, @GenLedCode, 0, @SumAmount);
		
		Set @BrCode = (Select BranchCode From tbl_Branch Where BranchName = @Branch);
				
		Insert Into @Voucher (VchrRef, VchrType, Category, BrCode)
		Values(@VchrRef, @VchrType, @Category, @BrCode);
		
		Fetch Next From DelayedInterest Into @Branch;
		End	
	Close DelayedInterest;
	Deallocate DelayedInterest;
	
	Set @PostDate = SYSDATETIME();
	Set @Remarks = '';
	Set @RollbackQuery = 'Delete From Fimisdb.dbo.system_DelayedInterest Where AccountingDate = ''' +
							 Convert(Varchar(30),@PostDate) + ''';';
	
	Set @QueryWithCommit = 'Update Fimisdb.dbo.system_DelayedInterest Set PostDate = Sysdatetime(), VoucherNumber = ''@VchrNo'' ' + 
							'Where AccountingDate = ''' + Convert(Varchar(30), @PostDate) + ''';';
	
	Set @VchrRef = (Select IsNull(Max(VchrRef),0) From BookKeeper.dbo.PendingVoucher);
	Set Xact_Abort On;
	Begin Tran t1
		Insert into BookKeeper.dbo.PendingVoucherDetail(VchrRef, SerialNo, AccCode, GenLedCode, DrAmount, CrAmount, LoanNo, Name)
		Select VchrRef + @VchrRef, SerialNo, AccCode, GenLedCode, DrAmount, CrAmount, LoanNo, Name
		From @VoucherDetail;
		
		Insert into BookKeeper.dbo.PendingVoucher(VchrRef, VchrType, Category, BrCode, PostDate, Remarks, RollbackQuery, QueryWithCommit)
		Select VchrRef + @VchrRef, VchrType, Category, BrCode, SysDatetime(), @Remarks, @RollbackQuery, @QueryWithCommit
		From @Voucher;
		
		Insert into tbl_DelayedInterest(LoanNo, PostDate, Amount)
		Select LoanNo, @PostDate, Amount
		From @BasicData
		Where Product in ('Home Mortgage Loan', 'Project Mortgage Loan', 'Commercial Mortgage Loan');
		
		Insert into system_DelayedInterest(AccountingDate, PostBy)
		Values(@PostDate, @PostBy);
		
		Set @Return = 1;
	Commit Tran t1
	Set Xact_Abort Off;
	
	Select @Return;
END
GO
