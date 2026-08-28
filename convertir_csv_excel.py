"""
Script para convertir archivos CSV a Excel.
"""
import sys
from core.excel_exporter import convertir_csv_a_excel_interactivo

if __name__ == "__main__":
    if len(sys.argv) > 1:
        convertir_csv_a_excel_interactivo(sys.argv[1])
    else:
        print("Falta la ruta del archivo CSV como argumento.")
