Alter Procedure NoCheque_Contact
					@ListOfLoan VarcharList ReadOnly
With Encryption
As
Begin
Set nocount on;
Declare @ContactList Table(LoanNo Varchar(13), ClientName Varchar(150), [Role] Varchar(40), 
						   PhoneNo Varchar(20));
Declare @ClientList Table(LoanNo Varchar(13), CustomerId Varchar(12), ClientType Varchar, 
						  Name Varchar(150), [Role] Varchar(40));

Insert Into @ClientList(LoanNo, CustomerId, ClientType, Name, [Role])
Select LoanNo [Loan No], CustomerId [Customer Id], C_Type, Name, [Role]
From V_CustomerLoanRelation
Where LoanNo in (Select [Value] From @ListOfLoan);

Insert Into @ContactList(LoanNo, ClientName, [Role], PhoneNo)
Select A.LoanNo, A.Name, A.[Role], B.CellNo
From @ClientList A join tbl_Person B on A.ClientType = 'P' And A.CustomerId = B.PersonID
Union
Select A.LoanNo, A.Name, A.[Role], B.PhoneNumber1
From @ClientList A join tbl_Company B on A.ClientType = 'C' And A.CustomerId = B.CompanyID;

Select LoanNo, ClientName, [Role], PhoneNo PhoneNumber From @ContactList;
End