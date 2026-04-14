USE [FIMISDB]
GO

/****** Object:  UserDefinedTableType [dbo].[PaymentList]    Script Date: 03/27/2012 14:01:21 ******/
CREATE TYPE [dbo].[PaymentList] AS TABLE(
	[Purpose] [varchar](50) NULL,
	[ScheduleId] [varchar](11) NULL,
	[Amount] [money] NULL
)
GO


