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
Create Function Person(@PersonId Varchar(12))
Returns Table With Encryption
As
Return 
(
Select PersonID, IsNull(Title,'') Title, IsNull(Name,'') Name, IsNull(Gender,'') Gender, IsNull(FatherTitle,'') FatherTitle,
	   IsNull(FatherName,'') FatherName, IsNull(MotherTitle,'') MotherTitle, IsNull(MotherName,'') MotherName,
	   IsNull(SpouseTitle,'') SpouseTitle, IsNull(SpouseName,'') SpouseName, IsNull(DOB,'01/01/1900') DOB,
	   IsNull(POBDistrictCode,'') PobDistrictCode, IsNull(BirthCountryCode,'') BirthCountryCode, IsNull(NID,'') Nid,
	   IsNull(TIN,'') Tin, IsNull(Occupation,-1) Occupation, IsNull(PrmAddStreet,'') PrmAddStreet,
	   IsNull(PrmAddPostOffice,'') PrmAddPostOffice, IsNull(PrmAddPoliceStation,'') PrmAddPoliceStation, 
	   IsNull(PrmAddDistrictCode,'') PrmAddDistrictCode, IsNull(PrmAddPostalCode,'') PrmAddPostalCode,
	   IsNull(PrmAddCountryCode,'') PrmAddCountryCode, IsNull(PntAddStreet,'') PntAddStreet,
	   IsNull(PntAddPostOffice,'') PntAddPostOffice, IsNull(PntAddPoliceStation,'') PntAddPoliceStation,
	   IsNull(PntAddDistrictCode,'') PntAddDistrictCode, IsNull(PntAddPostalCode,'') PntAddPostalCode,
	   IsNull(PntAddCountryCode,'') PntAddCountryCode, IsNull(CellNo,'') CellNo, IsNull(PhoneNo,'') PhoneNo,
	   IsNull(EmailAddress,'') EmailAddress, IsNull(SectorType,-1) SectorType, IsNull(SectorCode,'') SectorCode, 
	   IsNull(Fax,'') Fax, IsNull(CIB,0) Cib
From tbl_Person
Where PersonId = @PersonId
)
GO


-- Select * from dbo.Person('143339')