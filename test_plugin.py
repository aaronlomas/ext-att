"""
Test del plugin - verifica que las dependencias estan instaladas correctamente.
"""
import sys

print("=== Test de Plugin AutoCAD ===")
print("")

try:
    import pyautocad
    print("[OK] pyautocad instalado correctamente")
except ImportError:
    print("[FAIL] pyautocad no encontrado (ejecuta: pip install pyautocad comtypes)")

try:
    import openpyxl
    print("[OK] openpyxl instalado correctamente")
except ImportError:
    print("[FAIL] openpyxl no encontrado (ejecuta: pip install openpyxl)")

try:
    import pandas
    print("[OK] pandas instalado correctamente")
except ImportError:
    print("[FAIL] pandas no encontrado (ejecuta: pip install pandas)")

print(f"\n[OK] Python {sys.version}")
print("")
print("Dependencias correctas. Para usar el plugin:")
print("1. Abre AutoCAD")
print("2. Abre un dibujo nuevo (o existente)")
print("3. Ejecuta: APPLOAD")
print("4. Selecciona 'exportar_bloques.lsp' y 'seleccionar_bloques.lsp'")
print("5. Escribe 'EXPORTAR_BLOQUES' o 'EXT-ATT' en la linea de comandos")
print("")
print("Para usar las versiones en Python directamente:")
print("1. python exportar_bloques.py")
print("2. python convertir_csv_excel.py tu_archivo.csv")
print("================================")
