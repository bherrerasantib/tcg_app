from PIL import Image, ImageOps, ImageFilter
import pytesseract
import easyocr
import numpy as np

img_path = 'crop_fuerza.jpg'
img = Image.open(img_path)
reader = easyocr.Reader(['es', 'en'])

print("==== PRUEBA 1: Solo en escala de grises ====")
img1 = img.convert('L').convert('RGB')
img1.show()
res_tess = pytesseract.image_to_string(
    img1, lang='eng', config="--psm 10 -c tessedit_char_whitelist=0123456789"
).strip()
img1_np = np.array(img1)
res_easy = reader.readtext(img1_np, detail=0, paragraph=False)
print(f"Pytesseract (solo número): {res_tess}")
print(f"EasyOCR: {res_easy}")
input("ENTER para la siguiente prueba...")

print("==== PRUEBA 2: Grises + filtro mediano ====")
img2 = img.convert('L').filter(ImageFilter.MedianFilter(3)).convert('RGB')
img2.show()
img2_np = np.array(img2)
res_tess = pytesseract.image_to_string(
    img2, lang='eng', config="--psm 10 -c tessedit_char_whitelist=0123456789"
).strip()
res_easy = reader.readtext(img2_np, detail=0, paragraph=False)
print(f"Pytesseract (solo número): {res_tess}")
print(f"EasyOCR: {res_easy}")
input("ENTER para la siguiente prueba...")

print("==== PRUEBA 3: Grises + invertir ====")
img3 = ImageOps.invert(img.convert('L')).convert('RGB')
img3.show()
res_tess = pytesseract.image_to_string(
    img3, lang='eng', config="--psm 10 -c tessedit_char_whitelist=0123456789"
).strip()
img3_np = np.array(img3)
res_easy = reader.readtext(img3_np, detail=0, paragraph=False)
print(f"Pytesseract (solo número): {res_tess}")
print(f"EasyOCR: {res_easy}")
input("ENTER para la siguiente prueba...")

print("==== PRUEBA 4: Sin ningún preprocesado (RGB original) ====")
img4 = img.convert('RGB')
img4.show()
img4_np = np.array(img4)   # <--- AGREGA ESTA LÍNEA
res_tess = pytesseract.image_to_string(
    img4, lang='eng', config="--psm 10 -c tessedit_char_whitelist=0123456789"
).strip()
res_easy = reader.readtext(img4_np, detail=0, paragraph=False)   # <--- USA EL NP ARRAY
print(f"Pytesseract (solo número): {res_tess}")
print(f"EasyOCR: {res_easy}")
input("ENTER para la siguiente prueba...")

print("==== PRUEBA 5: OCR modo texto (sin whitelist) ====")
img5 = img.convert('RGB')
img5.show()
img5_np = np.array(img5)   # <--- AGREGA ESTA LÍNEA
# Modo texto normal
res_tess_text = pytesseract.image_to_string(
    img5, lang='spa', config="--psm 7"
).strip()
res_easy_text = reader.readtext(img5_np, detail=0, paragraph=False)  # <--- USA EL NP ARRAY
print(f"Pytesseract (texto libre): {res_tess_text}")
print(f"EasyOCR (texto libre): {res_easy_text}")
input("ENTER para terminar...")

print("¡Listo! Así puedes comparar visualmente y decidir el mejor flujo para tu caso real.")
