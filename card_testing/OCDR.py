import os
import json
from PIL import Image
import pytesseract

# ---- CONFIGURACIÓN DE ZONAS ----
# (Usa los boxes ajustados)
ZONAS = {
    "nombre":     (10, 180, 140, 790),
    "costo":      (560, 35, 675, 150),
    "fuerza":     (20, 30, 130, 150),
    "raza":       (20, 150, 130, 180),
}

def es_entero(valor):
    try:
        int(valor)
        return True
    except:
        return False

def extraer_atributos_por_zonas(img_path, zonas=ZONAS):
    img = Image.open(img_path)
    resultado = {}
    fuerza_texto = ""
    for campo, box in zonas.items():
        zona_img = img.crop(box)
        texto = pytesseract.image_to_string(zona_img, lang='spa').strip().lower()
        # Guarda el valor limpio para fuerza
        if campo == "fuerza":
            fuerza_texto = texto
        resultado[campo] = texto

    # ---- Lógica de tipo y raza ----
    # Si fuerza es un número puro (aliado)
    if es_entero(fuerza_texto):
        resultado["tipo"] = "aliado"
        # raza queda como esté (puede tener valor)
    elif "totem" in fuerza_texto:
        resultado["tipo"] = "totem"
        resultado["raza"] = ""
        resultado["fuerza"] = "totem"
    elif "arma" in fuerza_texto:
        resultado["tipo"] = "arma"
        resultado["raza"] = ""
        resultado["fuerza"] = "arma"
    else:
        # Si fuerza no es número ni totem/arma, lo dejamos como está y tipo vacía
        resultado["tipo"] = resultado.get("tipo", "")

    return resultado

# ---- PROCESAR UNA SOLA CARTA ----
def procesar_una_carta(path_imagen, out_json='carta.json'):
    atributos = extraer_atributos_por_zonas(path_imagen)
    with open(out_json, 'w', encoding='utf-8') as f:
        json.dump(atributos, f, ensure_ascii=False, indent=2)
    print(f"Atributos extraídos: {atributos}")

# ---- PROCESAR TODAS LAS CARTAS DE UN DIRECTORIO ----
def procesar_directorio(directorio, out_json='cartas.json'):
    resultados = []
    for archivo in os.listdir(directorio):
        if archivo.lower().endswith(('.jpg', '.jpeg', '.png')):
            path_img = os.path.join(directorio, archivo)
            atributos = extraer_atributos_por_zonas(path_img)
            atributos["archivo"] = archivo
            resultados.append(atributos)
    with open(out_json, 'w', encoding='utf-8') as f:
        json.dump(resultados, f, ensure_ascii=False, indent=2)
    print(f"Se procesaron {len(resultados)} cartas y se guardaron en {out_json}")

# ---- EJEMPLO DE USO ----
if __name__ == "__main__":
    modo = input("¿Procesar una sola carta (1) o todo un directorio (2)? ")
    if modo == "1":
        img_path = input("Ruta de la imagen de la carta: ")
        procesar_una_carta(img_path)
    elif modo == "2":
        directorio = input("Ruta al directorio con cartas: ")
        procesar_directorio(directorio)
    else:
        print("Opción no válida")
