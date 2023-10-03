using ExamenVic.Models;
using ExamenVic.Models.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Diagnostics;
using System.Text;
using System.Web;
using ExamenVic.Models.ViewModels;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;

namespace ExamenVic.Controllers
{
    public class HomeController : Controller
    {
        private static List<Usuario> oUsuario = new List<Usuario>();
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public async Task<IActionResult> Index()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Index(string email, string contrasena)
        {
            string idRol;
            using (SqlConnection cn = new SqlConnection(CadenaDeConexion.cadena()))
            {
                SqlCommand cmd = new SqlCommand("VALIDARUSUARIO", cn);
                cmd.Parameters.AddWithValue("email", email);
                cmd.Parameters.AddWithValue("contrasena", contrasena);
                cmd.CommandType = CommandType.StoredProcedure;

                cn.Open();

                idRol = cmd.ExecuteScalar().ToString();

                if (idRol != "0")
                {
                    var claims = new List<Claim>
                        {
                            new Claim(ClaimTypes.Email, email),
                            new Claim("email", email)
                        };

                    claims.Add(new Claim(ClaimTypes.Role, idRol));

                    var claimIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

                    await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(claimIdentity));

                    HttpContext.Session.SetString("Email", email);

                    if (idRol == "1")
                    {
                        return RedirectToAction("VistaProfesor", "AreaDeTrabajo");
                    }
                    else{
                        return RedirectToAction("VistaEstudiante", "AreaDeTrabajo");
                    }
                    
                }
                else
                {
                    ViewData["Mensaje"] = "Usuario no encontrado";
                    return View();
                }

            }
        }

        public IActionResult Registrarse()
        {
            return View();
        }


        [HttpPost]
        public IActionResult Registrarse(string nombre, string email, string contrasena, string contrasena2, int rolUsuario)
        {
            if (contrasena == contrasena2)
            {
                    using (SqlConnection oconexion = new SqlConnection(CadenaDeConexion.cadena()))
                    {
                        SqlCommand cmd = new SqlCommand("REGISTRAR_USUARIO", oconexion);
                        cmd.Parameters.AddWithValue("nombreUsuario", nombre);
                        cmd.Parameters.AddWithValue("emailUsuario", email);
                        cmd.Parameters.AddWithValue("contrasenaUsuario", contrasena);
                        cmd.Parameters.AddWithValue("rol", rolUsuario);
                        cmd.CommandType = CommandType.StoredProcedure;
                        oconexion.Open();

                        cmd.ExecuteNonQuery();

                    }
            }

            else
            {
                ViewData["Mensaje"] = "Las contraseñas no coinciden";
                return View();
            }

            return RedirectToAction("Index", "Home");
        }


        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}