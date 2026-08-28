"""
Módulo para la interacción con AutoCAD usando pyautocad.
"""
import sys

def validar_autoconectado():
    try:
        from pyautocad import Autocad
        acad = Autocad(create_if_not_exists=False)
        acad.prompt("")
        return acad
    except Exception:
        return None

def obtener_atributos(block_ref):
    attrs = {}
    try:
        attribs = block_ref.GetAttributes()
        for attr in attribs:
            try:
                tag = attr.TagString.strip()
                valor = attr.TextString.strip()
                if tag:
                    attrs[tag] = valor
            except Exception:
                continue
    except Exception:
        pass
    return attrs

def escanear_bloques(acad, bloques_objetivo):
    resultados = []

    try:
        count = acad.model.Count
    except Exception:
        acad.prompt("Error: No se pudo acceder al modelo.\n")
        return resultados

    acad.prompt(f"Escaneando {count} entidades...\n")

    for i in range(count):
        try:
            entity = acad.model.Item(i)
            entity_name = entity.EntityName

            if entity_name != "AcDbBlockReference":
                continue

            block_name = entity.Name.upper().strip()
            nombre_match = None
            for objetivo in bloques_objetivo:
                if objetivo.upper() in block_name:
                    nombre_match = objetivo
                    break

            if not nombre_match:
                continue

            insertion_point = entity.InsertionPoint
            x = round(insertion_point[0], 4)
            y = round(insertion_point[1], 4)

            atributos = obtener_atributos(entity)

            resultados.append({
                "nombre_bloque": entity.Name,
                "tipo_detectado": nombre_match,
                "x": x,
                "y": y,
                "atributos": atributos,
            })

        except Exception:
            continue

    return resultados
