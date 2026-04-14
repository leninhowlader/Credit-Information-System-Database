SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


alter FUNCTION ChequeListForEncash(@Branch Varchar(50), @Product Varchar(30), @FromDate DateTime, @ToDate DateTime)
RETURNS @List Table ([Check] Bit, LoanNo Varchar(13), [Client Name] Varchar(120), [Inst No.] Int, Purpose Varchar(50),
					[Chq No.] Varchar(30), Bank Varchar(50), Amount Money, [Chq Date] Datetime, [Deposit Bank] Varchar(200),
					Branch Varchar(50), Product Varchar(30), [Cheque Id] Varchar(11), [A/C Number] Varchar(30), 
					[Cheque Branch] Varchar(50))
AS
BEGIN
	If @Branch = ''
		Begin
		If @Product = ''
			Begin
			Insert into @List([Check], LoanNo, [Client Name], [Inst No.], Purpose, [Chq No.], Bank, Amount, [Chq Date],
							  [Deposit Bank], Branch, Product, [Cheque Id], [A/C Number], [Cheque Branch])
			Select 0 'Check', B.LoanNo, D.ClientName 'Client Name', B.InstlNo 'Inst No.', C.Purpose, IsNull(A.ChequeNo,'') 'Chq No.',
					IsNull(A.Bank,'') Bank, A.Amount, A.ChqDate 'Chq Date', '' 'Deposit Bank', IsNull(F.BranchName,'') 'Branch', 
					G.GroupName 'Product', A.ChequeId 'Cheque Id', IsNull(A.BankAccNumber,'') 'A/C Number', IsNull(A.Branch,'') 'Cheque Branch'
			From tbl_Cheque A Join tbl_ChequeSchedule B on A.ChequeId = B.ChequeId
			Join dmn_ChequePurpose C on B.Purpose = C.Code
			Join V_ClientName D on B.LoanNo = D.LoanNo
			Join tbl_Loan E on B.LoanNo = E.LoanNo
			Join tbl_Branch F on E.BranchID = F.BranchCode
			Join tbl_Product G on G.ID = E.ProductID
			Where A.ChqStatus = 1 And (A.ChqDate between @FromDate and @ToDate);
			End
		Else
			Begin
			Insert into @List([Check], LoanNo, [Client Name], [Inst No.], Purpose, [Chq No.], Bank, Amount, [Chq Date],
							  [Deposit Bank], Branch, Product, [Cheque Id], [A/C Number], [Cheque Branch])
			Select 0 'Check', B.LoanNo, D.ClientName 'Client Name', B.InstlNo 'Inst No.', C.Purpose, IsNull(A.ChequeNo,'') 'Chq No.',
					IsNull(A.Bank,'') Bank, A.Amount, A.ChqDate 'Chq Date', '' 'Deposit Bank', IsNull(F.BranchName,'') 'Branch', 
					G.GroupName 'Product', A.ChequeId 'Cheque Id', IsNull(A.BankAccNumber,'') 'A/C Number', IsNull(A.Branch,'') 'Cheque Branch'
			From tbl_Cheque A Join tbl_ChequeSchedule B on A.ChequeId = B.ChequeId
			Join dmn_ChequePurpose C on B.Purpose = C.Code
			Join V_ClientName D on B.LoanNo = D.LoanNo
			Join tbl_Loan E on B.LoanNo = E.LoanNo
			Join tbl_Branch F on E.BranchID = F.BranchCode
			Join tbl_Product G on G.ID = E.ProductID
			Where A.ChqStatus = 1 And (A.ChqDate between @FromDate and @ToDate)
				  And G.GroupName = @Product;
			End
		End
	Else
		Begin
		If @Product = ''
			Begin
			Insert into @List([Check], LoanNo, [Client Name], [Inst No.], Purpose, [Chq No.], Bank, Amount, [Chq Date],
							  [Deposit Bank], Branch, Product, [Cheque Id], [A/C Number], [Cheque Branch])
			Select 0 'Check', B.LoanNo, D.ClientName 'Client Name', B.InstlNo 'Inst No.', C.Purpose, IsNull(A.ChequeNo,'') 'Chq No.',
					IsNull(A.Bank,'') Bank, A.Amount, A.ChqDate 'Chq Date', '' 'Deposit Bank', IsNull(F.BranchName,'') 'Branch', 
					G.GroupName 'Product', A.ChequeId 'Cheque Id', IsNull(A.BankAccNumber,'') 'A/C Number', IsNull(A.Branch,'') 'Cheque Branch'
			From tbl_Cheque A Join tbl_ChequeSchedule B on A.ChequeId = B.ChequeId
			Join dmn_ChequePurpose C on B.Purpose = C.Code
			Join V_ClientName D on B.LoanNo = D.LoanNo
			Join tbl_Loan E on B.LoanNo = E.LoanNo
			Join tbl_Branch F on E.BranchID = F.BranchCode
			Join tbl_Product G on G.ID = E.ProductID
			Where A.ChqStatus = 1 And (A.ChqDate between @FromDate and @ToDate)
				  And F.BranchName = @Branch;
			End
		Else
			Begin
			Insert into @List([Check], LoanNo, [Client Name], [Inst No.], Purpose, [Chq No.], Bank, Amount, [Chq Date],
							  [Deposit Bank], Branch, Product, [Cheque Id], [A/C Number], [Cheque Branch])
			Select 0 'Check', B.LoanNo, D.ClientName 'Client Name', B.InstlNo 'Inst No.', C.Purpose, IsNull(A.ChequeNo,'') 'Chq No.',
					IsNull(A.Bank,'') Bank, A.Amount, A.ChqDate 'Chq Date', '' 'Deposit Bank', IsNull(F.BranchName,'') 'Branch', 
					G.GroupName 'Product', A.ChequeId 'Cheque Id', IsNull(A.BankAccNumber,'') 'A/C Number', IsNull(A.Branch,'') 'Cheque Branch'
			From tbl_Cheque A Join tbl_ChequeSchedule B on A.ChequeId = B.ChequeId
			Join dmn_ChequePurpose C on B.Purpose = C.Code
			Join V_ClientName D on B.LoanNo = D.LoanNo
			Join tbl_Loan E on B.LoanNo = E.LoanNo
			Join tbl_Branch F on E.BranchID = F.BranchCode
			Join tbl_Product G on G.ID = E.ProductID
			Where A.ChqStatus = 1 And (A.ChqDate between @FromDate and @ToDate)
				  And F.BranchName = @Branch And G.GroupName = @Product;
			End
		End
		
		Declare @InstlNumber Int, @PurposeCode Int, @Purpose Varchar(50), @ChequeId Varchar(11), @Amount Money,
				@ChequeAmount Money;
		
		Declare ChequeCursor Cursor For
				Select [Cheque Id] From @List Group By [Cheque Id] Having Count(*) > 1;
		
		Open ChequeCursor;
		Fetch Next From ChequeCursor Into @ChequeId;
		While @@Fetch_Status = 0
			Begin
			Set @ChequeAmount = (Select Amount From tbl_Cheque Where ChequeId = @ChequeId);
			
			Declare InstallmentCursor Cursor For 
				Select A.[Inst No.], B.Code, A.Purpose 
				From @List A join dmn_ChequePurpose B On A.Purpose = B.Purpose
				Where A.[Cheque Id] = @ChequeId;
		
			Open InstallmentCursor;
			Fetch Next From InstallmentCursor Into @InstlNumber, @PurposeCode, @Purpose;
			While @@Fetch_Status = 0 
				Begin
				Set @Amount = (Select InterestPart + PrincipalPart 
								From tbl_PaymentSchedule
								Where ScheduleId = (Select ScheduleId From tbl_ChequeSchedule
													Where ChequeId = @ChequeId And Purpose = @PurposeCode
														  And InstlNo = @InstlNumber));
				
				If @Amount > @ChequeAmount Set @Amount = @ChequeAmount;
				
				Set @ChequeAmount -= @Amount;
				
				Update @List Set Amount = @Amount
				Where [Inst No.] = @InstlNumber and Purpose = @Purpose
					  And [Cheque Id] = @ChequeId;
				
				Fetch Next From InstallmentCursor Into @InstlNumber, @PurposeCode, @Purpose;
				End
			Close InstallmentCursor;
			Deallocate InstallmentCursor;
			
			Fetch Next From ChequeCursor Into @ChequeId;
			End
		Close ChequeCursor;
		Deallocate ChequeCursor;
	RETURN 
END
GO

-- Select * From dbo.ChequeListForEncash('Head Office', 'Home Mortgage Loan', '06/20/2012','06/20/2012') Order By Case When IsNumeric(LoanNo) = 1 Then Convert(Int,LoanNo) Else 0 End