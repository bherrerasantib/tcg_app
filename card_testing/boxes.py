from PIL import Image, ImageDraw, ImageFont

ruta_img = 'C:/Users/Benjamin/Downloads/Cartas_Analizador/New/atenea.png'

ZONAS = {
    "nombre":     (10, 180, 140, 790),
    "costo":      (560, 35, 675, 150),
    "fuerza":     (20, 30, 130, 150),
    "raza":       (20, 150, 130, 180),
}

# Colores para cada box, puedes sumar más si tienes más campos
colores = ["red", "blue", "green", "orange", "purple", "cyan", "magenta"]

img = Image.open(ruta_img).convert("RGB")
img_draw = img.copy()
draw = ImageDraw.Draw(img_draw)

for idx, (campo, box) in enumerate(ZONAS.items()):
    color = colores[idx % len(colores)]
    draw.rectangle(box, outline=color, width=3)
    # Etiqueta (opcional): para que se vea el nombre del campo
    etiqueta = campo
    # Ubica la etiqueta en la esquina superior izquierda del box
    x, y = box[0] + 3, box[1] + 3
    draw.text((x, y), etiqueta, fill=color)

img_draw.show()
img_draw.save("zonas_marcadas.jpg")  # Puedes abrir este archivo para revisarlo en detalle

print("Listo. Ajusta las coordenadas en ZONAS hasta que los recuadros estén perfectos.")
