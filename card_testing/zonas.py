from PIL import Image, ImageDraw, ImageOps
import pytesseract
import easyocr

ruta_img = 'C:/Users/Benjamin/Downloads/Cartas_Analizador/New/atenea.png'

ZONAS = {
    "nombre":     (10, 180, 140, 790),      # nombre vertical
    "costo":      (560, 35, 675, 150),      # arriba derecha
    "fuerza":     (20, 30, 130, 150),       # arriba izquierda
    "raza":       (20, 150, 130, 180),      # debajo de fuerza
}

def preprocesar_numero(img, threshold=100):
    img = img.convert('L')
    img = img.point(lambda x: 0 if x < threshold else 255, 'L')
    # Convertir a RGB antes de retornar
    img = img.convert('RGB')
    return img

def preprocesar_texto(img):
    img = img.convert('L')
    img = ImageOps.autocontrast(img)
    # Convertir a RGB antes de retornar
    img = img.convert('RGB')
    return img

img = Image.open(ruta_img)
reader = easyocr.Reader(['es', 'en'])  # Puedes poner solo 'es' o 'en' si prefieres

for campo, box in ZONAS.items():
    zona_img = img.crop(box)
    # Aplica la rotación/preprocesado según el campo
    if campo == "nombre":
        zona_img = zona_img.rotate(270, expand=True)
        zona_img = preprocesar_texto(zona_img)
    elif campo in ["costo", "fuerza"]:
        zona_img = preprocesar_numero(zona_img)
        print(f"Mostrando zona: {campo}")
        zona_img.show()
        zona_img.save(f"crop_{campo}.png")
        # OCRs
        texto_ocr = pytesseract.image_to_string(
            zona_img,
            lang='eng',
            config="--psm 10 -c tessedit_char_whitelist=0123456789"
        ).strip()
        print(f"pytesseract OCR para {campo}: '{texto_ocr}'")
        results_easyocr = reader.readtext(f"crop_{campo}.png", detail=0)
        print(f"EasyOCR para {campo}: {results_easyocr}")
    else:
        zona_img = preprocesar_texto(zona_img)

    print(f"Mostrando zona: {campo}")
    zona_img = zona_img.convert("RGB")
    zona_img.show()
    zona_img.save(f"crop_{campo}.jpg", format="JPEG")   # Usa JPG

    # OCRs
    if campo in ["costo", "fuerza"]:
        texto_ocr = pytesseract.image_to_string(
            zona_img,
            lang='eng',
            config="--psm 10 -c tessedit_char_whitelist=0123456789"
        ).strip()
        print(f"pytesseract OCR para {campo}: '{texto_ocr}'")
    results_easyocr = reader.readtext(f"crop_{campo}.jpg", detail=0)
    print(f"EasyOCR para {campo}: {results_easyocr}")

    input("Presiona ENTER para mostrar la siguiente zona...")

print("Listo. Ajusta los boxes o el threshold si lo ves necesario.")
