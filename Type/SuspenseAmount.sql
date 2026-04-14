USE [FIMISDB]
GO

/****** Object:  UserDefinedTableType [dbo].[SuspenseAmount]    Script Date: 03/27/2012 14:05:05 ******/
CREATE TYPE [dbo].[SuspenseAmount] AS TABLE(
	[ScheduleId] [varchar](11) NOT NULL,
	[Amount] [money] NULL,
	PRIMARY KEY CLUSTERED 
(
	[ScheduleId] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO


