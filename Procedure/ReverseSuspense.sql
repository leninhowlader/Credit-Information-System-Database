SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Alter PROCEDURE ReverseSuspense
					@SuspenseAmountList SuspenseAmount ReadOnly
With Encryption
AS
BEGIN
	SET NOCOUNT ON;
	Declare @Branch Varchar(50), @Product Varchar(30), @ScheduleId Varchar(11), @GenLedCode Varchar(5), 
			@AccCode Varchar(9), @AmountSum Money, @VchrRef Numeric(5,0), @SerialNo Numeric(5,0), 
			@VchrType Int, @Category Varchar(50), @BrCode Int, @Remarks Varchar(Max), 
			@RollbackQuery Varchar(Max), @QueryWithCommit Varchar(Max), @ScheduleIdList Varchar(Max), @Return Int;
	
	Set @Return = 0;
	
	Declare @Voucher Table(VchrRef Numeric(5,0), VchrType Int, Category Varchar(50), BrCode Int, PostDate Datetime,
						   Remarks Varchar(Max), RollbackQuery Varchar(Max), QueryWithCommit Varchar(Max));
	
	Declare @VoucherDetail Table(VchrRef Numeric(5,0), SerialNo Numeric(5,0), AccCode Varchar(9), GenLedCode Varchar(5),
								 DrAmount Money, CrAmount Money, LoanNo Varchar(13), Name Varchar(70));
    
    Declare @tmpList Table(LoanNo Varchar(13), Name Varchar(70), Branch Varchar(50), Product Varchar(30),
						   SuspenseAmount Money, ScheduleId Varchar(11));
    
    
    Insert Into @tmpList(LoanNo, Name, Branch, Product, SuspenseAmount, ScheduleId)
    Select A.LoanNo, C.ClientName, C.BranchName, C.GroupName, B.Amount, B.ScheduleId 
    From tbl_ChequeSchedule A join @SuspenseAmountList B on A.ScheduleId = B.ScheduleId 
								join V_ClientName C on A.LoanNo = C.LoanNo;
	
	Set @VchrType = 3;
	Set @Category = 'Interest Suspense Reverse';
	Set @Remarks = '';
	Set @RollbackQuery = '';
	Set @QueryWithCommit = '';
	
	Declare VchrCursor Cursor For Select Distinct Branch, Product From @tmpList;
	Open VchrCursor;
	Fetch Next From VchrCursor Into @Branch, @Product;
	While @@Fetch_Status = 0
		Begin
		Set @VchrRef = (Select IsNull(Max(VchrRef),0) From @Voucher) + 1;
		
		If @Product = 'Home Mortgage Loan'
			Begin
			Set @GenLedCode = '22070'; -- (Select GenLedCode From BookKeeper.dbo.GLDesc Where GlName = 'Provision for Int. Loss HML (A/P)');
			
			Insert Into @VoucherDetail(VchrRef, SerialNo, AccCode, GenLedCode, DrAmount, CrAmount, LoanNo, Name)
			Select @VchrRef, ROW_NUMBER() Over (Order by A.LoanNo), B.AccCode, @GenLedCode, 
				   A.SuspenseAmount, 0, A.LoanNo, A.Name  
			From @tmpList A Left Join BookKeeper.dbo.SLDesc B on B.GenLedCode = @GenLedCode 
											And BookKeeper.dbo.LOANNUMBER(B.SlName) = A.LoanNo
			Where A.Branch = @Branch And A.Product = @Product; 
			
			Set @GenLedCode = '40073'; -- (Select GenLedCode From BookKeeper.dbo.GLDesc Where GlName = 'Interest Suspense ');
			Set @AccCode = '400730001'; -- (Select AccCode From BookKeeper.dbo.SLDesc Where GenLedCode = '40073' And SlName = 'HML');
			Set @SerialNo = (Select IsNull(Max(SerialNo),0) From @VoucherDetail Where VchrRef = @VchrRef) + 1;
			Set @AmountSum = (Select Sum(DrAmount) From @VoucherDetail Where VchrRef = @VchrRef);
			
			Insert Into @VoucherDetail(VchrRef, SerialNo, AccCode, GenLedCode, DrAmount, CrAmount)
			Values (@VchrRef, @SerialNo, @AccCode, @GenLedCode, 0, @AmountSum);
			End
		Else If @Product = 'Project Mortgage Loan' or @Product = 'Commercial Mortgage Loan'
			Begin
			Set @GenLedCode = '22071'; -- (Select GenLedCode From BookKeeper.dbo.GLDesc Where GlName = 'Provision for Int. Loss PML (A/P)');
			
			Insert Into @VoucherDetail(VchrRef, SerialNo, AccCode, GenLedCode, DrAmount, CrAmount, LoanNo, Name)
			Select @VchrRef, ROW_NUMBER() Over (Order by A.LoanNo), B.AccCode, @GenLedCode, 
				   A.SuspenseAmount, 0, A.LoanNo, A.Name  
			From @tmpList A Left Join BookKeeper.dbo.SLDesc B on B.GenLedCode = @GenLedCode 
											And BookKeeper.dbo.LOANNUMBER(B.SlName) = A.LoanNo
			Where A.Branch = @Branch And A.Product = @Product; 
			
			Set @GenLedCode = '40073'; -- (Select GenLedCode From BookKeeper.dbo.GLDesc Where GlName = 'Interest Suspense');
			Set @AccCode = '400730002'; -- (Select AccCode From BookKeeper.dbo.SLDesc Where GenLedCode = '40073' And SlName = 'PML');
			Set @SerialNo = (Select IsNull(Max(SerialNo),0) From @VoucherDetail Where VchrRef = @VchrRef) + 1;
			Set @AmountSum = (Select Sum(DrAmount) From @VoucherDetail Where VchrRef = @VchrRef);
			
			Insert Into @VoucherDetail(VchrRef, SerialNo, AccCode, GenLedCode, DrAmount, CrAmount)
			Values (@VchrRef, @SerialNo, @AccCode, @GenLedCode, 0, @AmountSum);
			End
		
		Set @ScheduleIdList = '('''
		Declare RollbackCursor Cursor For Select ScheduleId From @tmpList 
											Where Product = @Product And Branch = @Branch;
		Open RollbackCursor;
		Fetch Next From RollbackCursor Into @ScheduleId;
		While @@Fetch_Status=0
			Begin
			Set @ScheduleIdList += @ScheduleId + ''', '''; 
			Fetch Next From RollbackCursor Into @ScheduleId;
			End
		Close RollbackCursor;
		Deallocate RollbackCursor;
		
		Set @RollbackQuery = 'Declare @List Table (ScheduleId Varchar(11), PostDate Datetime); ' +
							 'Insert Into @List(ScheduleId, PostDate) Select ScheduleId, Max(PostDate) ' +
							 'From Fimisdb.dbo.tbl_OverdueHistory Where isPaid = 1 And ScheduleId in ' +
							 Right(@ScheduleIdList, Len(@ScheduleIdList) - 3) + 'Group By ScheduleId; ' +
							 'Merge Into Fimisdb.dbo.tbl_OverdueHistory A Using @List B ' +
							 'On (A.ScheduleId = B.ScheduleId And A.[Date] = B.PostDate) ' +
							 'When Matched Then Update Set A.isSuspended = 0;';
							 
		Set @BrCode = (Select BranchCode From tbl_Branch Where BranchName = @Branch);
		
		Insert Into @Voucher(VchrRef, VchrType, Category, BrCode, Remarks, RollbackQuery, QueryWithCommit)
		Values (@VchrRef, @VchrType, @Category, @BrCode, @Remarks, @RollbackQuery, @QueryWithCommit);
		
		Fetch Next From VchrCursor Into @Branch, @Product;
		End
		
	Close VchrCursor;
	Deallocate VchrCursor;
	
	Declare @LastVoucherNumber Numeric(5,0);
	Set @LastVoucherNumber = (Select IsNull(Max(VchrRef),0) From BookKeeper.dbo.PendingVoucher);
	
	Declare @ScheduleList Table (ScheduleId Varchar(11), PostDate Datetime);
	
	Insert into @ScheduleList (ScheduleId, PostDate)
	Select ScheduleId, Max([Date])
	From tbl_OverdueHistory 
	Where isPaid = 1 And ScheduleId in (Select ScheduleId From @SuspenseAmountList)
		And isSuspended = 1
	Group By ScheduleId;
	
	Set Xact_abort On;
	Begin Tran InterestSuspense
		Insert into BookKeeper.dbo.PendingVoucher(VchrRef, VchrType, Category, BrCode, PostDate, Remarks, RollbackQuery, QueryWithCommit)
		Select VchrRef + @LastVoucherNumber, VchrType, Category, BrCode, Sysdatetime(), Remarks, RollbackQuery, QueryWithCommit 
		From @Voucher;
		
		Insert into BookKeeper.dbo.PendingVoucherDetail(VchrRef, SerialNo, AccCode, GenLedCode, DrAmount, CrAmount, LoanNo, Name)
		Select VchrRef + @LastVoucherNumber, SerialNo, AccCode, GenLedCode, DrAmount, CrAmount, LoanNo, Name
		From @VoucherDetail;
		
		Merge Into tbl_OverdueHistory A
		Using @ScheduleList B
		On (A.ScheduleId = B.ScheduleId And A.[Date] = B.PostDate)
		When Matched Then Update Set A.isSuspended = 0;
		
		Set @Return = 1;
	Commit Tran InterestSuspense
	Set Xact_abort Off;
	
	Select @Return;
END
GO
