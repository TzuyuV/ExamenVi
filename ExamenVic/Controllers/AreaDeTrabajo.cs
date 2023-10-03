using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using ExamenVic.Models.ViewModels;

namespace ExamenVic.Controllers
{
    public class AreaDeTrabajo : Controller
    {

        private static List<Materia> oMaterias = new List<Materia>();
        private static List<ListaEstudiantes> oEstudiantes =  new List<ListaEstudiantes>();
        private static List<MateriasProfesor> oListaProfe = new List<MateriasProfesor>();

        public IActionResult VistaEstudiante()
        {
            oMaterias = new List<Materia>();

            using (SqlConnection oconexion = new SqlConnection(CadenaDeConexion.cadena()))
            {
                SqlCommand cmd = new SqlCommand("CONSULTAR_MATERIAS_ESTUDIANTES", oconexion);
                cmd.Parameters.AddWithValue("emailUsuario", HttpContext.Session.GetString("Email"));
                cmd.CommandType = CommandType.StoredProcedure;
                oconexion.Open();
                cmd.ExecuteNonQuery();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        Materia mat = new Materia();

                        mat.idCarga = Convert.ToInt32(dr["idCarga"]);
                        mat.nombreMateria = dr["nombreMateria"].ToString();
                        mat.calificacion = Convert.ToInt32(dr["calificacion"]);

                        oMaterias.Add(mat);
                    }
                }

            }

            return View(oMaterias);
        }

        public IActionResult cargarMateria(int idMateria)
        {
            using (SqlConnection oconexion = new SqlConnection(CadenaDeConexion.cadena()))
            {
                SqlCommand cmd = new SqlCommand("CARGAR_MATERIA", oconexion);
                cmd.Parameters.AddWithValue("idMateria", idMateria);
                cmd.Parameters.AddWithValue("emailUsuario", HttpContext.Session.GetString("Email"));
                cmd.CommandType = CommandType.StoredProcedure;
                oconexion.Open();
                cmd.ExecuteNonQuery();
            }

            return RedirectToAction("VistaEstudiante", "AreaDeTrabajo");
        }

        public IActionResult EliminarCarga(int idCarga)
        {
            using (SqlConnection oconexion = new SqlConnection(CadenaDeConexion.cadena()))
            {
                SqlCommand cmd = new SqlCommand("ELIMINAR_CARGA", oconexion);
                cmd.Parameters.AddWithValue("idCarga", idCarga);
                cmd.CommandType = CommandType.StoredProcedure;
                oconexion.Open();
                cmd.ExecuteNonQuery();
            }

            return RedirectToAction("VistaEstudiante", "AreaDeTrabajo");
        }


        public IActionResult VistaProfesor()
        {
            oListaProfe = new List<MateriasProfesor>();

            using (SqlConnection oconexion = new SqlConnection(CadenaDeConexion.cadena()))
            {
                SqlCommand cmd = new SqlCommand("CONSULTAR_MATERIAS_PROFESOR", oconexion);
                cmd.Parameters.AddWithValue("emailUsuario", HttpContext.Session.GetString("Email"));
                cmd.CommandType = CommandType.StoredProcedure;
                oconexion.Open();
                cmd.ExecuteNonQuery();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        MateriasProfesor listamAT = new MateriasProfesor();

                        listamAT.idUsuario = Convert.ToInt32(dr["idUsuario"]);
                        listamAT.nombreMateria = dr["nombreMateria"].ToString();

                        oListaProfe.Add(listamAT);
                    }
                }

            }

            return View(oListaProfe);
        }

        public IActionResult ListaEstudiantes(string nombreMateria)
        {
            oEstudiantes = new List<ListaEstudiantes>();

            using (SqlConnection oconexion = new SqlConnection(CadenaDeConexion.cadena()))
            {
                SqlCommand cmd = new SqlCommand("OBTENER_ESTUDIANTES", oconexion);
                cmd.Parameters.AddWithValue("nombreMateria", nombreMateria);
                cmd.CommandType = CommandType.StoredProcedure;
                oconexion.Open();
                cmd.ExecuteNonQuery();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        ListaEstudiantes estudiante = new ListaEstudiantes();

                        estudiante.idUsuario = Convert.ToInt32(dr["idUsuario"]);
                        estudiante.nombreUsuario = dr["nombreUsuario"].ToString();
                        estudiante.calificacion = Convert.ToInt32(dr["calificacion"]);

                        oEstudiantes.Add(estudiante);
                    }
                }

            }

            return View(oEstudiantes);
        }


        public IActionResult ConteoAprobacion(int idUsuario, string nombreMateria)
        {
            using (SqlConnection oconexion = new SqlConnection(CadenaDeConexion.cadena()))
            {
                SqlCommand cmd = new SqlCommand("CONTAR_APROVACION", oconexion);
                cmd.Parameters.AddWithValue("idUsuario", idUsuario);
                cmd.Parameters.AddWithValue("nombreMateria", nombreMateria);
                cmd.CommandType = CommandType.StoredProcedure;
                oconexion.Open();
                cmd.ExecuteNonQuery();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        ViewBag.totalAprobados = Convert.ToInt32(dr["totalAprobados"]);
                        ViewBag.totalReprobados = Convert.ToInt32(dr["totalReprobados"]);
                    }
                }

            }

            return View();
        }

        public IActionResult GuardarCalificaciones(string[] idUsuario, int[] calif)
        {
            for (int i = 0; i < idUsuario.Length; i++)
            {
                using (SqlConnection oconexion = new SqlConnection(CadenaDeConexion.cadena()))
                {
                    SqlCommand cmd = new SqlCommand("ACTUALIZAR_CALIFICACION", oconexion);
                    cmd.Parameters.AddWithValue("idUsuario", idUsuario[i]);
                    cmd.Parameters.AddWithValue("calif", calif[i]);
                    cmd.CommandType = CommandType.StoredProcedure;
                    oconexion.Open();
                    cmd.ExecuteNonQuery();

                }


            }

                return RedirectToAction("VistaProfesor", "AreaDeTrabajo");
        }
    }
}
