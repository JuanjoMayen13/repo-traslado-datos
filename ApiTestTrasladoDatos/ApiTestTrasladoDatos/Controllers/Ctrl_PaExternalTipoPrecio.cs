using ApiTestTrasladoDatos.Models;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using OfficeOpenXml;
using System;
using System.Data.SqlClient;
using System.IO;

namespace ApiTestTrasladoDatos.Controllers
{
 
    [Route("api/[controller]")]
    [ApiController]
    public class Ctrl_PaExternalTipoPrecio : ControllerBase
    {
        private readonly string _connectionString;

        public Ctrl_PaExternalTipoPrecio(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("conexion");
        }

        [HttpPost]
        public IActionResult Post([FromForm] ExcelData request , [FromForm] string userName)
        {
            try
            {
                using (var package = new ExcelPackage(request.ArchivoExcel.OpenReadStream()))
                {
                    ExcelWorksheet worksheet = package.Workbook.Worksheets[request.NombreHojaExcel];

                    var rowCount = worksheet.Dimension.Rows;
                    var colCount = worksheet.Dimension.Columns;

                    using (var connection = new SqlConnection(_connectionString))
                    {
                        connection.Open();

                        for (int row = 2; row <= rowCount; row++)
                        {
                            var firstCell = worksheet.Cells[row, 1].Value;
                            if (firstCell != null && !string.IsNullOrWhiteSpace(firstCell.ToString()))
                            {
                                var tipoPrecio = Convert.ToInt32(worksheet.Cells[row, 1].Value);
                                var descripcion = worksheet.Cells[row, 2].Value.ToString();
                              
                                var fechaHora = DateTime.Now;

                                var parameters = new M_TipoPrecio
                                {
                                    pTipoPrecio = tipoPrecio,
                                    pDescripcion = descripcion,
                                    pUserName = userName,
                                    pFechaHora = fechaHora,
                                    pMensaje = "",
                                    pResultado = true
                                };

                                connection.Execute("PaExternalTipoPrecio", parameters, commandType: System.Data.CommandType.StoredProcedure);
                            }
                        }

                        connection.Close();
                    }
                }

                return Ok("Procedimiento almacenado ejecutado correctamente");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error al ejecutar procedimiento almacenado: {ex.Message}");
            }
        }

        public class ExcelData
        {
            public IFormFile ArchivoExcel { get; set; }
            public string NombreHojaExcel { get; set; }
        }
    }
}
