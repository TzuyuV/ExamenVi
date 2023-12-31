USE [PROYECTOESCUELA]
GO
/****** Object:  Table [dbo].[CARGAS]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CARGAS](
	[idCarga] [int] IDENTITY(1,1) NOT NULL,
	[calificacion] [int] NULL,
	[idUsuario] [int] NULL,
	[idMateria] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idCarga] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MATERIAS]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MATERIAS](
	[idMateria] [int] IDENTITY(1,1) NOT NULL,
	[nombreMateria] [varchar](14) NULL,
	[idUsuario] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMateria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ROLES]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ROLES](
	[idRol] [int] IDENTITY(1,1) NOT NULL,
	[nombreRol] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[idRol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[USUARIOS]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USUARIOS](
	[idUsuario] [int] IDENTITY(1,1) NOT NULL,
	[nombreUsuario] [varchar](42) NULL,
	[emailUsuario] [varchar](40) NULL,
	[contrasenaUsuario] [varchar](30) NULL,
	[idRol] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CARGAS] ADD  DEFAULT ((-1)) FOR [calificacion]
GO
ALTER TABLE [dbo].[CARGAS]  WITH CHECK ADD FOREIGN KEY([idMateria])
REFERENCES [dbo].[MATERIAS] ([idMateria])
GO
ALTER TABLE [dbo].[CARGAS]  WITH CHECK ADD FOREIGN KEY([idUsuario])
REFERENCES [dbo].[USUARIOS] ([idUsuario])
GO
ALTER TABLE [dbo].[MATERIAS]  WITH CHECK ADD FOREIGN KEY([idUsuario])
REFERENCES [dbo].[USUARIOS] ([idUsuario])
GO
ALTER TABLE [dbo].[USUARIOS]  WITH CHECK ADD FOREIGN KEY([idRol])
REFERENCES [dbo].[ROLES] ([idRol])
GO

INSERT INTO ROLES VALUES ('PROFESOR')
INSERT INTO ROLES VALUES ('ESTUDIANTE')

INSERT INTO USUARIOS VALUES ('Victor Aguilar', 'pruebacorreo@hotmail.com', '1234', 1)

INSERT INTO MATERIAS VALUES ('Español', 1)
INSERT INTO MATERIAS VALUES ('Matematicas', 1)
INSERT INTO MATERIAS VALUES ('Física', 1)
INSERT INTO MATERIAS VALUES ('Química', 1)
INSERT INTO MATERIAS VALUES ('Historia', 1)
/****** Object:  StoredProcedure [dbo].[ACTUALIZAR_CALIFICACION]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ACTUALIZAR_CALIFICACION]
@idUsuario INT,
@calif INT
AS
BEGIN
UPDATE CARGAS SET calificacion = @calif WHERE idUsuario=@idUsuario
END
GO
/****** Object:  StoredProcedure [dbo].[CARGAR_MATERIA]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CARGAR_MATERIA]
@idMateria INT,
@emailUsuario VARCHAR(40)
AS
BEGIN
	DECLARE @ID INT = (SELECT idUsuario FROM USUARIOS WHERE emailUsuario=@emailUsuario)
	INSERT INTO CARGAS VALUES(-1, @ID, @idMateria)
END
GO
/****** Object:  StoredProcedure [dbo].[CONSULTAR_MATERIAS_ESTUDIANTES]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONSULTAR_MATERIAS_ESTUDIANTES]
@emailUsuario VARCHAR(40)
AS
BEGIN
SELECT CARGAS.idCarga ,MATERIAS.nombreMateria, CARGAS.calificacion FROM MATERIAS INNER JOIN CARGAS 
ON MATERIAS.idMateria = CARGAS.idMateria INNER JOIN USUARIOS ON USUARIOS.idUsuario = CARGAS.idUsuario WHERE USUARIOS.emailUsuario = @emailUsuario
END
GO
/****** Object:  StoredProcedure [dbo].[CONSULTAR_MATERIAS_PROFESOR]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONSULTAR_MATERIAS_PROFESOR]
@emailUsuario VARCHAR(40)
AS
BEGIN
SELECT MATERIAS.idUsuario, MATERIAS.nombreMateria FROM USUARIOS INNER JOIN MATERIAS ON 
USUARIOS.idUsuario = MATERIAS.idUsuario WHERE emailUsuario= @emailUsuario
END
GO
/****** Object:  StoredProcedure [dbo].[CONTAR_APROVACION]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTAR_APROVACION]
@idUsuario INT,
@nombreMateria VARCHAR(14)
AS
BEGIN
 DECLARE @APROBADOS INT = (SELECT COUNT(CARGAS.calificacion) FROM CARGAS INNER JOIN MATERIAS ON CARGAS.idMateria = 
 MATERIAS.idMateria WHERE MATERIAS.idUsuario = @idUsuario AND MATERIAS.nombreMateria= @nombreMateria AND CARGAS.calificacion >=7)

  DECLARE @REPROBADOS INT = (SELECT COUNT(CARGAS.calificacion) FROM CARGAS INNER JOIN MATERIAS ON CARGAS.idMateria = 
 MATERIAS.idMateria WHERE MATERIAS.idUsuario = @idUsuario AND MATERIAS.nombreMateria= @nombreMateria AND CARGAS.calificacion<7)

 SELECT @APROBADOS[totalAprobados], @REPROBADOS[totalReprobados]

END
GO
/****** Object:  StoredProcedure [dbo].[ELIMINAR_CARGA]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ELIMINAR_CARGA]
@idCarga INT
AS
BEGIN
DELETE FROM CARGAS WHERE idCarga = @idCarga
END
GO
/****** Object:  StoredProcedure [dbo].[OBTENER_ESTUDIANTES]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OBTENER_ESTUDIANTES]
@nombreMateria VARCHAR(14)
AS
BEGIN
SELECT USUARIOS.idUsuario, USUARIOS.nombreUsuario, CARGAS.calificacion, MATERIAS.nombreMateria FROM USUARIOS INNER JOIN CARGAS 
ON USUARIOS.idUsuario = CARGAS.idUsuario INNER JOIN MATERIAS ON MATERIAS.idMateria = CARGAS.idMateria WHERE MATERIAS.nombreMateria = @nombreMateria
END
GO
/****** Object:  StoredProcedure [dbo].[REGISTRAR_USUARIO]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[REGISTRAR_USUARIO]
@nombreUsuario VARCHAR(42),
@emailUsuario VARCHAR(40),
@contrasenaUsuario VARCHAR(68),
@rol INT
AS
BEGIN
	INSERT INTO USUARIOS VALUES (@nombreUsuario, @emailUsuario, @contrasenaUsuario, @rol)
END
GO
/****** Object:  StoredProcedure [dbo].[VALIDARUSUARIO]    Script Date: 03/10/2023 08:00:27 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[VALIDARUSUARIO](
@email VARCHAR(40),
@contrasena VARCHAR(68)
)
AS
BEGIN
IF(EXISTS (SELECT * FROM USUARIOS WHERE emailUsuario=@email AND contrasenaUsuario=@contrasena))
	SELECT idUsuario, emailUsuario, idRol FROM USUARIOS WHERE emailUsuario=@email AND contrasenaUsuario=@contrasena
ELSE
	SELECT '0'
END
GO
