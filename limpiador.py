import sys
import os
import argparse

def clean_file(input_path, output_path=None):
    if not os.path.isfile(input_path):
        print(f"Error: El archivo '{input_path}' no existe.")
        return

    # Si no hay output, sobreescribimos el original (in-place)
    temp_path = input_path + ".tmp"
    
    print(f"🧹 Limpiando archivo: {input_path}...")
    
    try:
        with open(input_path, 'r', encoding='utf-8', errors='ignore') as infile, \
             open(temp_path, 'w', encoding='utf-8') as outfile:
            
            for line in infile:
                # Quitamos espacios en blanco al final (pero no el newline por ahora)
                content = line.strip()
                
                # Regla: borrar ':' y '.' si están al final de la línea
                # Se repite mientras queden caracteres al final por si hay "password:.." -> "password"
                while content.endswith(':') or content.endswith('.'):
                    content = content[:-1]
                
                if content:
                    outfile.write(content + '\n')
        
        # Reemplazar el archivo original o escribir en el nuevo
        target = output_path if output_path else input_path
        if os.path.exists(target) and not output_path:
            os.remove(input_path)
            
        os.rename(temp_path, target)
        print(f"✅ Limpieza completada. Guardado en: {target}")

    except Exception as e:
        print(f"❌ Error durante la limpieza: {e}")
        if os.path.exists(temp_path):
            os.remove(temp_path)

def main():
    parser = argparse.ArgumentParser(description="Limpia diccionarios borrando ':' y '.' al final de cada línea.")
    parser.add_argument("file", help="Ruta al archivo a limpiar")
    parser.add_argument("-o", "--output", help="Ruta de salida (opcional, por defecto sobreescribe el original)")

    args = parser.parse_args()
    clean_file(args.file, args.output)

if __name__ == "__main__":
    main()
