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
Create Function Document(@PersonId Varchar(12))
Returns Table With Encryption
As
Return
(
Select PersonID, SLNo, IsNull(DocType,'') DocType, IsNull(DocNumber,'') DocNumber,
	   IsNull(IssueOrg,'') IssueOrg, IsNull(IssueDate,'01/01/1900') IssueDate,
	   IsNull(IssuingCountryCode,'') IssuingCountryCode
From tbl_Document
Where PersonId = @PersonId
)
GO

-- Select * from dbo.Document('')